package substates;

import backend.Highscore;
import backend.WeekData;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import objects.HealthIcon;
import flixel.addons.transition.FlxTransitionableState;

class ResetScoreSubState extends MusicBeatSubstate {
	var bg:FlxSprite;
	var alphabetArray:Array<Alphabet> = [];
	var icon:HealthIcon;
	var onYes:Bool = false;
	var yesText:Alphabet;
	var noText:Alphabet;
	var bgGrid:FlxBackdrop;
	var text:Alphabet;

	var song:String;
	var difficulty:Int;
	var week:Int;

	// Week -1 = Freeplay
	public function new(song:String, difficulty:Int, character:String, week:Int = -1) {
		this.song = song;
		this.difficulty = difficulty;
		this.week = week;

		super();

		var name:String = song;
		if (week > -1) {
			name = WeekData.weeksLoaded.get(WeekData.weeksList[week]).weekName;
		}
		name += ' (' + Difficulty.getString(difficulty) + ')?';

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFBB0000);
		add(bg);
		bg.alpha = 0.5;

		bgGrid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x11FFFFFF, 0x0));
		bgGrid.alpha = 0.5;
		bgGrid.velocity.set(175, 175);
		add(bgGrid);

		var tooLong:Float = (name.length > 18) ? 0.8 : 1; // Fucking Winter Horrorland
		text = new Alphabet(0, 180, "Reset the score of", true);
		text.screenCenter(X);
		alphabetArray.push(text);
		text.alpha = 0;
		add(text);

		text = new Alphabet(0, text.y + 90, name, true);
		text.scaleX = tooLong;
		text.screenCenter(X);
		if (week == -1)
			text.x += 60 * tooLong;
		alphabetArray.push(text);
		text.alpha = 0;
		add(text);
		if (week == -1) {
			icon = new HealthIcon(character);
			icon.setGraphicSize(Std.int(icon.width * tooLong));
			icon.updateHitbox();
			icon.setPosition(text.x - icon.width + (10 * tooLong), text.y - 30);
			icon.alpha = 0;
			add(icon);
		}

		yesText = new Alphabet(0, text.y + 150, 'Yes', true);
		yesText.screenCenter(X);
		yesText.x -= 200;
		add(yesText);

		noText = new Alphabet(0, text.y + 150, 'No', true);
		noText.screenCenter(X);
		noText.x += 200;
		add(noText);
		updateOptions();

		#if android
		addVirtualPad(LEFT_RIGHT, A_B);
		addPadCamera();
		#else
		if(ClientPrefs.data.tabletmode) {
			addVirtualPad(LEFT_RIGHT, A_B);
			addPadCamera();
		}
		#end
	}

	override function update(elapsed:Float) {
		var isTab = ClientPrefs.data.tabletmode;
		for (i in 0...alphabetArray.length) {
			var spr = alphabetArray[i];
			spr.alpha += elapsed * 2.5;
		}
		if (week == -1)
			icon.alpha += elapsed * 2.5;

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P || (isTab && MusicBeatSubstate._virtualpad.buttonLeft.justPressed) || (isTab && MusicBeatSubstate._virtualpad.buttonRight.justPressed)) {
			FlxG.sound.play(Paths.sound('scrollMenu'), 1);
			onYes = !onYes;
			updateOptions();
		}
		if (controls.BACK || (isTab && MusicBeatSubstate._virtualpad.buttonB.justPressed)) {
			if(ClientPrefs.data.styleEngine == 'MicUp') {
				if(states.FreeplayStyle.vocals != null) states.FreeplayStyle.vocals.fadeIn(0.4, 0);
				FlxG.sound.play(Paths.sound('cancelMenu'));
				
				#if android
				FlxTransitionableState.skipNextTransOut = true;
				FlxG.resetState();
				#else
				close();
				#end
			} else {
				close();
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
		} else if (controls.ACCEPT || (isTab && MusicBeatSubstate._virtualpad.buttonA.justPressed)) {
			if (onYes) {
				if (week == -1) {
					Highscore.resetSong(song, difficulty);
				} else {
					Highscore.resetWeek(WeekData.weeksList[week], difficulty);
				}
			}
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			#if android
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
			#else
			close();
			#end
		}
		super.update(elapsed);
	}

	function updateOptions() {
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
		if (week == -1)
			icon.animation.curAnim.curFrame = confirmInt;
	}
}
