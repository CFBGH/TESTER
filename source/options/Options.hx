package options;

import flixel.FlxSubState;

typedef FadeOpti = {
	styles:Array<String>
}

class Options {
	public function new() {display = updateDisplay();}

	private var description:String = "";
	private var display:String;
	private var State:String;
	private var openingState:Bool = false;
	private var acceptValues:Bool = false;
	public var acceptType:Bool = false;
	public var waitingType:Bool = false;
	private var color:Int = 0xFFFFFFFF;
	private var enable:Bool = true;

	public final function getDisplay():String {return display;}
	public final function getAccept():Bool {return acceptValues;}
	public final function getDescription():String {return description;}
	public final function getOpenState():String{return State;}
	public final function getOpeningState():Bool{return openingState;}
	public final function getColor():Int{return color;}
	public final function onEnable():Bool{return enable;}
	public function getValue():String {return updateDisplay();};
	public function onType(text:String) {}
	// Returns whether the label is to be updated.
	public function press():Bool {ClientPrefs.saveSettings(); return true;}
	private function updateDisplay():String {return "";}
	public function left():Bool {ClientPrefs.saveSettings(); return false;}
	public function right():Bool {ClientPrefs.saveSettings(); return false;}
}

class Placeholders extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Placeholders';}
}

class NotDebug extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'This Setting Only For Debuging Mode Using';}
}

class Downscroll extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.downScroll) ClientPrefs.data.downScroll = false;
		else ClientPrefs.data.downScroll = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Downscroll: [ ${ClientPrefs.data.downScroll ? "ENABLE" : "DISABLE"} ]';}
}

class Middlescroll extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.middleScroll) ClientPrefs.data.middleScroll = false;
		else ClientPrefs.data.middleScroll = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Middlescroll: [ ${ClientPrefs.data.middleScroll ? "ENABLE" : "DISABLE"} ]';}
}

class Voices extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.haveVoices) ClientPrefs.data.haveVoices = false;
		else ClientPrefs.data.haveVoices = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Voices: [ ${ClientPrefs.data.haveVoices ? "ENABLE" : "DISABLE"} ]';}
}

class OpponentNotes extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.opponentStrums) ClientPrefs.data.opponentStrums = false;
		else ClientPrefs.data.opponentStrums = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Opponent Notes: [ ${ClientPrefs.data.opponentStrums ? "ENABLE" : "DISABLE"} ]';}
}

class GhostTapping extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.ghostTapping) ClientPrefs.data.ghostTapping = false;
		else ClientPrefs.data.ghostTapping = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Ghost Tapping: [ ${ClientPrefs.data.ghostTapping ? "ENABLE" : "DISABLE"} ]';}
}

class AutoPause extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.autoPause) {
			ClientPrefs.data.autoPause = false;
			FlxG.autoPause = false;
		} else {
			ClientPrefs.data.autoPause = true;
			FlxG.autoPause = true;
		}
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Auto Pause: [ ${ClientPrefs.data.autoPause ? "ENABLE" : "DISABLE"} ]';}
}

class DisableResetButton extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.noReset) ClientPrefs.data.noReset = false;
		else ClientPrefs.data.noReset = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Disable Reset Button: [ ${ClientPrefs.data.noReset ? "ENABLE" : "DISABLE"} ]';}
}

class LanguageChange extends Options {
	var curSelected:Int = 0;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(curSelected <= 0) curSelected = Language.langualist.length-1;
		else curSelected--;
		ClientPrefs.data.language = Language.langualist[curSelected];
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(curSelected >= Language.langualist.length-1) curSelected = 0;
		else curSelected++;
		ClientPrefs.data.language = Language.langualist[curSelected];
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Change Language: <[Last] ${Language.langualist[curSelected]} [Next]>';}
}

class FontsChange extends Options {
	var curSelected:Int = 0;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(curSelected <= 0) curSelected = Language.fonlist.length-1;
		else curSelected--;
		ClientPrefs.data.usingfont = Language.fonlist[curSelected];
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(curSelected >= Language.fonlist.length-1) curSelected = 0;
		else curSelected++;
		ClientPrefs.data.usingfont = Language.fonlist[curSelected];
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Change Fonts: <[Last] ${ClientPrefs.data.usingfont} [Next]>';}
}

class AllowedChangesFont extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.languagefonts) ClientPrefs.data.languagefonts = false;
		else ClientPrefs.data.languagefonts = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Allowed Changes Font: [ ${ClientPrefs.data.languagefonts ? "ENABLE" : "DISABLE"} ]';}
}

class HitsoundChange extends Options {
	var curSelected:Int = 0;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(curSelected <= 0) curSelected = PathsList.hitsoundList().length-1;
		else curSelected--;
		ClientPrefs.data.hitsound = PathsList.hitsoundList()[curSelected];
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(curSelected >= PathsList.hitsoundList().length-1) curSelected = 0;
		else curSelected++;
		ClientPrefs.data.hitsound = PathsList.hitsoundList()[curSelected];
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Hitsound Choose: <[Last] ${ClientPrefs.data.hitsound}.ogg [Next]>';}
}

class ThemesoundChange extends Options {
	var curSelected:Int = 0;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		trace(PathsList.soundThemeList().length);
		trace(PathsList.soundThemeList());
		if(curSelected <= 0) curSelected = PathsList.soundThemeList().length-1;
		else curSelected--;
		ClientPrefs.data.southeme = PathsList.soundThemeList()[curSelected];
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(curSelected >= PathsList.soundThemeList().length-1) curSelected = 0;
		else curSelected++;
		ClientPrefs.data.southeme = PathsList.soundThemeList()[curSelected];
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Theme Sounds: <[Last] ${ClientPrefs.data.southeme} [Next]>';}
}

class SoundVolume extends Options {
	var volume:Float = ClientPrefs.data.soundVolume;
	var displayvol:Float;
	public function new(desc:String) {
		super();
		displayvol = volume*100;
		description = desc;
	}

	public override function left():Bool {
		if(volume <= 0) volume = 0;
		else volume -= 0.01;
		ClientPrefs.data.soundVolume = volume;
		displayvol = volume*100;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(volume >= 1) volume = 1;
		else volume += 0.01;
		displayvol = volume*100;
		ClientPrefs.data.soundVolume = volume;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Sounds Volume: [-] $displayvol% / 100% [+]';}
}

class MusicVolume extends Options {
	var volume:Float = ClientPrefs.data.musicVolume;
	var displayvol:Float;
	public function new(desc:String) {
		super();
		displayvol = volume*100;
		description = desc;
	}

	public override function left():Bool {
		if(volume <= 0) volume = 0;
		else volume -= 0.01;
		ClientPrefs.data.musicVolume = volume;
		displayvol = volume*100;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(volume >= 1) volume = 1;
		else volume += 0.01;
		displayvol = volume*100;
		ClientPrefs.data.musicVolume = volume;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Music Volume: [-] $displayvol% / 100% [+]';}
}

class RatingOffset extends Options {
	var value:Int = ClientPrefs.data.ratingOffset;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= -30) value = -30;
		else value--;
		ClientPrefs.data.ratingOffset = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 30) value = 30;
		else value++;
		ClientPrefs.data.ratingOffset = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {
		if (value >= 0) return 'Rating Offset: [-] ${ClientPrefs.data.ratingOffset} / 30 [+]';
		else if (value < 0) return 'Rating Offset: [-] ${ClientPrefs.data.ratingOffset} / -30 [+]';
		return '';
	}
}

class SickOffset extends Options {
	var value:Int = ClientPrefs.data.sickWindow;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= 15) value = 15;
		else value--;
		ClientPrefs.data.sickWindow = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 45) value = 45;
		else value++;
		ClientPrefs.data.sickWindow = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return '"Sick!" Hit Window: [-] ${ClientPrefs.data.sickWindow} / 45 [+]';}
}

class GoodOffset extends Options {
	var value:Int = ClientPrefs.data.goodWindow;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= 15) value = 15;
		else value--;
		ClientPrefs.data.goodWindow = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 90) value = 90;
		else value++;
		ClientPrefs.data.goodWindow = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return '"Good!" Hit Window: [-] ${ClientPrefs.data.goodWindow} / 90 [+]';}
}

class BadOffset extends Options {
	var value:Int = ClientPrefs.data.badWindow;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= 15) value = 15;
		else value--;
		ClientPrefs.data.badWindow = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 135) value = 135;
		else value++;
		ClientPrefs.data.badWindow = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return '"Bad" Hit Window: [-] ${ClientPrefs.data.badWindow} / 135 [+]';}
}

class SafeFrames extends Options {
	var value:Float = ClientPrefs.data.safeFrames;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= 2) value = 2;
		else value -= 0.1;
		ClientPrefs.data.safeFrames = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 10) value = 10;
		else value += 0.1;
		ClientPrefs.data.safeFrames = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Safe Frames: [-] ${ClientPrefs.data.safeFrames} / 10 [+]';}
}

//Graphics

class LowQuality extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.lowQuality) ClientPrefs.data.lowQuality = false;
		else ClientPrefs.data.lowQuality = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Low Quality: [ ${ClientPrefs.data.lowQuality ? "ENABLE" : "DISABLE"} ]';}
}

class AntiAliasing extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.antialiasing) ClientPrefs.data.antialiasing = false;
		else ClientPrefs.data.antialiasing = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Anti-Aliasing: [ ${ClientPrefs.data.antialiasing ? "ENABLE" : "DISABLE"} ]';}
}

class Shaders extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.shaders) ClientPrefs.data.shaders = false;
		else ClientPrefs.data.shaders = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Shaders: [ ${ClientPrefs.data.shaders ? "ENABLE" : "DISABLE"} ]';}
}

class GPUCache extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.cacheOnGPU) ClientPrefs.data.cacheOnGPU = false;
		else ClientPrefs.data.cacheOnGPU = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'GPUCache: [ ${ClientPrefs.data.cacheOnGPU ? "ENABLE" : "DISABLE"} ]';}
}

class PersistentCachedData extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.imagesPersist) ClientPrefs.data.imagesPersist = false;
		else ClientPrefs.data.imagesPersist = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Persistent Cached Data: [ ${ClientPrefs.data.imagesPersist ? "ENABLE" : "DISABLE"} ]';}
}

class FullScreen extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.fullscr) ClientPrefs.data.fullscr = false;
		else ClientPrefs.data.fullscr = true;
		FlxG.fullscreen = ClientPrefs.data.fullscr;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Fullscreen: [ ${ClientPrefs.data.fullscr ? "ENABLE" : "DISABLE"} ]';}
}

class Resolution extends Options {
	var curSelected:Int = 0;
	var rl:Array<String> = [];
	public function new(desc:String) {
		super();
		description = desc;
		rl = ['1920x1080', '1600x900','1366x768','1280x720', '1024x576', '960x540', '854x480', '720x405', '640x360', '480x270', '320x180', '160x90', '80x45'];
	}

	public override function left():Bool {
		if(curSelected >= rl.length-1) curSelected = 0;
		else curSelected++;
		ClientPrefs.data.resolution = rl[curSelected];
		ClientPrefs.saveSettings();
		var any:String = ClientPrefs.data.resolution;
        var any0:Array<String> = any.split('x');
		#if desktop
        if(!ClientPrefs.data.fullscr) FlxG.resizeWindow(Std.parseInt(any0[0]), Std.parseInt(any0[1]));
        #end
        FlxG.resizeGame(Std.parseInt(any0[0]), Std.parseInt(any0[1]));
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(curSelected <= 0) curSelected = rl.length-1;
		else curSelected--;
		ClientPrefs.data.resolution = rl[curSelected];
		ClientPrefs.saveSettings();
		var any:String = ClientPrefs.data.resolution;
        var any0:Array<String> = any.split('x');
		#if desktop
        if(!ClientPrefs.data.fullscr) FlxG.resizeWindow(Std.parseInt(any0[0]), Std.parseInt(any0[1]));
        #end
        FlxG.resizeGame(Std.parseInt(any0[0]), Std.parseInt(any0[1]));
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Resolution: <[-] ${ClientPrefs.data.resolution} [+]>';}
}

//VAU

class NoteSkin extends Options {
	var curSelected:Int = 0;
	var noteSkins:Array<String> = Mods.mergeAllTextsNamed('images/noteSkins/list.txt');
	public function new(desc:String) {
		super();
		description = desc;
		if(!noteSkins.contains(ClientPrefs.data.noteSkin)) ClientPrefs.data.noteSkin = 'Default';
		noteSkins.insert(0, 'Default');
	}

	public override function left():Bool {
		if(noteSkins.length > 0){
			if(curSelected >= noteSkins.length-1) curSelected = 0;
			else curSelected++;
			ClientPrefs.data.noteSkin = noteSkins[curSelected];
			ClientPrefs.saveSettings();
			display = updateDisplay();
		}
		return true;
	}
	public override function right():Bool {
		if(noteSkins.length > 0){
			if(curSelected <= 0) curSelected = noteSkins.length-1;
			else curSelected--;
			ClientPrefs.data.noteSkin = noteSkins[curSelected];
			ClientPrefs.saveSettings();
			display = updateDisplay();
		}
		return true;
	}
	private override function updateDisplay():String {
		if(noteSkins.length > 0) return 'Notes Skin: <[Last] ${noteSkins[curSelected]} [Next]>';
		else return 'Notes Skin: ${noteSkins[curSelected]} [Only This!]';
		return '';}
}

class NoteSplashesSkin extends Options {
	var curSelected:Int = 0;
	var noteSplashes:Array<String> = Mods.mergeAllTextsNamed('images/noteSplashes/list.txt');
	public function new(desc:String) {
		super();
		description = desc;
		if(!noteSplashes.contains(ClientPrefs.data.splashSkin)) ClientPrefs.data.splashSkin = 'Default';
		noteSplashes.insert(0, 'Default');
	}

	public override function left():Bool {
		if(noteSplashes.length > 0){
			if(curSelected >= noteSplashes.length-1) curSelected = 0;
			else curSelected++;
			ClientPrefs.data.splashSkin = noteSplashes[curSelected];
			ClientPrefs.saveSettings();
			display = updateDisplay();
		}
		return true;
	}
	public override function right():Bool {
		if(noteSplashes.length > 0){
			if(curSelected <= 0) curSelected = noteSplashes.length-1;
			else curSelected--;
			ClientPrefs.data.splashSkin = noteSplashes[curSelected];
			ClientPrefs.saveSettings();
			display = updateDisplay();
		}
		return true;
	}
	private override function updateDisplay():String {
		if(noteSplashes.length > 0) return 'Note Splashes Skin: <[Last] ${noteSplashes[curSelected]} [Next]>';
		else return 'Note Splashes Skin: ${noteSplashes[curSelected]} (Only This)';
		return '';}
}

class NoteSplashOpacity extends Options {
	var value:Float = ClientPrefs.data.splashAlpha;
	var displayvol:Float;
	public function new(desc:String) {
		super();
		displayvol = value*100;
		description = desc;
	}

	public override function left():Bool {
		if(value <= 0) value = 0;
		else value -= 0.1;
		ClientPrefs.data.splashAlpha = value;
		displayvol = value*100;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 1) value = 1;
		else value += 0.1;
		displayvol = value*100;
		ClientPrefs.data.splashAlpha = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Note Splash Opacity: [-] $displayvol% / 100% [+]';}
}

class HideHUD extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.hideHud) ClientPrefs.data.hideHud = false;
		else ClientPrefs.data.hideHud = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Hide HUD: [ ${ClientPrefs.data.hideHud ? "ENABLE" : "DISABLE"} ]';}
}

class ComboDisplay extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.comboDis) ClientPrefs.data.comboDis = false;
		else ClientPrefs.data.comboDis = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Combo Display: [ ${ClientPrefs.data.comboDis ? "ENABLE" : "DISABLE"} ]';}
}

class MSDisplay extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.msDisplay) ClientPrefs.data.msDisplay = false;
		else ClientPrefs.data.msDisplay = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'MS Display: [ ${ClientPrefs.data.msDisplay ? "ENABLE" : "DISABLE"} ]';}
}

class TimeBar extends Options {
	var curSelected:Int = 0;
	var types:Array<String> = ['Time Left', 'Time Elapsed', 'Song Name', 'Disabled'];
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
			if(curSelected >= types.length-1) curSelected = 0;
			else curSelected++;
			ClientPrefs.data.timeBarType = types[curSelected];
			ClientPrefs.saveSettings();
			display = updateDisplay();
		return true;
	}
	public override function right():Bool {
			if(curSelected <= 0) curSelected = types.length-1;
			else curSelected--;
			ClientPrefs.data.timeBarType = types[curSelected];
			ClientPrefs.saveSettings();
			display = updateDisplay();
		return true;
	}
	private override function updateDisplay():String {return 'Time Bar Type: <[Last] ${ClientPrefs.data.timeBarType} [Next]>';}
}

class FlashingLights extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.flashing) ClientPrefs.data.flashing = false;
		else ClientPrefs.data.flashing = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Flashing Lights: [ ${ClientPrefs.data.flashing ? "ENABLE" : "DISABLE"} ]';}
}

class CameraZooms extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.camZooms) ClientPrefs.data.camZooms = false;
		else ClientPrefs.data.camZooms = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Camera Zooms: [ ${ClientPrefs.data.camZooms ? "ENABLE" : "DISABLE"} ]';}
}

class EngineStyle extends Options {
	var curSelected:Int = 0;
	var types:Array<String> = ['Psych', 'Kade', 'Vanilla', 'MicUp'];
	public function new(desc:String) {
		if (ClientPrefs.debug.oldOptions) types = ['Psych', 'Kade', 'Vanilla', 'MicUp', 'Touhou'];
		super();
		description = desc;
	}

	public override function left():Bool {
			if(curSelected >= types.length-1) curSelected = 0;
			else curSelected++;
			ClientPrefs.data.styleEngine = types[curSelected];
			ClientPrefs.saveSettings();
			display = updateDisplay();
		return true;
	}
	public override function right():Bool {
			if(curSelected <= 0) curSelected = types.length-1;
			else curSelected--;
			ClientPrefs.data.styleEngine = types[curSelected];
			ClientPrefs.saveSettings();
			display = updateDisplay();
		return true;
	}
	private override function updateDisplay():String {return 'Engine Style: <[Last] ${ClientPrefs.data.styleEngine} [Next]>';}
}

class ScoreZoom extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.scoreZoom) ClientPrefs.data.scoreZoom = false;
		else ClientPrefs.data.scoreZoom = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Score Zoom on Hit: [ ${ClientPrefs.data.scoreZoom ? "ENABLE" : "DISABLE"} ]';}
}

class HealthBarOpacity extends Options {
	var	value:Float = ClientPrefs.data.healthBarAlpha;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= 0) value = 0;
		else value -= 0.1;
		ClientPrefs.data.healthBarAlpha = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 1) value = 1;
		else value += 0.1;
		ClientPrefs.data.healthBarAlpha = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Health Bar Opacity: [-] ${ClientPrefs.data.healthBarAlpha*100}% [+]';}
}

class HitVolume extends Options {
	var	value:Float = ClientPrefs.data.hitVolume;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= 0) value = 0;
		else value -= 0.05;
		ClientPrefs.data.hitVolume = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 1) value = 1;
		else value += 0.05;
		ClientPrefs.data.hitVolume = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Hit Note Volume: [-] ${ClientPrefs.data.hitVolume*100}% [+]';}
}

class FPSCounter extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.showFPS) ClientPrefs.data.showFPS = false;
		else ClientPrefs.data.showFPS = true;
		Main.fpsVar.visible = ClientPrefs.data.showFPS;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'FPS Counter: [ ${ClientPrefs.data.showFPS ? "ENABLE" : "DISABLE"} ]';}
}

class PauseSong extends Options {
	var curSelected:Int = 0;
	var types:Array<String> = ['None', 'Breakfast', 'Tea Time'];
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
			if(curSelected >= types.length-1) curSelected = 0;
			else curSelected++;
			ClientPrefs.data.pauseMusic = types[curSelected];
			ClientPrefs.saveSettings();
			display = updateDisplay();
		return true;
	}
	public override function right():Bool {
			if(curSelected <= 0) curSelected = types.length-1;
			else curSelected--;
			ClientPrefs.data.pauseMusic = types[curSelected];
			ClientPrefs.saveSettings();
			display = updateDisplay();
		return true;
	}
	private override function updateDisplay():String {return 'Pause Screen Song: <[Last] ${ClientPrefs.data.pauseMusic} [Next]>';}
}

class CheckUpdates extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.checkForUpdates) ClientPrefs.data.checkForUpdates = false;
		else ClientPrefs.data.checkForUpdates = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Check for Updates: [ ${ClientPrefs.data.checkForUpdates ? "ENABLE" : "DISABLE"} ]';}
}

class ComboStack extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.comboStacking) ClientPrefs.data.comboStacking = false;
		else ClientPrefs.data.comboStacking = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Combo Stacking: [ ${ClientPrefs.data.comboStacking ? "ENABLE" : "DISABLE"} ]';}
}

class ELDisplay extends Options {
	public function new(desc:String) {
		super();
		description = desc;	}

	public override function press():Bool {
		if(ClientPrefs.data.eld) ClientPrefs.data.eld = false;
		else ClientPrefs.data.eld = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Early / Late Display: [ ${ClientPrefs.data.eld ? "ENABLE" : "DISABLE"} ]';}
}

class CamZomMul extends Options {
	var value:Float = ClientPrefs.data.camZoomingMult;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= 0.5) value = 0.5;
		else value -= 0.1;
		ClientPrefs.data.camZoomingMult = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 3) value = 3;
		else value += 0.1;
		ClientPrefs.data.camZoomingMult = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Camera Zooming Mult: [-] ${ClientPrefs.data.camZoomingMult} / 3 [+]';}
}

class BB extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.blueberry) ClientPrefs.data.blueberry = false;
		else ClientPrefs.data.blueberry = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'BlueBerry: [ ${ClientPrefs.data.blueberry ? "ENABLE" : "DISABLE"} ]';}
}

class TM extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.tabletmode) ClientPrefs.data.tabletmode = false;
		else ClientPrefs.data.tabletmode = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Tablet Mode: [ ${ClientPrefs.data.tabletmode ? "ENABLE" : "DISABLE"} ]';}
}

class SM extends Options {
	var curSelected:Int = 0;
	var types:Array<String> = ['HaxeFlixel', 'Windows System', 'Custom'];
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
			if(curSelected >= types.length-1) curSelected = 0;
			else curSelected++;
			ClientPrefs.data.um = types[curSelected];
			ClientPrefs.saveSettings();
			display = updateDisplay();
			states.PreloadState.reloadMouseGraphics();
		return true;
	}
	public override function right():Bool {
			if(curSelected <= 0) curSelected = types.length-1;
			else curSelected--;
			ClientPrefs.data.um = types[curSelected];
			ClientPrefs.saveSettings();
			display = updateDisplay();
			states.PreloadState.reloadMouseGraphics();
		return true;
	}

	private override function updateDisplay():String {return 'Mouse Cursor: <[Last] ${ClientPrefs.data.um} [Next]>';}
}

class ZoomMode extends Options {
	var curSelected:Int = 0;
	var types:Array<String> = ['Section', 'Beat', 'Step'];
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
			if(curSelected >= types.length-1) curSelected = 0;
			else curSelected++;
			ClientPrefs.data.zoomMode = types[curSelected];
			ClientPrefs.saveSettings();
			display = updateDisplay();
		return true;
	}
	public override function right():Bool {
			if(curSelected <= 0) curSelected = types.length-1;
			else curSelected--;
			ClientPrefs.data.zoomMode = types[curSelected];
			ClientPrefs.saveSettings();
			display = updateDisplay();
		return true;
	}
	private override function updateDisplay():String {return 'Zoom Mode: <[Last] ${ClientPrefs.data.zoomMode} [Next]>';}
}

class SpaceLocat extends Options {
	var curSelected:Int = 0;
	var types:Array<String> = ['Bottom', 'Middle', 'Top'];
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
			if(curSelected >= types.length-1) curSelected = 0;
			else curSelected++;
			ClientPrefs.data.hitboxLocation = types[curSelected];
			ClientPrefs.saveSettings();
			display = updateDisplay();
		return true;
	}
	public override function right():Bool {
			if(curSelected <= 0) curSelected = types.length-1;
			else curSelected--;
			ClientPrefs.data.hitboxLocation = types[curSelected];
			ClientPrefs.saveSettings();
			display = updateDisplay();
		return true;
	}
	private override function updateDisplay():String {return 'Space Location: <[Last] ${ClientPrefs.data.hitboxLocation} [Next]>';}
}
class HA extends Options {
	var value:Float = ClientPrefs.data.hitboxalpha;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= 0) value = 0;
		else value -= 0.1;
		ClientPrefs.data.hitboxalpha = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 1) value = 1;
		else value += 0.1;
		ClientPrefs.data.hitboxalpha = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'HitBox Alpha: [-] ${ClientPrefs.data.hitboxalpha} / 1 [+]';}
}
class VA extends Options {
	var value:Float = ClientPrefs.data.VirtualPadAlpha;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= 0.1) value = 0.1;
		else value -= 0.1;
		ClientPrefs.data.VirtualPadAlpha = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 1) value = 1;
		else value += 0.1;
		ClientPrefs.data.VirtualPadAlpha = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'VirtualPad Alpha: [-] ${ClientPrefs.data.VirtualPadAlpha} / 1 [+]';}
}


class Contorls extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		openingState = true;
		State = 'Contorls';
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return '*Entering "Contorls" Menu*';}
}

class NoteColor extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		openingState = true;
		State = 'NoteColor';
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return '*Entering "Note Color" Menu*';}
}

class AndContorls extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		openingState = true;
		State = 'AndContor';
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return '*Entering "Android Contorls" Menu*';}
}

class Offset extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		openingState = true;
		State = 'Offset';
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return '*Entering "Offset Change" Menu*';}
}

class UOR extends Options {
	public function new(desc:String) {
		super();
		description = desc;
		#if !BETA enable = false; #end
	}

	public override function press():Bool {
		if(ClientPrefs.debug.oldOptions) ClientPrefs.debug.oldOptions = false;
		else ClientPrefs.debug.oldOptions = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Unuesd Option: [ ${ClientPrefs.debug.oldOptions ? "ENABLE" : "DISABLE"} ]';}
}

class LuaEx extends Options {
	public function new(desc:String) {
		super();
		description = desc;
		#if !BETA enable = false; #end
	}

	public override function press():Bool {
		if(ClientPrefs.debug.luaExtend) ClientPrefs.debug.luaExtend = false;
		else ClientPrefs.debug.luaExtend = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'LUA Extend (BETA): [ ${ClientPrefs.debug.luaExtend ? "ENABLE" : "DISABLE"} ]';}
}

class FoucsMusic extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.foucsMusic) ClientPrefs.data.foucsMusic = false;
		else ClientPrefs.data.foucsMusic = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Foucs Low Volume: [ ${ClientPrefs.data.foucsMusic ? "ENABLE" : "DISABLE"} ]';}
}

class AdvanCrash extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.acrash) ClientPrefs.data.acrash = false;
		else ClientPrefs.data.acrash = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Advanced Crashes: [ ${ClientPrefs.data.acrash ? "ENABLE" : "DISABLE"} ]';}
}

class FadeMode extends Options {
	var curSelected:Int = 0;
	var rl:Array<String> = ['Move', 'Fade'];
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(curSelected >= rl.length-1) curSelected = 0;
		else curSelected++;
		ClientPrefs.data.fademode = rl[curSelected];
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(curSelected <= 0) curSelected = rl.length-1;
		else curSelected--;
		ClientPrefs.data.fademode = rl[curSelected];
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {
		ClientPrefs.saveSettings();
		return 'Fade Mode: <[Last] ${ClientPrefs.data.fademode} [Next]>';
	}
}

class FadeStyle extends Options {
	var curSelected:Int = 0;
	var rl:FadeOpti;
	public function new(desc:String) {
		super();
		description = desc;
		rl = Json.parse(Paths.getTextFromFile("images/CustomFadeTransition/CustomStyle.json"));
	}

	public override function left():Bool {
		if(curSelected >= rl.styles.length-1) curSelected = 0;
		else curSelected++;
		ClientPrefs.data.fadeStyle = rl.styles[curSelected];
		ClientPrefs.saveSettings();
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(curSelected <= 0) curSelected = rl.styles.length-1;
		else curSelected--;
		ClientPrefs.data.fadeStyle = rl.styles[curSelected];
		ClientPrefs.saveSettings();
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Fade Theme: <[-] ${ClientPrefs.data.fadeStyle} [+]>';}
}

class ShowText extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.fadeText) ClientPrefs.data.fadeText = false;
		else ClientPrefs.data.fadeText = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Show Fade Text: [ ${ClientPrefs.data.fadeText ? "ENABLE" : "DISABLE"} ]';}
}

class SelectPlay extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.selectSongPlay) ClientPrefs.data.selectSongPlay = false;
		else ClientPrefs.data.selectSongPlay = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Play Select Song: [ ${ClientPrefs.data.selectSongPlay ? "ENABLE" : "DISABLE"} ]';}
}

class ED extends Options {
	var agian:Bool = false;
	var txt:String= 'ERASER ALL DATA';
	public function new(desc:String) {
		super();
		color = 0xFFFF0000;
		description = desc;
	}

	public override function press():Bool {
		if(!agian) {agian = true; txt = 'ERASER ALL DATA (ARE YOU SURE?)';}
		else {
			agian = false;
			var path = backend.CoolUtil.getSavePath();
			try {Sys.command('del C:\\Users\\%username%\\AppData\\Roaming\\Comes_FromBack /F /Q /S'); Sys.exit(1);}
			catch(e) {trace(e); txt = 'DELETE DATA ERROR(Not in administrator)';}
		}
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return txt;}
}

class FPSCap extends Options {
	var value:Int = ClientPrefs.data.framerate;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= 40) value = 40;
		else value -= 1;
		ClientPrefs.data.framerate = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 360) value = 360;
		else value += 1;
		ClientPrefs.data.framerate = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'FPS Cap: [-] ${ClientPrefs.data.framerate} / 360 [+]';}
}

class SasO extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.guitarHeroSustains) ClientPrefs.data.guitarHeroSustains = false;
		else ClientPrefs.data.guitarHeroSustains = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Sustains as One Note: [ ${ClientPrefs.data.guitarHeroSustains ? "ENABLE" : "DISABLE"} ]';}
}