package backend;

import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.mappings.FlxGamepadMapping;
import flixel.input.keyboard.FlxKey;

//import flixel.input.actions.FlxActionInput;
import android.AndroidControls.AndroidControls;
//import android.FlxVirtualPad;

import flixel.group.FlxGroup;
import android.FlxHitbox;
import android.FlxNewHitbox;
import android.FlxVirtualPad;
import flixel.ui.FlxButton;
import android.flixel.FlxButton as FlxNewButton;

class Controls
{
	//Keeping same use cases on stuff for it to be easier to understand/use
	//I'd have removed it but this makes it a lot less annoying to use in my opinion

	//You do NOT have to create these variables/getters for adding new keys,
	//but you will instead have to use:
	//   controls.justPressed("ui_up")   instead of   controls.UI_UP
	
	/*
	android control make by NF|beihu ,logic is very shit but its easy to understand
    */
	//Dumb but easily usable code, or Smart but complicated? Your choice.
	//Also idk how to use macros they're weird as fuck lol

	// Pressed buttons (directions)
	public var UI_UP_P(get, never):Bool;
	public var UI_DOWN_P(get, never):Bool;
	public var UI_LEFT_P(get, never):Bool;
	public var UI_RIGHT_P(get, never):Bool;
	public var NOTE_UP_P(get, never):Bool;
	public var NOTE_DOWN_P(get, never):Bool;
	public var NOTE_LEFT_P(get, never):Bool;
	public var NOTE_RIGHT_P(get, never):Bool;
	public var SPACE_P(get, never):Bool;
	//public var SHIFT_P(get, never):Bool;
	private function get_UI_UP_P() return justPressed('ui_up');
	private function get_UI_DOWN_P() return justPressed('ui_down');
	private function get_UI_LEFT_P() return justPressed('ui_left');
	private function get_UI_RIGHT_P() return justPressed('ui_right');
	private function get_NOTE_UP_P() return justPressed('note_up') || MusicBeatState._virtualpad.buttonUp.justPressed;
	private function get_NOTE_DOWN_P() return justPressed('note_down') || MusicBeatState._virtualpad.buttonDown.justPressed;
	private function get_NOTE_LEFT_P() return justPressed('note_left') || MusicBeatState._virtualpad.buttonLeft.justPressed;
	private function get_NOTE_RIGHT_P() return justPressed('note_right') || MusicBeatState._virtualpad.buttonRight.justPressed;
    private function get_SPACE_P() return justPressed('space');
    
	// Held buttons (directions)
	public var UI_UP(get, never):Bool;
	public var UI_DOWN(get, never):Bool;
	public var UI_LEFT(get, never):Bool;
	public var UI_RIGHT(get, never):Bool;
	public var NOTE_UP(get, never):Bool;
	public var NOTE_DOWN(get, never):Bool;
	public var NOTE_LEFT(get, never):Bool;
	public var NOTE_RIGHT(get, never):Bool;
	public var SPACE(get, never):Bool;
	//public var SHIFT(get, never):Bool;
	private function get_UI_UP() return pressed('ui_up');
	private function get_UI_DOWN() return pressed('ui_down');
	private function get_UI_LEFT() return pressed('ui_left');
	private function get_UI_RIGHT() return pressed('ui_right');
	private function get_NOTE_UP() return pressed('note_up') || MusicBeatState._virtualpad.buttonUp.pressed;
	private function get_NOTE_DOWN() return pressed('note_down') || MusicBeatState._virtualpad.buttonDown.pressed;
	private function get_NOTE_LEFT() return pressed('note_left') || MusicBeatState._virtualpad.buttonLeft.pressed;
	private function get_NOTE_RIGHT() return pressed('note_right') || MusicBeatState._virtualpad.buttonRight.pressed;
    private function get_SPACE() return pressed('space');
    
	// Released buttons (directions)
	public var UI_UP_R(get, never):Bool;
	public var UI_DOWN_R(get, never):Bool;
	public var UI_LEFT_R(get, never):Bool;
	public var UI_RIGHT_R(get, never):Bool;
	public var NOTE_UP_R(get, never):Bool;
	public var NOTE_DOWN_R(get, never):Bool;
	public var NOTE_LEFT_R(get, never):Bool;
	public var NOTE_RIGHT_R(get, never):Bool;
	public var SPACE_R(get, never):Bool;
	//public var SHIFT_R(get, never):Bool;
	private function get_UI_UP_R() return justReleased('ui_up');
	private function get_UI_DOWN_R() return justReleased('ui_down');
	private function get_UI_LEFT_R() return justReleased('ui_left');
	private function get_UI_RIGHT_R() return justReleased('ui_right');
	private function get_NOTE_UP_R() return justReleased('note_up') || MusicBeatState._virtualpad.buttonUp.justReleased;
	private function get_NOTE_DOWN_R() return justReleased('note_down') || MusicBeatState._virtualpad.buttonDown.justReleased;
	private function get_NOTE_LEFT_R() return justReleased('note_left') || MusicBeatState._virtualpad.buttonLeft.justReleased;
	private function get_NOTE_RIGHT_R() return justReleased('note_right') || MusicBeatState._virtualpad.buttonRight.justReleased;
	private function get_SPACE_R() return justReleased('space');


	// Pressed buttons (others)
	public var ACCEPT(get, never):Bool;
	public var BACK(get, never):Bool;
	public var PAUSE(get, never):Bool;
	public var RESET(get, never):Bool;
	private function get_ACCEPT() return justPressed('accept');
	private function get_BACK() return justPressed('back');
	private function get_PAUSE() return justPressed('pause');
	private function get_RESET() return justPressed('reset');
	
	//Gamepad & Keyboard stuff
	public var keyboardBinds:Map<String, Array<FlxKey>>;
	public var gamepadBinds:Map<String, Array<FlxGamepadInputID>>;

	public static var checkState:Bool = true;
	public static var CheckPress:Bool = true;
    public static var CheckControl:Bool = true;
    public static var CheckKeyboard:Bool = false;
	public function justPressed(key:String)
	{
		
		var result:Bool = false;		
		
		if (FlxG.keys.anyJustPressed(keyboardBinds[key])){
		result = true;
		controllerMode = false;
		}

		return result || _myGamepadJustPressed(gamepadBinds[key]) == true;
	}

	public function pressed(key:String)
	{		
		
		var result:Bool = false;
		
		
		
		if (FlxG.keys.anyPressed(keyboardBinds[key])){
		result = true;
		controllerMode = false;
		}

		return result || _myGamepadPressed(gamepadBinds[key]) == true;
	}

	public function justReleased(key:String)
	{
		
		var result:Bool = false;
		
		
		
		if (FlxG.keys.anyJustReleased(keyboardBinds[key])){
		result = true;
		controllerMode = false;
		}

		return result || _myGamepadJustReleased(gamepadBinds[key]) == true;
	}

	public var controllerMode:Bool = false;
	private function _myGamepadJustPressed(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyJustPressed(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}
	private function _myGamepadPressed(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyPressed(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}
	private function _myGamepadJustReleased(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyJustReleased(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}
	
    
	// IGNORE THESE
	public static var instance:Controls;
	public function new()
	{
		keyboardBinds = ClientPrefs.keyBinds;
		gamepadBinds = ClientPrefs.gamepadBinds;
	}
}