package substates;

import haxe.Exception;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import flixel.FlxSubState;
import options.Option;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;
import flixel.input.FlxKeyManager;
import backend.OFLSprite;
import backend.HitGraph;
import backend.Rating;
import lib.HelperFunctions;
import states.PlayState;

using StringTools;

class ResultsScreen extends FlxSubState
{
	public var background:FlxSprite;
	public var text:FlxText;

	public var anotherBackground:FlxSprite;
	public var graph:HitGraph;
	public var graphSprite:OFLSprite;

	public var comboText:FlxText;
	public var contText:FlxText;
	public var moreText:FlxText;
	public var settingsText:FlxText;

	public var music:FlxSound;

	public var graphData:BitmapData;

	public var ranking:String;
	public var accuracy:String;
	public var totalNotes:Int;
	public var songFinish:Bool = false;

	override function create()
	{
		if (PlayState.songRatingFC == 'FC' || PlayState.songRatingFC == 'GFC' || PlayState.songRatingFC == 'MFC') {
			totalNotes = PlayState.songHitsRating;
		} else {
			totalNotes = PlayState.songHitsRating + PlayState.misses;
		}

		background = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		background.scrollFactor.set();
		add(background);

		music = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		music.volume = 0;
		music.play(false, FlxG.random.int(0, Std.int(music.length / 2)));
		FlxG.sound.list.add(music);

		background.alpha = 0;

		text = new FlxText(20, -55, 0, 'Song Cleared!\nSong Name: ${PlayState.songNameRating}');
		text.size = 34;
		text.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		text.color = FlxColor.WHITE;
		text.scrollFactor.set();
		add(text);

		var score = PlayState.songScoreRating;
		if (PlayState.isStoryMode)
		{
			score = PlayState.campaignScore;
			text.text = "Week Cleared!";
		}

		var sicks = PlayState.isStoryMode ? PlayState.campaignSicks : PlayState.sicksRa;
		var goods = PlayState.isStoryMode ? PlayState.campaignGoods : PlayState.goodsRa;
		var bads = PlayState.isStoryMode ? PlayState.campaignBads : PlayState.badsRa;
		var shits = PlayState.isStoryMode ? PlayState.campaignShits : PlayState.shitsRa;

		comboText = new FlxText(20, -75, 0,
			'Judgements:\nSicks - ${sicks}\nGoods - ${goods}\nBads - ${bads}\nShits - ${shits}\n\nCombo Breaks: ${(PlayState.misses)}\nHighest Combo: ${PlayState.highestCombo}\nScore: ${PlayState.songScoreRating}\nAccuracy: ${PlayState.percentRating}%\n\nCombo Level: ${PlayState.songRatingFC}\nRate: 1x\nF1 - Replay\nF2 - Restart Song
        ');
		comboText.size = 28;
		comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		comboText.color = FlxColor.WHITE;
		comboText.scrollFactor.set();
		add(comboText);

		contText = new FlxText(FlxG.width - 475, FlxG.height + 50, 0, 'Press ${ClientPrefs.data.tabletmode ? 'Click' : 'ENTER'} to continue.');
		contText.size = 28;
		contText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		contText.color = FlxColor.WHITE;
		contText.scrollFactor.set();
		add(contText);

		anotherBackground = new FlxSprite(FlxG.width - 500, 45).makeGraphic(450, 240, FlxColor.BLACK);
		anotherBackground.scrollFactor.set();
		anotherBackground.alpha = 0;
		add(anotherBackground);

		graph = new HitGraph(FlxG.width - 500, 45, 495, 240);
		graph.alpha = 0;

		graphSprite = new OFLSprite(FlxG.width - 510, 45, 460, 240, graph);

		graphSprite.scrollFactor.set();
		graphSprite.alpha = 0;

		add(graphSprite);

		var sicks = HelperFunctions.truncateFloat(PlayState.sicksRa / PlayState.goodsRa, 1);
		var goods = HelperFunctions.truncateFloat(PlayState.goodsRa / PlayState.badsRa, 1);

		if (sicks == Math.POSITIVE_INFINITY)
			sicks = 0;
		if (goods == Math.POSITIVE_INFINITY)
			goods = 0;

		var mean:Float = 0;

		for (i in 0...PlayState.rep.replay.songNotes.length)
		{
			// 0 = time
			// 1 = length
			// 2 = type
			// 3 = diff
			var obj = PlayState.rep.replay.songNotes[i];
			// judgement
			var obj2 = PlayState.rep.replay.songJudgements[i];

			var obj3 = obj[0];

			var diff = obj[3];
			var judge = obj2;
			if (diff != (166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166))
				mean += diff;
		}

		if (sicks == Math.POSITIVE_INFINITY || sicks == Math.NaN)
			sicks = 1;
		if (goods == Math.POSITIVE_INFINITY || goods == Math.NaN)
			goods = 1;

		graph.update();

		mean = HelperFunctions.truncateFloat(mean / PlayState.rep.replay.songNotes.length, 2);

		settingsText = new FlxText(20, FlxG.height + 50, 0,
			'Mean: ${mean}ms (SICK:${Rating.timingWindows[3]}ms,GOOD:${Rating.timingWindows[2]}ms,BAD:${Rating.timingWindows[1]}ms,SHIT:${Rating.timingWindows[0]}ms)');
		settingsText.size = 16;
		settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
		settingsText.color = FlxColor.WHITE;
		settingsText.scrollFactor.set();
		add(settingsText);

		moreText = new FlxText(FlxG.width - 510, -100, 0,
			'More:\nBPM: ${PlayState.SONG.bpm}\nSpeed: ${PlayState.SONG.speed}\nHits Notes: ${totalNotes}/${PlayState.songHitsRating}\nCombo: ${PlayState.highestCombo}/${PlayState.comboRating}\n\nBotPlay: ${PlayState.botplay}');
		moreText.size = 28;
		moreText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		moreText.color = FlxColor.WHITE;
		moreText.scrollFactor.set();
		add(moreText);

		FlxTween.tween(background, {alpha: 0.5}, 0.5);
		FlxTween.tween(text, {y: 20}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(comboText, {y: 145}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(contText, {y: FlxG.height - 45}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(settingsText, {y: FlxG.height - 35}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(moreText, {y: graph.y + 260}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(anotherBackground, {alpha: 0.6}, 0.5, {
			onUpdate: function(tween:FlxTween)
			{
				graph.alpha = FlxMath.lerp(0, 1, tween.percent);
				graphSprite.alpha = FlxMath.lerp(0, 1, tween.percent);
			}
		});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();
	}

	var frames = 0;

	public static function cancelMusicFadeTween() {
		if (FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	override function update(elapsed:Float)
	{
		if (music != null)
			if (music.volume < 0.5)
				music.volume += 0.01 * elapsed;

		// keybinds

		if (!ClientPrefs.data.tabletmode) {
			if (FlxG.keys.justPressed.ENTER)
			{
				if (music != null)
					music.fadeOut(0.3);

				PlayState.rep = null;

				if (PlayState.isStoryMode) {
					FlxG.sound.playMusic(Paths.music('freakyMenuKE'));

					Mods.loadTopMod();

					cancelMusicFadeTween();
					if (FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new states.StoryMenuState());
				} else {
					trace('WENT BACK TO FREEPLAY??');
					Mods.loadTopMod();

					cancelMusicFadeTween();
					if (FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new states.FreeplayState());
				}
			}
		} else {
			if (FlxG.mouse.justPressed)
			{
				if (music != null)
					music.fadeOut(0.3);

				PlayState.rep = null;

				if (PlayState.isStoryMode) {
					FlxG.sound.playMusic(Paths.music('freakyMenuKE'));

					Mods.loadTopMod();

					cancelMusicFadeTween();
					if (FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new states.StoryMenuState());
				} else {
					trace('WENT BACK TO FREEPLAY??');
					Mods.loadTopMod();

					cancelMusicFadeTween();
					if (FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new states.FreeplayState());
				}
			}
		}

		if (FlxG.keys.justPressed.F1 && !PlayState.loadRep)
		{
			//PlayState.rep = null;

			PlayState.loadRep = true;
			PlayState.chartingMode = false;

			if (music != null)
				music.fadeOut(0.3);

			PlayState.isStoryMode = false;
			PlayState.replaying = true;
			PlayState.storyDifficulty = PlayState.storyDifficulty;
			LoadingState.loadAndSwitchState(new PlayState());
		}

		super.update(elapsed);
	}
}
