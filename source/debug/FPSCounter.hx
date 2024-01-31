package debug;

import flixel.FlxG;
import Main;
import Sys;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class FPSCounter extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	/**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var memoryMegas(get, never):Float;
	public var memp:Float;
	public var ft:Float;

	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 13, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		times = [];
	}

	var deltaTimeout:Float = 0.0;

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void
	{
		if (memp < memoryMegas) memp = memoryMegas;
		if (deltaTimeout > 1000) {
			deltaTimeout = 0.0;
			return;
		}

		var now:Float = haxe.Timer.stamp();
		times.push(now);
		while (times[0] < now - 1000)
			times.shift();

		currentFPS = currentFPS < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;		
		updateText();
		deltaTimeout += deltaTime;
	}

	public dynamic function updateText():Void { // so people can override it in hscript
		ft = FlxMath.roundDecimal(1000 / currentFPS, 1);
		text = 'FPS: $currentFPS / ${ClientPrefs.data.framerate}'
		+ '\nMemory: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}'
		+ '\nMemory Peak: ${flixel.util.FlxStringUtil.formatBytes(memp)}'
		+ '\nFrame Time: $ft MS'
		+ '\n${Main.MAIN_Version}${#if BETA Main.BETA_Version #end}';

		if(ClientPrefs.debug.debugMode/* && ClientPrefs.data.debugText*/) {
			text += '\nSYSTEM: ${Sys.systemName()}';
		}

		defaultTextFormat.font = 'assets/fonts/language/${ClientPrefs.data.language}/${ClientPrefs.data.usingfont}';

		textColor = 0xFFFFFFFF;
		if (currentFPS < FlxG.drawFramerate * 0.5)
			textColor = 0xFFFF0000;
	}

	inline function get_memoryMegas():Float return cast(System.totalMemory, UInt);
}
