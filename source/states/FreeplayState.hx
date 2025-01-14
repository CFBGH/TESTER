package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import objects.HealthIcon;
import objects.MusicPlayer;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import flixel.math.FlxMath;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];
	var selector:FlxText;
	private static var curSelected:Int = 0;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;
	var closedState:Bool = false;
	var freeplay:Bool = false;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var bottomString:String;
	var bottomText:FlxText;
	var bottomBG:FlxSprite;
	var player:MusicPlayer;

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		PlayState.isEndless = false;
		PlayState.isMarathon = false;
		PlayState.isFreeplay = true;
		PlayState.isSurvival = false;
		WeekData.reloadWeekFiles(false);

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		Mods.loadTopMod();

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
			songText.targetY = i;
			grpSongs.add(songText);

			songText.scaleX = Math.min(1, 980 / songText.width);
			songText.snapToPosition();

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			
			// too laggy with a lot of songs, so i had to recode the logic for it
			songText.visible = songText.active = songText.isMenuItem = false;
			icon.visible = icon.active = false;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Language.fonts(), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Language.fonts(), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		lerpSelected = curSelected;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		var leText:String = ((ClientPrefs.data.styleEngine == 'Psych' || ClientPrefs.data.styleEngine == 'Touhou' || !ClientPrefs.data.selectSongPlay) ? (ClientPrefs.data.haveVoices ? ${language.States.Free.cons[0]} : ${language.States.Free.cons[1]}) : ${language.States.Free.cons[2]});
		bottomString = leText;
		var size:Int = 16;
		bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Language.fonts(), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);
		
		player = new MusicPlayer(this);
		add(player);
		
		changeSelection();

		#if android
		addVirtualPad(FULL, A_B_C_X_Y_Z);
		#else
		if(ClientPrefs.data.tabletmode)
			addVirtualPad(FULL, A_B_C_X_Y_Z);
		#end

		updateTexts();
		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (vocals != null) trace('LSound: ${vocals.amplitudeLeft}, RSound: ${vocals.amplitudeRight}');
		var isTab = ClientPrefs.data.tabletmode;
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FlxMath.bound(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, FlxMath.bound(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT || (isTab && MusicBeatState._virtualpad.buttonZ.pressed)) shiftMult = 3;

		if (!player.playingMusic)
		{
			scoreText.text = '${language.States.Free.pb}$lerpScore (${ratingSplit.join('.')}%)';
			positionHighscore();
			
			if(songs.length > 1)
			{
				if(FlxG.keys.justPressed.HOME)
				{
					curSelected = 0;
					changeSelection();
					holdTime = 0;	
				}
				else if(FlxG.keys.justPressed.END)
				{
					curSelected = songs.length - 1;
					changeSelection();
					holdTime = 0;	
				}
				if (controls.UI_UP_P || (isTab && MusicBeatState._virtualpad.buttonUp.justPressed))
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (controls.UI_DOWN_P || (isTab && MusicBeatState._virtualpad.buttonDown.justPressed))
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP || (isTab && MusicBeatState._virtualpad.buttonUp.pressed) || (isTab && MusicBeatState._virtualpad.buttonDown.pressed))
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				}

				if(FlxG.mouse.wheel != 0)
				{
					FlxG.sound.play(PathsList.themeSound('scrollMenu'), ClientPrefs.data.soundVolume);
					changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				}
			}

			if (controls.UI_LEFT_P || (isTab && MusicBeatState._virtualpad.buttonLeft.justPressed))
			{
				changeDiff(-1);
				_updateSongLastDifficulty();
			}
			else if (controls.UI_RIGHT_P || (isTab && MusicBeatState._virtualpad.buttonRight.justPressed))
			{
				changeDiff(1);
				_updateSongLastDifficulty();
			}
		}
		if (controls.BACK || (isTab && MusicBeatState._virtualpad.buttonB.justPressed))
		{
			if (player.playingMusic)
			{
				FlxG.sound.music.stop();
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				instPlaying = -1;

				player.playingMusic = false;
				player.switchPlayMusic();

				if(ClientPrefs.data.styleEngine == 'Kade')
					FlxG.sound.playMusic(Paths.music('freakyMenuKE'), 0);
				else if(ClientPrefs.data.styleEngine == 'TouHou')
					FlxG.sound.playMusic(Paths.music('freakyMenuTH'), 0);
				else
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				
				FlxTween.tween(FlxG.sound, {volume: ClientPrefs.data.musicVolume}, 2);
				freeplay = false;
			}
			else 
			{
				closedState = true;
				persistentUpdate = false;
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(PathsList.themeSound('cancelMenu'), ClientPrefs.data.soundVolume);
				MusicBeatState.switchState(new MainMenuState());
			}
		}

		if((FlxG.keys.justPressed.CONTROL || (isTab && MusicBeatState._virtualpad.buttonC.justPressed)) && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}

		if(ClientPrefs.data.styleEngine == 'Psych' || ClientPrefs.data.styleEngine == 'Touhou') {
			if(FlxG.keys.justPressed.SPACE || (isTab && MusicBeatState._virtualpad.buttonX.justPressed)) {
				if(instPlaying != curSelected && !player.playingMusic)
				{
					destroyFreeplayVocals();
					FlxG.sound.music.volume = 0;

					freeplay = true;
					Mods.currentModDirectory = songs[curSelected].folder;
					var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
					PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());

					Conductor.bpm = PlayState.SONG.bpm;

					if (PlayState.SONG.needsVoices && ClientPrefs.data.haveVoices)
					{
						vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
						FlxG.sound.list.add(vocals);
						vocals.persist = true;
						vocals.looped = true;
					}
					else if (vocals != null)
					{
						vocals.stop();
						vocals.destroy();
						vocals = null;
					}

					FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), ClientPrefs.data.musicVolume);
					if(vocals != null) { //Sync vocals to Inst
						vocals.play();
						vocals.volume = ClientPrefs.data.musicVolume;
					}
					instPlaying = curSelected;

					player.playingMusic = true;
					player.curTime = 0;
					player.switchPlayMusic();
				}
				else if (instPlaying == curSelected && player.playingMusic)
					player.pauseOrResume(player.paused);
			}
		} else {
			if(ClientPrefs.data.selectSongPlay) {
				if(instPlaying != curSelected && !player.playingMusic) {
					destroyFreeplayVocals();
					FlxG.sound.music.volume = 0;

					freeplay = true;
					Mods.currentModDirectory = songs[curSelected].folder;
					var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
					PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());

					Conductor.bpm = PlayState.SONG.bpm;

					if (PlayState.SONG.needsVoices && ClientPrefs.data.haveVoices) {
						vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
						FlxG.sound.list.add(vocals);
						vocals.persist = true;
						vocals.looped = true;
					}
					else if (vocals != null) {
						vocals.stop();
						vocals.destroy();
						vocals = null;
					}

					FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), ClientPrefs.data.musicVolume);
					if(vocals != null) { //Sync vocals to Inst
						vocals.play();
						vocals.volume = ClientPrefs.data.musicVolume;
					}
					instPlaying = curSelected;
				}
			} else {
				if(FlxG.keys.justPressed.SPACE || (isTab && MusicBeatState._virtualpad.buttonX.justPressed)) {
					if(instPlaying != curSelected && !player.playingMusic){
						destroyFreeplayVocals();
						FlxG.sound.music.volume = 0;

						freeplay = true;
						Mods.currentModDirectory = songs[curSelected].folder;
						var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
						PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());

						Conductor.bpm = PlayState.SONG.bpm;

						if (PlayState.SONG.needsVoices && ClientPrefs.data.haveVoices)
						{
							vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
							FlxG.sound.list.add(vocals);
							vocals.persist = true;
							vocals.looped = true;
						}
						else if (vocals != null)
						{
							vocals.stop();
							vocals.destroy();
							vocals = null;
						}

						FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), ClientPrefs.data.musicVolume);
						if(vocals != null) { //Sync vocals to Inst
							vocals.play();
							vocals.volume = ClientPrefs.data.musicVolume;
						}
						instPlaying = curSelected;

						player.playingMusic = true;
						player.curTime = 0;
						player.switchPlayMusic();
					}
					else if (instPlaying == curSelected && player.playingMusic)
						player.pauseOrResume(player.paused);
				}
			}
		}

		if ((controls.ACCEPT || (isTab && MusicBeatState._virtualpad.buttonA.justPressed)) && !player.playingMusic)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			/*#if MODS_ALLOWED
			if(!FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			try
			{
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				if(colorTween != null) {
					colorTween.cancel();
				}
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');

				var errorStr:String = e.toString();
				if(errorStr.startsWith('[file_contents,assets/data/')) errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length-1); //Missing chart
				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(PathsList.themeSound('cancelMenu'), ClientPrefs.data.soundVolume);

				updateTexts(elapsed);
				super.update(elapsed);
				return;
			}
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		else if((controls.RESET || (isTab && MusicBeatState._virtualpad.buttonY.justPressed)) && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(PathsList.themeSound('scrollMenu'), ClientPrefs.data.soundVolume);
		}

		updateTexts(elapsed);

		//if(vocals != null){ trace('L:'+vocals.amplitudeLeft);trace('R:'+vocals.amplitudeRight);}
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, FlxMath.bound(1 - (elapsed * 3.125), 0, 1));

		super.update(elapsed);
	}

	private var sickBeats:Int = 0;
	override function beatHit()
	{
		super.beatHit();
		trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + sickBeats);

		if (FlxG.camera.zoom < 1.35 && ClientPrefs.data.camZooms && curBeat % 4 == 0 && freeplay)
		{
			if (ClientPrefs.data.styleEngine != 'Touhou')
				FlxG.camera.zoom += 0.075;
			else
				FlxG.camera.zoom += 0.05;
		}

		if(!closedState && freeplay) sickBeats++;
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		if (player.playingMusic)
			return;

		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		lastDifficultyName = Difficulty.getString(curDifficulty);
		if (Difficulty.list.length > 1)
			diffText.text = '< ' + lastDifficultyName.toUpperCase() + ' >';
		else
			diffText.text = lastDifficultyName.toUpperCase();

		positionHighscore();
		missingText.visible = false;
		missingTextBG.visible = false;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (player.playingMusic)
			return;

		_updateSongLastDifficulty();
		if(playSound) FlxG.sound.play(PathsList.themeSound('scrollMenu'), ClientPrefs.data.soundVolume);

		var lastList:Array<String> = Difficulty.list;
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			bullShit++;
			item.alpha = 0.6;
			if (item.targetY == curSelected)
				item.alpha = 1;
		}
		
		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();
		
		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !lastList.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		changeDiff();
		_updateSongLastDifficulty();
	}

	inline private function _updateSongLastDifficulty()
	{
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty);
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(lerpSelected, curSelected, FlxMath.bound(elapsed * 9.6, 0, 1));
		for (i in _lastVisibles)
		{
			grpSongs.members[i].visible = grpSongs.members[i].active = false;
			iconArray[i].visible = iconArray[i].active = false;
		}
		_lastVisibles = [];

		var min:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected - _drawDistance)));
		var max:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected + _drawDistance)));
		for (i in min...max)
		{
			var item:Alphabet = grpSongs.members[i];
			item.visible = item.active = true;
			item.x = ((item.targetY - lerpSelected) * item.distancePerItem.x) + item.startPosition.x;
			item.y = ((item.targetY - lerpSelected) * 1.3 * item.distancePerItem.y) + item.startPosition.y;

			var icon:HealthIcon = iconArray[i];
			icon.visible = icon.active = true;
			_lastVisibles.push(i);
		}
	}

	override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;
		if (!FlxG.sound.music.playing)
			if(ClientPrefs.data.styleEngine == 'Kade')
				FlxG.sound.playMusic(Paths.music('freakyMenuKE'), ClientPrefs.data.musicVolume);
			else if (ClientPrefs.data.styleEngine == 'TouHou')
				FlxG.sound.playMusic(Paths.music('freakyMenuTH'), ClientPrefs.data.musicVolume);
			else
				FlxG.sound.playMusic(Paths.music('freakyMenu'), ClientPrefs.data.musicVolume);
	}	
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}