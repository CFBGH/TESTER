package substates;

import backend.Highscore;
import backend.Song;
import backend.WeekData;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxStringUtil;
import options.OptionsState;
import states.*;

class PauseSubState extends MusicBeatSubstate {
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = [];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	public static var songName:String = '';

	public function new(x:Float, y:Float) {
		super();
		#if android
		menuItemsOG = ['Resume', 'Restart Song', 'Change Difficulty', 'Chart Editor', 'Options', 'Exit to menu'];
		#else
		if(ClientPrefs.data.tabletmode)
			menuItemsOG = ['Resume', 'Restart Song', 'Change Difficulty', 'Chart Editor', 'Options', 'Exit to menu'];
		else
			menuItemsOG = ['Resume', 'Restart Song', 'Change Difficulty', 'Options', 'Exit to menu'];
		#end

		if (Difficulty.list.length < 2)
			menuItemsOG.remove('Change Difficulty'); // No need to change difficulty if there is only one!

		if (PlayState.chartingMode) {
			menuItemsOG.insert(2, 'Leave Charting Mode');

			var num:Int = 0;
			if (!PlayState.instance.startingSong) {
				num = 1;
				menuItemsOG.insert(3, 'Skip Time');
			}
			menuItemsOG.insert(3 + num, 'End Song');
			menuItemsOG.insert(4 + num, 'Toggle Practice Mode');
			menuItemsOG.insert(5 + num, 'Toggle Botplay');
		}
		menuItems = menuItemsOG;

		for (i in 0...Difficulty.list.length) {
			var diff:String = Difficulty.getString(i);
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		pauseMusic = new FlxSound();
		if (songName != null) {
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		} else if (songName != 'None') {
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF0000BB);
		add(bg);
		bg.alpha = 0.5;

		var bgGrid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x11FFFFFF, 0x0));
		bgGrid.alpha = 0.5;
		bgGrid.velocity.set(175, 175);
		add(bgGrid);

		var levelInfo:FlxText = new FlxText(20, 15, 0, PlayState.SONG.song, 32);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Language.fonts(), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, Difficulty.getString().toUpperCase(), 32);
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Language.fonts(), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 64, 0, "Blueballed: " + PlayState.deathCounter, 32);
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Language.fonts(), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 133, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Language.fonts(), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var loopsText = new FlxText(20, 15 + 96, 0, "Loops: " + PlayState.loops, 32);
		loopsText.scrollFactor.set();
		loopsText.setFormat(Language.fonts(), 32);
		loopsText.updateHitbox();
		loopsText.visible = PlayState.isEndless;
		add(loopsText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Language.fonts(), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		loopsText.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);
		loopsText.x = FlxG.width - (loopsText.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.expoInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.expoInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.expoInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.expoInOut, startDelay: 0.7});
		FlxTween.tween(loopsText, {alpha: 1, y: loopsText.y + 5}, 0.4, {ease: FlxEase.expoInOut, startDelay: 0.9});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);

		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Language.fonts(), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		#if android
		if(PlayState.chartingMode)
			addVirtualPad(FULL, A);
		else
			addVirtualPad(FULL, A);

		addPadCamera();
		#else
		if(ClientPrefs.data.tabletmode) {
			if(PlayState.chartingMode)
				addVirtualPad(FULL, A);
			else
				addVirtualPad(FULL, A);
			
			addPadCamera();
		}
		#end
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;

	override function update(elapsed:Float) {
		cantUnpause -= elapsed;
		var isTab = ClientPrefs.data.tabletmode;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();

		var upP = controls.UI_UP_P || (isTab && MusicBeatSubstate._virtualpad.buttonUp.justPressed);
		var downP = controls.UI_DOWN_P || (isTab && MusicBeatSubstate._virtualpad.buttonDown.justPressed);
		var accepted = controls.ACCEPT || (isTab && MusicBeatSubstate._virtualpad.buttonA.justPressed);

		if (upP) {
			changeSelection(-1);
		}
		if (downP) {
			changeSelection(1);
		}

		var daSelected:String = menuItems[curSelected];
		switch (daSelected) {
			case 'Skip Time':
				if (controls.UI_LEFT_P || (isTab && MusicBeatSubstate._virtualpad.buttonLeft.justPressed)) {
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P || (isTab && MusicBeatSubstate._virtualpad.buttonRight.justPressed)) {
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if (controls.UI_LEFT || controls.UI_RIGHT || (isTab && MusicBeatSubstate._virtualpad.buttonLeft.pressed) || (isTab && MusicBeatSubstate._virtualpad.buttonRight.pressed)) {
					holdTime += elapsed;
					if (holdTime > 0.5) {
						curTime += 45000 * elapsed * ((controls.UI_LEFT || (isTab && MusicBeatSubstate._virtualpad.buttonLeft.pressed)) ? -1 : 1);
					}

					if (curTime >= FlxG.sound.music.length)
						curTime -= FlxG.sound.music.length;
					else if (curTime < 0)
						curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		if (accepted && (cantUnpause <= 0 || !controls.controllerMode)) {
			if (menuItems == difficultyChoices) {
				try {
					if (menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {
						var name:String = PlayState.SONG.song;
						var poop = Highscore.formatSong(name, curSelected);
						PlayState.SONG = Song.loadFromJson(poop, name);
						PlayState.storyDifficulty = curSelected;
						MusicBeatState.resetState();
						FlxG.sound.music.volume = 0;
						PlayState.changedDifficulty = true;
						PlayState.chartingMode = false;
						return;
					}
				} catch (e:Dynamic) {
					trace('ERROR! $e');

					var errorStr:String = e.toString();
					if (errorStr.startsWith('[file_contents,assets/data/'))
						errorStr = 'Missing file: ' + errorStr.substring(27, errorStr.length - 1); // Missing chart
					missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
					missingText.screenCenter(Y);
					missingText.visible = true;
					missingTextBG.visible = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));

					super.update(elapsed);
					return;
				}

				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected) {
				case "Resume":
					close();
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					deleteSkipTimeText();
					regenMenu();
				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case "Restart Song":
					restartSong();
				case "Leave Charting Mode":
					restartSong();
					PlayState.chartingMode = false;
				case 'Skip Time':
					if (curTime < Conductor.songPosition) {
						PlayState.startOnTime = curTime;
						restartSong(true);
					} else {
						if (curTime != Conductor.songPosition) {
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}
				case 'End Song':
					close();
					PlayState.instance.notes.clear();
					PlayState.instance.unspawnNotes = [];
					PlayState.instance.finishSong(true);
				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;
				case 'Options':
					PlayState.instance.paused = true; // For lua
					PlayState.instance.vocals.volume = 0;
					MusicBeatState.switchState(new OptionsState());
					if (ClientPrefs.data.pauseMusic != 'None') {
						FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), pauseMusic.volume);
						FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
						FlxG.sound.music.time = pauseMusic.time;
					}
					OptionsState.onPlayState = true;
				case "Exit to menu":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					Mods.loadTopMod();
					if(ClientPrefs.data.styleEngine == 'MicUp') {
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						if (PlayState.isStoryMode) {
							MusicBeatState.switchState(new StoryMenuState());
						} else if(PlayState.isFreeplay || PlayState.chartingMode) {
							MusicBeatState.switchState(new FreeplayStyle());
						} else if(PlayState.isEndless) {
							MusicBeatState.switchState(new MenuEndless());
						} else if(PlayState.isMarathon) {
							MusicBeatState.switchState(new MenuMarathon());
						} else if(PlayState.isSurvival) {
							MusicBeatState.switchState(new MenuSurvival());
						}
					} else if (ClientPrefs.data.styleEngine == 'Kade') {
						PlayState.instance.saveRatingData('Kade', true);
						PlayState.instance.openSubState(new substates.ResultsScreen());
						FlxG.sound.playMusic(Paths.music('freakyMenuKE'));
					} else {
						if (PlayState.isStoryMode)
							MusicBeatState.switchState(new StoryMenuState());
						else
							MusicBeatState.switchState(new FreeplayState());

						if(ClientPrefs.data.styleEngine == 'Touhou') FlxG.sound.playMusic(Paths.music('freakyMenuTH'));
						else FlxG.sound.playMusic(Paths.music('freakyMenu'));
					}
					PlayState.cancelMusicFadeTween();
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
					FlxG.camera.followLerp = 0;
			}
		}
	}

	function deleteSkipTimeText() {
		if (skipTimeText != null) {
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false) {
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if (noTrans) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		}
		MusicBeatState.resetState();
	}

	override function destroy() {
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void {
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0) {
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));

				if (item == skipTimeTracker) {
					curTime = Math.max(0, Conductor.songPosition);
					updateSkipTimeText();
				}
			}
		}
		missingText.visible = false;
		missingTextBG.visible = false;
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var item = new Alphabet(90, 320, menuItems[i], true);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);

			if (menuItems[i] == 'Skip Time') {
				skipTimeText = new FlxText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Language.fonts(), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}
		curSelected = 0;
		changeSelection();
	}

	function updateSkipTextStuff() {
		if (skipTimeText == null || skipTimeTracker == null)
			return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText() {
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false)
			+ ' / '
			+ FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
}
