package options;

import states.MainMenuState;
import backend.StageData;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Note Colors', 'Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay', 'Extra Setting'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var onPlayState:Bool = false;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay and Combo':
				MusicBeatState.switchState(new options.NoteOffsetState());
			case 'Extra Setting':
				openSubState(new options.ExtraSettingsSubState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create() {
		Language.init();
		if(ClientPrefs.data.tabletmode) ClientPrefs.debug.tab = true; else ClientPrefs.debug.tab = false; 

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		#if android
		addVirtualPad(UP_DOWN, A_B_E);
		#else
		if(ClientPrefs.data.tabletmode)
			addVirtualPad(UP_DOWN, A_B_E);
		#end

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		var isTab:Bool = ClientPrefs.debug.tab;
		super.update(elapsed);

		if (controls.UI_UP_P || (isTab && MusicBeatState._virtualpad.buttonUp.justPressed))
			changeSelection(-1);
		if (controls.UI_DOWN_P || (isTab && MusicBeatState._virtualpad.buttonDown.justPressed))
			changeSelection(1);

		if(FlxG.mouse.wheel != 0)
			changeSelection(-FlxG.mouse.wheel);

		if(!ClientPrefs.debug.debugMode) {
			if(FlxG.keys.justPressed.D && FlxG.keys.justPressed.B) {
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxG.camera.flash(0x00FF00, 0.4, null, true);
				trace('Debug Mode is ON!');
				ClientPrefs.debug.debugMode = true;
				ClientPrefs.saveSettings();
			}
		} else {
			if(FlxG.keys.justPressed.R && FlxG.keys.justPressed.D) {
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxG.camera.flash(0xFFFF0000, 0.4, null, true);
				trace('Debug Mode is OFF!');
				ClientPrefs.debug.debugMode = false;
				ClientPrefs.saveSettings();
			}
		}

		if((isTab && MusicBeatState._virtualpad.buttonE.justPressed) || (ClientPrefs.debug.debugMode && FlxG.keys.justPressed.A))
			MusicBeatState.switchState(new options.AndroidControlsMenu());

		/*if(ClientPrefs.debug.debugMode && FlxG.keys.justPressed.M)
			MusicBeatState.switchState(new ModSettingsSubState());*/

		if (controls.BACK || (isTab && MusicBeatState._virtualpad.buttonB.justPressed) || FlxG.mouse.justPressedRight) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if(onPlayState)
			{
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else MusicBeatState.switchState(new MainMenuState());
		}
		else if (controls.ACCEPT || (isTab && MusicBeatState._virtualpad.buttonA.justPressed) || FlxG.mouse.justPressed) openSelectedSubstate(options[curSelected]);
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}