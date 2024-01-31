package substates;

import sys.io.File;
import sys.FileSystem;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import states.MenuModifiers;
import states.MenuMarathon;
import states.MenuSurvival;

using StringTools;

class Substate_PresetSaveOK extends MusicBeatSubstate
{
	public static var curSelected:Int = 0;

	var goingBack:Bool = false;

	var camLerp:Float = 0.16;

	var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 1, FlxColor.BLACK);

	var resultText:FlxText;

	var resultName:FlxText;
	var eggText:String = "";

	var eggImage:FlxSprite;

	public function new()
	{
		super();

		add(blackBarThingie);
		blackBarThingie.scrollFactor.set();
		blackBarThingie.scale.y = 750;

		resultText = new FlxText(FlxG.width * 0.7, 5, 1000, "Is this okay?", 32);
		resultText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		resultText.alignment = CENTER;
		resultText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		resultText.screenCenter(X);
		resultText.y = 38;
		resultText.scrollFactor.set();
		add(resultText);

		resultName = new FlxText(FlxG.width * 0.7, 5, 1280, Substate_PresetSave.nameResult, 96);
		resultName.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, RIGHT);
		resultName.alignment = CENTER;
		resultName.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		resultName.screenCenter();
		resultName.y += 35;
		resultName.scrollFactor.set();
		add(resultName);

		eggText = resultName.text.toLowerCase();

		if (eggText.contains('<') || eggText.contains('>') || eggText.contains('*') || eggText.contains('?') || eggText.contains('/')
			|| eggText.contains(':') || eggText.contains('"'))
		{
			#if windows
			canOK = false;
			resultText.text = "Please refrain from using *, ?, |, slashes, arrow parenthesis, : and double quotes as you can't name filenames like that.";
			#end
		}

		switch (eggText)
		{
			case 'con' | 'prn' | 'aux' | 'nul' | 'com1' | 'com2' | 'com3' | 'com4' | 'com5' | 'com6' | 'com7' | 'com8' | 'com9' | 'lpt1' | 'lpt2' | 'lpt3' |
				'lpt4' | 'lpt5' | 'lpt6' | 'lpt7' | 'lpt8' | 'lpt9': // what a backdoor
				#if windows
				canOK = false;
				resultText.text = "It is illegal to make a filename like that based on a device's name. Try thinking of something else.";
				#end
			case 'current':
				canOK = false;
				resultText.text = "Don't replace what saves on your way. It'll autosave itself.";
			default:
		}
		{
			FlxTween.tween(resultName, {size: 64, y: 280}, 0.2, {ease: FlxEase.backOut});
		}

		new FlxTimer().start(0.25, function(tmr:FlxTimer)
		{
			selectable = true;
		});
	}

	var selectable:Bool = false;
	var canOK:Bool = true;
	var easterImage:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		blackBarThingie.y = 360 - blackBarThingie.height / 2;
		blackBarThingie.x = 640 - blackBarThingie.width / 2;

		if (selectable && !goingBack)
		{
			if (controls.BACK)
			{
				FlxG.state.closeSubState();
				FlxG.state.openSubState(new Substate_PresetSave());
			}

			if (controls.ACCEPT && canOK)
			{
				switch (Substate_PresetSave.coming)
				{
					case "Modifiers":
						ModifierVariables.savePreset(eggText);
					case "Marathon":
						MenuMarathon.savePreset(eggText);
					case "Survival":
						MenuSurvival.savePreset(eggText);
				}

				goingBack = true;

				FlxTween.tween(blackBarThingie, {'scale.x': 0}, 0.5, {ease: FlxEase.expoIn});
				FlxTween.tween(resultText, {'scale.x': 0}, 0.5, {ease: FlxEase.expoIn});
				FlxTween.tween(resultName, {'scale.x': 0}, 0.5, {ease: FlxEase.expoIn});
				if (easterImage)
					FlxTween.tween(eggImage, {'scale.x': 0}, 0.5, {ease: FlxEase.expoIn});

				FlxG.sound.play(Paths.sound('confirmMenu'));
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					FlxG.state.closeSubState();
					switch (Substate_PresetSave.coming)
					{
						case "Modifiers":
							FlxG.state.openSubState(new Substate_Preset());
						case "Marathon":
							FlxG.state.openSubState(new Marathon_Substate());
						case "Survival":
							FlxG.state.openSubState(new Survival_Substate());
					}
				});
			}
		}
	}
}
