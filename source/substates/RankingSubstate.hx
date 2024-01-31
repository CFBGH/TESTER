package substates;

import backend.ClientPrefs;
import backend.Song;
import states.*;
import sys.FileSystem;
import sys.io.File;

class RankingSubstate extends MusicBeatSubstate {
	var pauseMusic:FlxSound;

	var rank:FlxSprite = new FlxSprite(-200, 730);
	var combo:FlxSprite = new FlxSprite(-200, 730);
	var comboRank:String = "N/A";
	var ranking:String = "N/A";
	var rankingNum:Int = 15;
	var press:FlxText;

	public function new(x:Float, y:Float) {
		super();

		generateRanking();

		backend.HighscoreMic.saveRank(PlayState.SONG.song, rankingNum, PlayState.storyDifficulty);

		var tabletmode:Bool = false;
		#if android
		tabletmode = true;
		#else
		tabletmode = ClientPrefs.data.tabletmode;
		#end

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		rank = new FlxSprite(-20, 40).loadGraphic(Paths.image('rankings/$ranking'));
		rank.scrollFactor.set();
		add(rank);
		rank.antialiasing = true;
		rank.setGraphicSize(0, 450);
		rank.updateHitbox();
		rank.screenCenter();

		combo = new FlxSprite(-20, 40).loadGraphic(Paths.image('rankings/$comboRank'));
		combo.scrollFactor.set();
		combo.screenCenter();
		combo.x = rank.x - combo.width / 2;
		combo.y = rank.y - combo.height / 2;
		add(combo);
		combo.antialiasing = true;
		combo.setGraphicSize(0, 130);

		press = new FlxText(20, 15, 0, 'Press ${ClientPrefs.data.tabletmode ? 'Click' : 'ANY'} to continue.', 32);
		press.scrollFactor.set();
		press.setFormat(Paths.font("vcr.ttf"), 32);
		press.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		press.updateHitbox();
		add(press);

		var hint:FlxText = new FlxText(20, 15, 0, "You passed. Try getting under 10 misses for SDCB", 32);
		hint.scrollFactor.set();
		hint.setFormat(Paths.font("vcr.ttf"), 32);
		hint.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		hint.updateHitbox();
		add(hint);

		switch (comboRank) {
			case 'MFC':
				hint.text = "Congrats! You're perfect!";
			case 'GFC':
				hint.text = "You're doing great! Try getting only sicks for MFC";
			case 'FC':
				hint.text = "Good job. Try getting goods at minimum for GFC.";
			case 'SDCB':
				hint.text = "Nice. Try not missing at all for FC.";
		}

		if (PlayState.chartingMode)
			hint.text = "BOOOO, YOU CHEATER! YOU SHOULD BE ASHAMED OF YOURSELF!";

		if (ClientPrefs.getGameplaySetting('botplay')) {
			hint.y -= 35;
			hint.text = "If you wanna gather that rank, disable botplay.";
		}

		if (PlayState.deathCounter >= 30) {
			hint.text = "skill issue\nnoob";
		}

		hint.screenCenter(X);

		hint.alpha = press.alpha = 0;

		press.screenCenter();
		press.y = 670 - press.height;

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(press, {alpha: 1, y: 690 - press.height}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(hint, {alpha: 1, y: 645 - hint.height}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float) {
		if (pauseMusic.volume < 0.5 * 100 / 100)
			pauseMusic.volume += 0.01 * 100 / 100 * elapsed;

		super.update(elapsed);

		if (!ClientPrefs.data.tabletmode) {
			if (FlxG.keys.justPressed.ANY) {
				if (PlayState.isStoryMode) {
					if (PlayState.storyPlaylist.length <= 0) {
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 100 / 100);
						MusicBeatState.switchState(new StoryMenuState());
					}
				} else if(PlayState.isFreeplay) {
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 100 / 100);
					MusicBeatState.switchState(new FreeplayStyle());
				} else if(PlayState.isEndless) {
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 100 / 100);
					MusicBeatState.switchState(new MenuEndless());
				} else if(PlayState.isMarathon) {
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 100 / 100);
					MusicBeatState.switchState(new MenuMarathon());
				} else if(PlayState.isSurvival) {
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 100 / 100);
					MusicBeatState.switchState(new MenuSurvival());
				}
			}
		} else {
			if (FlxG.mouse.justPressed) {
				if (PlayState.isStoryMode) {
					if (PlayState.storyPlaylist.length <= 0) {
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 100 / 100);
						MusicBeatState.switchState(new StoryMenuState());
					}
				} else if(PlayState.isFreeplay) {
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 100 / 100);
					MusicBeatState.switchState(new FreeplayStyle());
				} else if(PlayState.isEndless) {
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 100 / 100);
					MusicBeatState.switchState(new MenuEndless());
				} else if(PlayState.isMarathon) {
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 100 / 100);
					MusicBeatState.switchState(new MenuMarathon());
				} else if(PlayState.isSurvival) {
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 100 / 100);
					MusicBeatState.switchState(new MenuSurvival());
				}
			}
		}
	}

	override function destroy() {
		pauseMusic.destroy();

		super.destroy();
	}

	function generateRanking():String {
		if (PlayState.misses == 0 && PlayState.badsRa == 0 && PlayState.shitsRa == 0 && PlayState.badsRa == 0) // Marvelous (SICK) Full Combo
			comboRank = "MFC";
		else
			if (PlayState.misses == 0 && PlayState.badsRa == 0 && PlayState.shitsRa == 0 && PlayState.badsRa >= 1) // Good Full Combo (Nothing but Goods & Sicks)
			comboRank = "GFC";
		else if (PlayState.misses == 0)
			comboRank = "FC"; // Regular FC
		else if (PlayState.misses < 10)
			comboRank = "SDCB"; // Single Digit Combo Breaks

		// WIFE TIME :)))) (based on Wife3)

		var wifeConditions:Array<Bool> = [
			PlayState.percentRating >= 100, // P
			PlayState.percentRating >= 98.60, // X
			PlayState.percentRating >= 97.50, // X-
			PlayState.percentRating >= 95.80, // SS+
			PlayState.percentRating >= 94.80, // SS
			PlayState.percentRating >= 93.70, // SS-
			PlayState.percentRating >= 92.50, // S+
			PlayState.percentRating >= 91.25, // S
			PlayState.percentRating >= 90.50, // S-
			PlayState.percentRating >= 88, // A+
			PlayState.percentRating >= 85, // A
			PlayState.percentRating >= 80, // A-
			PlayState.percentRating >= 76, // B
			PlayState.percentRating >= 60, // C
			PlayState.percentRating >= 48, // D
			PlayState.percentRating < 25 // E
		];

		for (i in 0...wifeConditions.length) {
			var b = wifeConditions[i];
			if (b) {
				rankingNum = i;
				switch (i) {
					case 0:
						ranking = "P";
					case 1:
						ranking = "X";
					case 2:
						ranking = "X-";
					case 3:
						ranking = "SS+";
					case 4:
						ranking = "SS";
					case 5:
						ranking = "SS-";
					case 6:
						ranking = "S+";
					case 7:
						ranking = "S";
					case 8:
						ranking = "S-";
					case 9:
						ranking = "A+";
					case 10:
						ranking = "A";
					case 11:
						ranking = "A-";
					case 12:
						ranking = "B";
					case 13:
						ranking = "C";
					case 14:
						ranking = "D";
					case 15:
						ranking = "E";
				}

				if (PlayState.chartingMode || PlayState.deathCounter >= 30 || PlayState.percentRating < 10)
					ranking = "F";
				break;
			}
		}
		return ranking;
	}
}
