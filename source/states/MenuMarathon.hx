package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;
import sys.io.File;
import sys.FileSystem;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxGradient;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.display.FlxBackdrop;
import substates.Marathon_Substate;

using StringTools;

typedef MarathonVars =
{
	var songNames:Array<String>;
	var songDifficulties:Array<String>;
}

class MenuMarathon extends MusicBeatState
{
	public static var _marathon:MarathonVars;

	var bg:FlxSprite = new FlxSprite(-89).loadGraphic(Paths.image('MaraBG_Main'));
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Mara_Checker'), FlxAxes.XY, 0.2, 0.2);
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);
	var side:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('Mara_Bottom'));

	public static var curSelected:Int = 0;

	public var targetY:Float = 0;
	var camLerp:Float = 0.1;
	var selectable:Bool = false;

	public static var substated:Bool = false;
	public static var no:Bool = false;

	var songs:Array<SongTitles> = [];

	public static var curDifficulty:Int = 2;

	var scoreText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var tracksUsed:FlxText;
	private var camGame:FlxCamera;
	public var camOther:FlxCamera;
	private var grpSongs:FlxTypedGroup<Alphabet>;
	var sprDifficulty:FlxSprite;

	override function create()
	{
		camGame = new FlxCamera();
		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0;
		
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;
		substated = false;

		PlayState.isStoryMode = false;
		PlayState.isEndless = false;
		PlayState.isMarathon = true;
		PlayState.isFreeplay = false;
		PlayState.isSurvival = false;

		lime.app.Application.current.window.title = lime.app.Application.current.meta.get('name');

		loadCurrent();

		no = false;

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		 var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		 for (i in 0...initSonglist.length)
		 {
		 	var data:Array<String> = initSonglist[i].split(':');
			songs.push(new SongTitles(data[0]));
		 }

		Mods.loadTopMod();

		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.03;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55FFFFFF, 0xAAFFFFFF], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		add(checker);
		checker.scrollFactor.set(0.07, 0.07);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true);
			// songText.itemType = "Vertical";
			songText.targetY = i;
			grpSongs.add(songText);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		side.scrollFactor.x = 0;
		side.scrollFactor.y = 0;
		side.antialiasing = true;
		side.screenCenter();
		add(side);

		var diffTex = Paths.getSparrowAtlas('difficulties');
		sprDifficulty = new FlxSprite(130, 0);
		sprDifficulty.frames = diffTex;
		sprDifficulty.animation.addByPrefix('noob', 'NOOB');
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.addByPrefix('expert', 'EXPERT');
		sprDifficulty.animation.addByPrefix('insane', 'INSANE');
		sprDifficulty.animation.play('easy');
		sprDifficulty.screenCenter(X);
		sprDifficulty.y = FlxG.height - sprDifficulty.height - 8;
		add(sprDifficulty);

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Language.fonts(), 32, FlxColor.WHITE, RIGHT);
		scoreText.alignment = CENTER;
		scoreText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		scoreText.screenCenter(X);
		scoreText.y = sprDifficulty.y - 38;
		add(scoreText);

		tracksUsed = new FlxText(FlxG.width * 0.7, 680, 0, "0 TRACKS USED", 20);
		tracksUsed.setFormat(Language.fonts(), 32, FlxColor.WHITE, RIGHT);
		tracksUsed.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		add(tracksUsed);

		changeSelection();
		changeDiff();

		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			selectable = true;
		});

		#if android
		addVirtualPad(UP_DOWN, A_B);
		#else
		if(ClientPrefs.data.tabletmode)
			addVirtualPad(UP_DOWN, A_B);
		#end

		super.create();
		CustomFadeTransition.nextCamera = camOther;
		side.y = FlxG.height;
		FlxTween.tween(side, {y: FlxG.height - side.height}, 0.6, {ease: FlxEase.quartInOut});

		FlxTween.tween(bg, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
		camGame.zoom = 0.6;
		camGame.alpha = 0;
		FlxTween.tween(camGame, {zoom: 1, alpha: 1}, 0.7, {ease: FlxEase.quartInOut});
	}

	override function update(elapsed:Float)
	{
		var isTab:Bool = ClientPrefs.data.tabletmode;
		checker.x -= -0.67 / (ClientPrefs.data.framerate / 60);
		checker.y -= 0.2 / (ClientPrefs.data.framerate / 60);

		super.update(elapsed);

		var bullShit:Int = 0;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

				var scaledY = FlxMath.remapToRange(item.targetY, 0, 1, 0, 1.3);

				item.y = FlxMath.lerp(item.y, (scaledY * 120) + (FlxG.height * 0.5), 0.16/(ClientPrefs.data.framerate / 60));
				item.x = FlxMath.lerp(item.x, (targetY * 0) + 308, 0.16/(ClientPrefs.data.framerate / 60));
				// item.x += -45/(ClientPrefs.data.framerate / 60);
		}

		tracksUsed.text = PlayState.storyPlaylist.length + " TRACKS USED";
		tracksUsed.x = 1240 - tracksUsed.width;

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5 / (ClientPrefs.data.framerate / 60)));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UI_UP_P || (isTab && MusicBeatState._virtualpad.buttonUp.justPressed);
		var downP = controls.UI_DOWN_P || (isTab && MusicBeatState._virtualpad.buttonDown.justPressed);
		var accepted = controls.ACCEPT || (isTab && MusicBeatState._virtualpad.buttonA.justPressed);
		var back = controls.BACK || (isTab && MusicBeatState._virtualpad.buttonB.justPressed);

		if (!substated && selectable)
		{
			if (upP)
				changeSelection(-1);
			if (downP)
				changeSelection(1);

			if (controls.UI_LEFT_P || (isTab && MusicBeatState._virtualpad.buttonLeft.justPressed))
				changeDiff(-1);
			if (controls.UI_RIGHT_P || (isTab && MusicBeatState._virtualpad.buttonRight.justPressed))
				changeDiff(1);

			if (back)
			{
				substated = true;
				#if android removeVirtualPad(); #else if(ClientPrefs.data.tabletmode) removeVirtualPad(); #end
				FlxG.sound.play(PathsList.themeSound('cancelMenu'), ClientPrefs.data.soundVolume);

				FlxG.state.openSubState(new Marathon_Substate());
			}

			if (accepted)
			{
				PlayState.difficultyPlaylist.push(Std.string(curDifficulty));
				PlayState.storyPlaylist.push(Std.string(songs[curSelected].songName.toLowerCase()));

				FlxG.sound.play(PathsList.themeSound('confirmMenu'), ClientPrefs.data.soundVolume);

				saveCurrent();
			}
		}
		scoreText.x = FlxG.width / 2 - scoreText.width / 2;

		if (no)
		{
			bg.kill();
			side.kill();
			gradientBar.kill();
			checker.kill();
			sprDifficulty.kill();
			scoreText.kill();
			grpSongs.clear();
			tracksUsed.kill();
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 5;
		if (curDifficulty > 5)
			curDifficulty = 0;

		#if !switch
		intendedScore = Std.int(FlxG.save.data.marathonScore);
		#end

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('noob');
			case 1:
				sprDifficulty.animation.play('easy');
			case 2:
				sprDifficulty.animation.play('normal');
			case 3:
				sprDifficulty.animation.play('hard');
			case 4:
				sprDifficulty.animation.play('expert');
			case 5:
				sprDifficulty.animation.play('insane');
		}

		sprDifficulty.alpha = 0;

		sprDifficulty.y = FlxG.height - sprDifficulty.height - 38;
		FlxTween.tween(sprDifficulty, {y: FlxG.height - sprDifficulty.height - 8, alpha: 1}, 0.04);
		sprDifficulty.x = FlxG.width / 2 - sprDifficulty.width / 2;
	}

	function changeSelection(change:Int = 0)
	{
		// NGio.logEvent('Fresh');
		FlxG.sound.play(PathsList.themeSound('scrollMenu'), ClientPrefs.data.soundVolume);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Std.int(FlxG.save.data.marathonScore);
		#end

		var bullShit:Int = 0;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function loadCurrent()
	{
		if (!FileSystem.isDirectory('presets/marathon'))
			FileSystem.createDirectory('presets/marathon');

		if (!FileSystem.exists('presets/marathon/current'))
		{
			_marathon = {
				songDifficulties: [],
				songNames: []
			}

			File.saveContent(('presets/marathon/current'), Json.stringify(_marathon, null, '    '));
		}
		else
		{
			var data:String = File.getContent('presets/marathon/current');
			_marathon = Json.parse(data);
			PlayState.difficultyPlaylist = _marathon.songDifficulties;
			PlayState.storyPlaylist = _marathon.songNames;
		}
	}

	public static function saveCurrent()
	{
		_marathon = {
			songDifficulties: PlayState.difficultyPlaylist,
			songNames: PlayState.storyPlaylist
		}
		File.saveContent(('presets/marathon/current'), Json.stringify(_marathon, null, '    '));
	}

	public static function loadPreset(input:String):Void
	{
		var data:String = File.getContent('presets/marathon/' + input);
		_marathon = Json.parse(data);

		PlayState.difficultyPlaylist = _marathon.songDifficulties;
		PlayState.storyPlaylist = _marathon.songNames;

		saveCurrent();
	}

	public static function savePreset(input:String):Void
	{
		_marathon = {
			songDifficulties: PlayState.difficultyPlaylist,
			songNames: PlayState.storyPlaylist
		}
		File.saveContent(('presets/marathon/' + input), Json.stringify(_marathon, null, '    ')); // just an example for now
	}
}

class SongTitles
{
	public var songName:String = "";

	public function new(song:String)
	{
		this.songName = song;
	}
}
