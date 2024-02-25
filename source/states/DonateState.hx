package states;

import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxGradient;
import objects.AttachedSprite;

class DonateState extends MusicBeatState {
	var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	var curSelected:Int = -1;
	var intendedColor:FlxColor;
	var colorTween:FlxTween;
	var bg:FlxSprite;
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);

	var donateMenu:Array<Array<String>> = [
		[
		'Funkin URL',
		'https://ninja-muffin24.itch.io/funkin'
		],

		['To Funkin Creater Link', 
		 'https://space.bilibili.com/525583987/dynamic?spm_id_from=444.41.my-info.face.click'
		]
	];

	override public function create() {

		persistentUpdate = true;

		bg = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);
		bg.alpha = 0.5;

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55AE59E4, 0xAA19ECFF], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		var bgGrid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(40, 40, 160, 160, true, 0x11FFFFFF, 0x0));
		bgGrid.alpha = 0.5;
		bgGrid.velocity.set(175, 175);
		add(bgGrid);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for(i in 0...donateMenu.length) {
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 150, donateMenu[i][0], true);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			optionText.screenCenter(X);
			grpOptions.add(optionText);

			if (curSelected == -1)
				curSelected = i;
		}

		#if android
		addVirtualPad(UP_DOWN, A_B);
		#else
		if(ClientPrefs.data.tabletmode)
			addVirtualPad(UP_DOWN, A_B);
		#end

		super.create();
	}

	var holdTime:Float = 0;
	override function update(elapsed:Float) {
		var isTab:Bool = ClientPrefs.data.tabletmode;
		if (FlxG.sound.music.volume < 0.7) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (donateMenu.length > 1) {
			var shiftMult:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftMult = 3;

			var upP = controls.UI_UP_P || (isTab && MusicBeatState._virtualpad.buttonUp.justPressed);
			var downP = controls.UI_DOWN_P || (isTab && MusicBeatState._virtualpad.buttonDown.justPressed);

			if (upP) {
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP) {
				changeSelection(shiftMult);
				holdTime = 0;
			}

			super.update(elapsed);
			
			if (controls.UI_DOWN || controls.UI_UP  || (isTab && MusicBeatState._virtualpad.buttonUp.pressed) || (isTab && MusicBeatState._virtualpad.buttonDown.pressed)) {
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if (holdTime > 0.5 && checkNewHold - checkLastHold > 0) {
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				}
			}
		}
		
		if (controls.BACK || (isTab && MusicBeatState._virtualpad.buttonB.justPressed)) {
			FlxG.sound.play(PathsList.themeSound('cancelMenu'), ClientPrefs.data.soundVolume);
			MusicBeatState.switchState(new MainMenuState());
		}

		if ((controls.ACCEPT || (isTab && MusicBeatState._virtualpad.buttonUp.justPressed)) && (donateMenu[curSelected][1] == null || donateMenu[curSelected][1].length > 4)) {
			CoolUtil.browserLoad(donateMenu[curSelected][1]);
		}
	}

	private function unselectableCheck(num:Int):Bool {
		return donateMenu[num].length <= 1;
	}

	function changeSelection(change:Int = 0) {
		FlxG.sound.play(PathsList.themeSound('scrollMenu'), ClientPrefs.data.soundVolume);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = donateMenu.length - 1;
			if (curSelected >= donateMenu.length)
				curSelected = 0;
		} while (unselectableCheck(curSelected));

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!unselectableCheck(bullShit - 1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}
	}
}
