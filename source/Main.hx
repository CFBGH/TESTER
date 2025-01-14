package;

import debug.FPSCounter;

import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;

import flixel.graphics.FlxGraphic;
import flixel.FlxGame;
import flixel.FlxState;
import haxe.io.Path;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;

import states.PreloadState;

#if linux
import lime.graphics.Image;
#end

//crash handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#end

#if linux
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end

class Main extends Sprite
{
	var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: PreloadState, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: false, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var MainInfos:Array<String> = [
		'ToFunkinEngine',
		'com.comesfromback.tofunkinengine',
		'Comes_FromBack',
		#if OFFICIAL
		'OBuildProject'
		#else
		'NotBuildProject'
		#end
	];

	public static var BETA_Version = '(BETA 20240205_072h-07 Part:2/4)';
	public static var MAIN_Version = 'To Funkin Engine v1.0';
	public static var fpsVar:FPSCounter;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		// Credits to MAJigsaw77 (he's the og author for this code)
		#if ios
		Sys.setCwd(lime.system.System.applicationStorageDirectory);
		#end

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}
		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		if (MainInfos.length < 4) MainInfos.push(#if OFFICIAL 'OBuildProject'#else'NotBuildProject'#end);
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end
		addChild(new FlxGame(game.width, game.height, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, false, game.startFullscreen));

		#if !mobile
		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.data.showFPS;
		}
		#end

		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		// shader coords fix
		FlxG.signals.gameResized.add(function (w, h) {
		     if (FlxG.cameras != null) {
			   for (cam in FlxG.cameras.list) {
				@:privateAccess
				if (cam != null && cam._filters != null)
					resetSpriteCache(cam.flashSprite);
			   }
		     }

		     if (FlxG.game != null)
			 resetSpriteCache(FlxG.game);
		});
	}

	static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
		        sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var errcode = e.error;
		var printError:String = '';
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();
		var	appName:String = Application.current.meta.get('file')+".exe";
		var parentPath = Sys.programPath().substr(0, Sys.programPath().length-appName.length);
    	var cmd = "cd/D "+parentPath+" && HaxeflixelCrashHandler.exe -"+errcode+" -"+parentPath+" -"+appName;

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");
		path = "./crash/" + "ToFunkinEngine_" + dateNow + ".txt";

		if(!ClientPrefs.data.acrash) {
			for (stackItem in callStack)
			{
				switch (stackItem)
				{
					case FilePos(s, file, line, column):
						errMsg += file + " (line " + line + ")\n";
					default:
						Sys.println(stackItem);
				}
			}

			errMsg += "\nUncaught Error: " + errcode + "\nPlease report this error to the GitHub page: https://github.com/ShadowMario/FNF-PsychEngine\n\n> Crash Handler written by: sqirra-rng";

			Sys.println(errMsg);
			Sys.println("Crash dump saved in " + Path.normalize(path));

			Application.current.window.alert(errMsg, "Error!");
			Sys.exit(1);
		} else {
			for (stackItem in callStack) {
				switch (stackItem) {
					case FilePos(s, file, line, column):
						printError += file + " (line " + line + ")\n";
					default:
						Sys.println(stackItem);
				}
			}

			cmd = "cd/D "+parentPath+" && HaxeflixelCrashHandler.exe -"+printError+" -"+parentPath+" -"+appName;

			Sys.command(cmd);
			Sys.exit(1);
		}

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");
	}
	#end
}
