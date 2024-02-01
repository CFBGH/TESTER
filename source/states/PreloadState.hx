package states;

import backend.Highscore;
import backend.WeekData;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import lime.app.Application;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import shaders.ColorSwap;
import states.TitleState;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
#if LUA_ALLOWED
import psychlua.*;
#else
import psychlua.FunkinLua;
import psychlua.HScript;
import psychlua.LuaUtils;
#end
#if (SScript >= "3.0.0")
import tea.SScript;
#end

class PreloadState extends MusicBeatState {
    public var loadText:FlxText;
    public static var updateVersion:String = '';
	var mustUpdate:Bool = false;
    private var luaDebugGroup:FlxTypedGroup<FlxText>;
    public var camOther:FlxCamera;
    private var GetInfo:Array<Dynamic> = [];
    private var ISMODED:Bool = false;
    #if ANDCHUCK
    public static var listDir:Array<String> = [];
    #end

    override public function create():Void {
        super.create();
        FlxG.save.bind('funkin', CoolUtil.getSavePath());
		ClientPrefs.loadPrefs();
		Language.init();
        trace(ClientPrefs.data.usingfont);

        camOther = new FlxCamera();
        camOther.bgColor.alpha = 0;
        FlxG.cameras.add(camOther, false);
        luaDebugGroup = new FlxTypedGroup<FlxText>();
	    luaDebugGroup.cameras = [camOther];
	    add(luaDebugGroup);
       
        GetInfo.push(lime.app.Application.current.meta.get('file'));
        GetInfo.push(lime.app.Application.current.meta.get('packageName'));
        GetInfo.push(lime.app.Application.current.meta.get('company'));
        GetInfo.push(lime.app.Application.current.meta.get('build'));
        for(i in 0...GetInfo.length) {
            if(Main.MainInfos[i] == GetInfo[i]) trace('Done');
            else trace('error!');
        }

	#if android
	FlxG.android.preventDefaultKeys = [BACK];
	removeVirtualPad();
	noCheckPress();
	#end

        #if ANDCHUCK
        listDir = FileSystem.readDirectory('./');
        trace(listDir);
        #end

        if (!sys.FileSystem.exists(Sys.getCwd() + "/assets/replays")) {
			sys.FileSystem.createDirectory(Sys.getCwd() + "/assets/replays");
            addText(language.States.Preload.text0);
        }

        addText(language.States.Preload.text1);

        #if LUA_ALLOWED
        addText(language.States.Preload.text2);
		Mods.pushGlobalMods();
		#end
        addText(language.States.Preload.text3);
		Mods.loadTopMod();

        addText(language.States.Preload.text4);
        FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];
        var any:String = ClientPrefs.data.resolution;
        var any0:Array<String> = any.split('x');
        trace(any0);
        #if desktop
        if(!ClientPrefs.data.fullscr) FlxG.resizeWindow(Std.parseInt(any0[0]), Std.parseInt(any0[1]));
        #end
        FlxG.resizeGame(Std.parseInt(any0[0]), Std.parseInt(any0[1]));

        FlxG.fullscreen = ClientPrefs.data.fullscr;

		FlxG.mouse.useSystemCursor = ClientPrefs.data.um;
        var timer2 = new haxe.Timer(2000);
        timer2.run = function() { addText(language.States.Preload.text5);

		lime.app.Application.current.window.title = lime.app.Application.current.meta.get('name');

        addText(language.States.Preload.text6);
		Highscore.load();

        if (FlxG.save.data.weekCompleted != null) {
			addText(language.States.Preload.text7);
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

        addText(language.States.Preload.text8);
        #if CHECK_FOR_UPDATES
		if(ClientPrefs.data.checkForUpdates) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/gitVersion.txt");

			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function (error) {
				trace('error: $error');
			}

			http.request();
		}
		#end
        timer2.stop();}

        var timer = new haxe.Timer(2000); // 2000ms delay
        timer.run = function() { if (mustUpdate) MusicBeatState.switchState(new OutdatedState());
                                 else FlxG.switchState(new TitleState()); timer.stop(); }
    }

    public function addText(text:String, ?color:FlxColor = FlxColor.WHITE) {
        var loadText:FlxText = luaDebugGroup.recycle(FlxText);
        loadText.setFormat(Language.fonts(), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        loadText.text = text;
        loadText.color = color;
        //loadText.disableTime = 6;
        loadText.alpha = 1;
        loadText.setPosition(10, 710/* + loadText.height*/);

        luaDebugGroup.forEachAlive(function(spr:FlxText) {
			spr.y -= loadText.height + 2;
		});
		luaDebugGroup.add(loadText);
    }
}
