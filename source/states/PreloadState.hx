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

using flixel.util.FlxSpriteUtil;

class PreloadState extends MusicBeatState {
    public var loadText:FlxText;
    public static var updateVersion:String = '';
	var mustUpdate:Bool = false;
    private var luaDebugGroup:FlxTypedGroup<FlxText>;
    private var PreloadArt:FlxSprite = new FlxSprite().loadGraphic(Paths.image("Preload/preloaderArt"));
    private var Text0:Alphabet = new Alphabet(0, 0, "WARNING!");
    private var Text:Alphabet = new Alphabet(0, 0, "THE OFFICIAL GAME BY");
    public var camOther:FlxCamera;
    private var GetInfo:Array<Dynamic> = [];
    public static var ISMODED:Bool = false;

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

        Text0.screenCenter();
        Text0.y -= 250;
        Text0.cameras = [camOther];
        add(Text0);

        Text.screenCenter();
        Text.y -= 150;
        Text.cameras = [camOther];
        add(Text);

        PreloadArt.screenCenter();
        PreloadArt.y += 100;
        PreloadArt.scale.x = 0.5;
        PreloadArt.scale.y = 0.5;
        PreloadArt.cameras = [camOther];
        add(PreloadArt);
        trace(lime.app.Application.current.meta);
        GetInfo.push(lime.app.Application.current.meta.get("file"));
        GetInfo.push(lime.app.Application.current.meta.get("packageName"));
        GetInfo.push(lime.app.Application.current.meta.get("company"));
        #if OFFICIAL
        GetInfo.push("OBuildProject");
        #else
        GetInfo.push("lol");
        #end

        for(i in 0...GetInfo.length) {
            if(Main.MainInfos[i] == GetInfo[i]) trace('Done');
            else {
                trace('error!');
                ISMODED = true;
            }
        }

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
        reloadMouseGraphics();
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

        var timer = new haxe.Timer(5000); // 2000ms delay
        timer.run = function() { if (mustUpdate) MusicBeatState.switchState(new OutdatedState());
                                 else FlxG.switchState(new TitleState()); timer.stop(); }
    }

    public static function reloadMouseGraphics() {
        if(ClientPrefs.data.um == 'HaxeFlixel') {
            FlxG.mouse.useSystemCursor = false;
            FlxG.mouse.unload();
        } else if(ClientPrefs.data.um == 'Windows System') {
            FlxG.mouse.useSystemCursor = true;
            FlxG.mouse.unload();
        } else if(ClientPrefs.data.um == 'Custom') {
            var mouse = new FlxSprite();
            mouse.loadGraphic(Paths.image("Preload/cursor"));
            //mouse.drawCircle();

            FlxG.mouse.useSystemCursor = false;
            FlxG.mouse.load(mouse.pixels);
        }
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