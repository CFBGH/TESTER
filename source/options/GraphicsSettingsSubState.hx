package options;

import flixel.graphics.FlxGraphic;
import objects.Character;
import lib.Resolution;

class GraphicsSettingsSubState extends BaseOptionsMenu {
	var antialiasingOption:Int;
	var boyfriend:Character = null;

	public function new() {
		title = 'Graphics';
		rpcTitle = 'Graphics Settings Menu'; // for Discord Rich Presence

		boyfriend = new Character(840, 170, 'bf', true);
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
		boyfriend.updateHitbox();
		boyfriend.dance();
		boyfriend.animation.finishCallback = function(name:String) boyfriend.dance();
		boyfriend.visible = false;

		// I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', // Name
		language.States.options.grap.opt1, // Description
			'lowQuality', // Save data variable name
			'bool'); // Variable type
		addOption(option);

		var option:Option = new Option('Anti-Aliasing', language.States.options.grap.opt2,
			'antialiasing', 'bool');
		option.onChange = onChangeAntiAliasing; // Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);
		antialiasingOption = optionsArray.length - 1;

		var option:Option = new Option('Shaders', // Name
		language.States.options.grap.opt3, // Description
			'shaders', 'bool');
		addOption(option);

		var option:Option = new Option('FullScreen', // Name
		language.States.options.grap.opt8, // Description
			'fullscr', 'bool');
		addOption(option);
		option.onChange = onChangeFullScreen;

		var option:Option = new Option("RainbowFPS", // Name
		language.States.options.grap.opt4, "rainbowFPS", 'bool');
		addOption(option);

		var option:Option = new Option('GPU Caching', // Name
		language.States.options.grap.opt5, // Description
			'cacheOnGPU', 'bool');
		addOption(option);

		#if !html5 // Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option('Framerate', language.States.options.grap.opt6, 'framerate', 'int');
		addOption(option);
		option.minValue = 30;
		option.maxValue = 320;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		var option:Option = new Option('Resolution', language.States.options.grap.opt6, 'resolution', 'string',
		['1920x1080', '1600x900','1366x768','1280x720', '1024x576', '960x540', '854x480', '720x405', '640x360', '480x270', '320x180', '160x90', '80x45']);
		addOption(option);
		option.onChange = onChangeResolution;

		var option:Option = new Option('Persistent Cached Data',
		language.States.options.grap.opt7,
			'imagesPersist', 'bool');
		option.onChange = onChangePersistentData; // Persistent Cached Data changes FlxGraphic.defaultPersist
		addOption(option);

		super();
		insert(1, boyfriend);
	}

	function onChangeAntiAliasing() {
		for (sprite in members) {
			var sprite:FlxSprite = cast sprite;
			if (sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.data.antialiasing;
			}
		}
	}

	function onChangeFramerate() {
		if (ClientPrefs.data.framerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		} else {
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}
	}

	override function changeSelection(change:Int = 0) {
		super.changeSelection(change);
		boyfriend.visible = (antialiasingOption == curSelected);
	}

	function onChangePersistentData() {
		FlxGraphic.defaultPersist = ClientPrefs.data.imagesPersist;
	}

	function onChangeFullScreen() {
		ClientPrefs.saveSettings();
		FlxG.fullscreen = ClientPrefs.data.fullscr;
	}

	function onChangeResolution() {
		ClientPrefs.saveSettings();
		Resolution.change(ClientPrefs.data.resolution);	
	}
}
