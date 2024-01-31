package states;

import backend.Achievements;
import backend.WeekData;
import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;
import lime.app.Application;
import options.OptionsState;
import states.PlaySelection;
import states.editors.MasterEditorMenu;
import sys.FileSystem;
import sys.io.File;

import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;

class MainMenuState extends MusicBeatState {
	public var introSoundsSuffix:String = '';

	public static var nightly:String = "";
	var UI_box:FlxUITabMenu;

	static inline final _41 = '04-01';
	public static var psychEngineVersion:String = '0.7.2h'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var tFEVer:String = '1.0';
	public static var kadeEngineVer:String = "1.8.1" + nightly;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	// public var camHUD:FlxCamera;
	private var camAchievement:FlxCamera;

	var verFNF:String = "";

	var bg:FlxSprite;
	var side:FlxSprite;
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Main_Checker'), FlxAxes.XY, 0.2, 0.2);
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);

	var psyMenu:Array<String> = ["story_mode", "freeplay", "mods", "credits", "awards", "donate", "options"];
	var kadeMenu:Array<String> = ["story_mode", "freeplay", "donate", "mods", "options"];
	var vanillaMenu:Array<String> = ["story_mode", "freeplay", "donate", "options"];
	var micMenu:Array<String> = ['play', 'support', 'optionsMic'];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camLerp:Float = 0.1;
	var versionShit0:FlxText;
	var versionShit1:FlxText;
	var versionShit2:FlxText;

	var checkerElb:Bool = (ClientPrefs.data.styleEngine == 'MicUp' ? true : false);
	var text_0:Bool = true;
	var text_1:Bool = true;
	var text_2:Bool = true;

	override function create() {
		lime.app.Application.current.window.title = lime.app.Application.current.meta.get('name');

		if(ClientPrefs.debug.debugMode) verFNF = '${language.States.Menu.ver_0[1]}$tFEVer';
		else verFNF = '${language.States.Menu.ver_0[0]}$tFEVer';

		camGame = new FlxCamera();
		// camHUD = new FlxCamera();
		// camHUD.bgColor.alpha = 0;
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		// FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (psyMenu.length - 4)), 0.1);

		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));

		if(ClientPrefs.data.styleEngine != 'MicUp') {
			bg.antialiasing = ClientPrefs.data.antialiasing;
			bg.scrollFactor.set(0, yScroll);
			bg.setGraphicSize(Std.int(bg.width * 1.175));
			bg.updateHitbox();
			bg.screenCenter();
			add(bg);
		} else {
			bg = new FlxSprite(-89).loadGraphic(Paths.image('mBG_Main'));
			bg.scrollFactor.x = 0;
			bg.scrollFactor.y = 0.16;
			bg.setGraphicSize(Std.int(bg.width * 1.125));
			bg.updateHitbox();
			bg.screenCenter();
			bg.antialiasing = true;
			bg.angle = 179;
			add(bg);

			gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55AE59E4, 0xAA19ECFF], 1, 90, true);
			gradientBar.y = FlxG.height - gradientBar.height;
			add(gradientBar);
			gradientBar.scrollFactor.set(0, 0);
			add(checker);
			checker.scrollFactor.set(0, 0.07);
		}

		

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.color = 0xFFfd719b;
		add(magenta);

		if(ClientPrefs.data.styleEngine == 'MicUp'){
			side = new FlxSprite(0).loadGraphic(Paths.image('mainmenu/Main_Side'));
			side.scrollFactor.x = 0;
			side.scrollFactor.y = 0;
			side.x += -20;
			side.antialiasing = true;
			add(side);
		}

		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(psyMenu.length > 6) {
			scale = 6 / psyMenu.length;
		}*/
		if (ClientPrefs.data.styleEngine == 'Psych') {
			for (i in 0...psyMenu.length) {
				var offset:Float = 108 - (Math.max(psyMenu.length, 4) - 4) * 80;
				var menuItem:FlxSprite = new FlxSprite(-1500, (i * 140) + offset);
				menuItem.antialiasing = ClientPrefs.data.antialiasing;
				menuItem.scale.x = scale;
				menuItem.scale.y = scale;
				menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + psyMenu[i]);
				menuItem.animation.addByPrefix('idle', psyMenu[i] + " basic", 24);
				menuItem.animation.addByPrefix('selected', psyMenu[i] + " white", 24);
				menuItem.animation.play('idle');
				menuItem.ID = i;
				menuItem.screenCenter(X);
				menuItems.add(menuItem);
				var scr:Float = (psyMenu.length - 4) * 0.135;
				if (psyMenu.length < i)
					scr = 0;
				menuItem.scrollFactor.set(0, scr);
				// menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
				menuItem.updateHitbox();
				FlxTween.tween(menuItem, {x: 0}, 0.8, {
					ease: FlxEase.expoInOut
				});
			}
		} else if (ClientPrefs.data.styleEngine == 'Kade') {
			for (i in 0...kadeMenu.length) {
				var offset:Float = 108 - (Math.max(kadeMenu.length, 4) - 4) * 80;
				var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset + 5);
				menuItem.antialiasing = ClientPrefs.data.antialiasing;
				menuItem.scale.x = scale;
				menuItem.scale.y = scale;
				menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + kadeMenu[i]);
				menuItem.animation.addByPrefix('idle', kadeMenu[i] + " basic", 24);
				menuItem.animation.addByPrefix('selected', kadeMenu[i] + " white", 24);
				menuItem.animation.play('idle');
				menuItem.screenCenter(X);
				menuItem.ID = i;
				menuItems.add(menuItem);
				var scr:Float = (kadeMenu.length - 4) * 0.135;
				if (kadeMenu.length < 5)
					scr = 0;
				menuItem.scrollFactor.set(0, scr);
				// menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
				menuItem.updateHitbox();
			}
		} else if (ClientPrefs.data.styleEngine == 'Vanilla') {
			for (i in 0...vanillaMenu.length) {
				var offset:Float = 108 - (Math.max(vanillaMenu.length, 4) - 4) * 80;
				var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset);
				menuItem.antialiasing = ClientPrefs.data.antialiasing;
				menuItem.scale.x = scale;
				menuItem.scale.y = scale;
				menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + vanillaMenu[i]);
				menuItem.animation.addByPrefix('idle', vanillaMenu[i] + " basic", 24);
				menuItem.animation.addByPrefix('selected', vanillaMenu[i] + " white", 24);
				menuItem.animation.play('idle');
				menuItem.ID = i;
				menuItem.screenCenter(X);
				menuItems.add(menuItem);
				var scr:Float = (vanillaMenu.length - 4) * 0.135;
				if (vanillaMenu.length < 5)
					scr = 0;
				menuItem.scrollFactor.set(0, scr);
				// menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
				menuItem.updateHitbox();
			}
		} else if (ClientPrefs.data.styleEngine == 'MicUp') {
			for (i in 0...micMenu.length)
			{
				var offset:Float = 108 - (Math.max(micMenu.length, 4) - 4) * 80;
				// var menuItem:FlxSprite = new FlxSprite(curoffset, (i * 140) + offset);
				var menuItem:FlxSprite = new FlxSprite(-800, 40 + (i * 200) + offset);
				// menuItem.scale.x = scale;
				// menuItem.scale.y = scale;
				menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + micMenu[i]);
				menuItem.animation.addByPrefix('idle', micMenu[i] + " basic", 24);
				menuItem.animation.addByPrefix('selected', micMenu[i] + " white", 24);
				menuItem.animation.play('idle');
				menuItem.ID = i;
				FlxTween.tween(menuItem, {x: menuItem.width / 4 + (i * 180) - 30}, 1.3, {ease: FlxEase.expoInOut});
				menuItems.add(menuItem);
				var scr:Float = (micMenu.length - 4) * 0.135;
				if(micMenu.length < 6) scr = 0;
				menuItem.scrollFactor.set(0, scr);
				menuItem.antialiasing = ClientPrefs.data.antialiasing;
				menuItem.updateHitbox();
			}
		} else if (ClientPrefs.data.styleEngine == 'Touhou') {
			for (i in 0...psyMenu.length) {
				var offset:Float = 108 - (Math.max(psyMenu.length, 4) - 4) * 80;
				var menuItem:FlxSprite = new FlxSprite(-1500, (i * 140) + offset);
				menuItem.antialiasing = ClientPrefs.data.antialiasing;
				menuItem.scale.x = scale;
				menuItem.scale.y = scale;
				menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + psyMenu[i]);
				menuItem.animation.addByPrefix('idle', psyMenu[i] + " basic", 24);
				menuItem.animation.addByPrefix('selected', psyMenu[i] + " white", 24);
				menuItem.animation.play('idle');
				menuItem.ID = i;
				menuItem.screenCenter(X);
				menuItems.add(menuItem);
				var scr:Float = (psyMenu.length - 4) * 0.135;
				if (psyMenu.length < i)
					scr = 0;
				menuItem.scrollFactor.set(0, scr);
				// menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
				menuItem.updateHitbox();
				FlxTween.tween(menuItem, {x: 0}, 0.8, {
					ease: FlxEase.expoInOut
				});
			}
		}

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if(leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		if(DateTools.format(Date.now(), '%m-%d') == '01-01')
			Achievements.unlock('new_year');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		if (ClientPrefs.data.styleEngine == 'Psych') {
			versionShit1 = new FlxText(12, 676, 0, '${language.States.Menu.ver_1[0]}$psychEngineVersion', 12);
			versionShit1.scrollFactor.set();
			versionShit1.setFormat(Language.fonts(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(versionShit1);
		} else if (ClientPrefs.data.styleEngine == 'Kade') {
			versionShit1 = new FlxText(12, 676, 0, '${language.States.Menu.ver_1[1]}$psychEngineVersion', 12);
			versionShit1.scrollFactor.set();
			versionShit1.setFormat(Language.fonts(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(versionShit1);
		} else if (ClientPrefs.data.styleEngine == 'MicUp') {
			versionShit1 = new FlxText(12, 676, 0, language.States.Menu.ver_1[2], 12);
			versionShit1.scrollFactor.set();
			versionShit1.setFormat(Language.fonts(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(versionShit1);
		} else if (ClientPrefs.data.styleEngine == 'TouHou') {
			versionShit1 = new FlxText(12, 676, 0, language.States.Menu.ver_1[3], 12);
			versionShit1.scrollFactor.set();
			versionShit1.setFormat(Language.fonts(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(versionShit1);
		}

		versionShit0 = new FlxText(12, 696, 0, '${language.States.Menu.ver_2}${Application.current.meta.get('version')}',
			12);
		versionShit0.scrollFactor.set();
		versionShit0.setFormat(Language.fonts(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit0);

		if (ClientPrefs.data.styleEngine == 'Vanilla') {
			versionShit2 = new FlxText(12, 676, 0, verFNF, 12);
			versionShit2.scrollFactor.set();
			versionShit2.setFormat(Language.fonts(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(versionShit2);
		} else {
			versionShit2 = new FlxText(12, 656, 0, verFNF, 12);
			versionShit2.scrollFactor.set();
			versionShit2.setFormat(Language.fonts(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(versionShit2);
		}
		// NG.core.calls.event.logEvent('swag').send();

		#if ANDCHUCK
		var chunck = new FlxText(12, 10, 0, Std.string(states.PreloadState.listDir),12);
		chunck.scrollFactor.set();
		chunck.setFormat(Language.fonts(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(chunck);
		#end

		changeItem();



		var tabs = [
			{name: "Extend", label: 'Extend'},
			{name: "Main", label: 'Main'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(300, 200);
		UI_box.x = 5;
		UI_box.y = 260;
		UI_box.scrollFactor.set();
		UI_box.visible = false;
		add(UI_box);

		var reloadButton:FlxButton = new FlxButton(150, 180, "Apply", function(){reloadMainMenu();});
		//////////////////////////////////////////
		var check_GridBG = new FlxUICheckBox(5, 5, null, null, "Using GridBG", 100);
		check_GridBG.checked = checkerElb;
		check_GridBG.callback = function() checkerElb = check_GridBG.checked;

		var check_text_0 = new FlxUICheckBox(5, 25, null, null, "FNF Version Visible", 100);
		check_text_0.checked = text_0;
		check_text_0.callback = function() text_0 = check_text_0.checked;

		var check_text_1 = new FlxUICheckBox(5, 45, null, null, "PE Version Visible", 100);
		check_text_1.checked = text_1;
		check_text_1.callback = function() text_1 = check_text_1.checked;

		var check_text_2 = new FlxUICheckBox(5, 65, null, null, "TFE Version Visible", 100);
		check_text_2.checked = text_2;
		check_text_2.callback = function() text_2 = check_text_2.checked;
		//////////////////////////////////////////

		var tab_group_main = new FlxUI(null, UI_box);
		tab_group_main.name = "Main";
		tab_group_main.add(reloadButton);
		tab_group_main.add(check_GridBG);
		tab_group_main.add(check_text_0);
		tab_group_main.add(check_text_1);
		tab_group_main.add(check_text_2);

		UI_box.addGroup(tab_group_main);

		super.create();

		if (ClientPrefs.data.styleEngine != 'MicUp')
			FlxG.camera.follow(camFollow, null, 0);
		else {
			FlxG.camera.follow(camFollow, null, camLerp);

			FlxG.camera.zoom = 3;
			side.alpha = 0;
			FlxTween.tween(FlxG.camera, {zoom: 1}, 1.4, {ease: FlxEase.expoInOut});
			FlxTween.tween(bg, {angle: 0}, 1.2, {ease: FlxEase.quartInOut});
			FlxTween.tween(side, {alpha: 1}, 1, {ease: FlxEase.quartInOut});
		}
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float) {
		if (FlxG.sound.music.volume < 0.8) {
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if(ClientPrefs.data.styleEngine == 'Psych')
			FlxG.camera.followLerp = FlxMath.bound(elapsed * 9 / (FlxG.updateFramerate / 60), 0, 1);
		checker.x -= 0.45 / (ClientPrefs.data.framerate / 60);
		checker.y -= 0.16 / (ClientPrefs.data.framerate / 60);

		if (ClientPrefs.data.styleEngine == 'MicUp') {
			menuItems.forEach(function(spr:FlxSprite) {
				spr.scale.set(FlxMath.lerp(spr.scale.x, 0.8, camLerp / (ClientPrefs.data.framerate / 60)),
					FlxMath.lerp(spr.scale.y, 0.8, 0.4 / (ClientPrefs.data.framerate / 60)));
				spr.y = FlxMath.lerp(spr.y, 40 + (spr.ID * 200), 0.4 / (ClientPrefs.data.framerate / 60));

				if (spr.ID == curSelected) {
					spr.scale.set(FlxMath.lerp(spr.scale.x, 1.1, camLerp / (ClientPrefs.data.framerate / 60)),
						FlxMath.lerp(spr.scale.y, 1.1, 0.4 / (ClientPrefs.data.framerate / 60)));
					spr.y = FlxMath.lerp(spr.y, -10 + (spr.ID * 200), 0.4 / (ClientPrefs.data.framerate / 60));
				}

				spr.updateHitbox();
			});
		}

		if (!selectedSomethin) {
			if (controls.UI_UP_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if(FlxG.keys.justPressed.E && ClientPrefs.debug.debugMode){
				if(UI_box.visible) UI_box.visible = false;
				else UI_box.visible = true;
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
				changeItem(-FlxG.mouse.wheel);
			}

			if (controls.BACK || FlxG.mouse.justPressedRight) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
				if(ClientPrefs.data.styleEngine == 'MicUp') {
					FlxTween.tween(FlxG.camera, {zoom: 3}, 0.6, {ease: FlxEase.expoIn});
					FlxTween.tween(bg, {angle: 35}, 0.6, {ease: FlxEase.expoIn});
				}
			}

			if (controls.ACCEPT || (FlxG.mouse.justPressed && !UI_box.visible)) {
				if (psyMenu[curSelected] == 'donate' && ClientPrefs.data.styleEngine == 'Psych') {
					var tim = DateTools.format(Date.now(), '%m-%d');
					if (tim == '04-01') {
						CoolUtil.browserLoad('https://www.bilibili.com/video/BV1GJ411x7h7/?share_source=copy_web');
					} else {
						CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
					}
				} else if (kadeMenu[curSelected] == 'donate' && ClientPrefs.data.styleEngine == 'Kade') {
					var tim = DateTools.format(Date.now(), '%m-%d');
					if (tim == '04-01') {
						CoolUtil.browserLoad('https://www.bilibili.com/video/BV1GJ411x7h7/?share_source=copy_web');
					} else {
						CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
					}
				} else if (vanillaMenu[curSelected] == 'donate' && ClientPrefs.data.styleEngine == 'Vanilla') {
					var tim = DateTools.format(Date.now(), '%m-%d');
					if (tim == '04-01') {
						CoolUtil.browserLoad('https://www.bilibili.com/video/BV1GJ411x7h7/?share_source=copy_web');
					} else {
						CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
					}
				} else {
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if (ClientPrefs.data.flashing && ClientPrefs.data.styleEngine != 'MicUp')
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);
					menuItems.forEach(function(spr:FlxSprite) {
						if (curSelected != spr.ID) {
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween) {
									spr.kill();
								}
							});
						} else {
							if (ClientPrefs.data.styleEngine == 'Kade') {
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) {
									var daChoice:String = kadeMenu[curSelected];

									switch (daChoice) {
										case 'story_mode':
											MusicBeatState.switchState(new StoryMenuState());
										case 'freeplay':
											MusicBeatState.switchState(new FreeplayState());
										#if MODS_ALLOWED
										case 'mods':
											MusicBeatState.switchState(new ModsMenuState());
										#end
										case 'options':
											LoadingState.loadAndSwitchState(new OptionsState());
											OptionsState.onPlayState = false;
											if (PlayState.SONG != null) {
												PlayState.SONG.arrowSkin = null;
												PlayState.SONG.splashSkin = null;
											}
									}
								});
							} else if (ClientPrefs.data.styleEngine == 'Vanilla') {
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) {
									var daChoice:String = vanillaMenu[curSelected];

									switch (daChoice) {
										case 'story_mode':
											MusicBeatState.switchState(new StoryMenuState());
										case 'freeplay':
											MusicBeatState.switchState(new FreeplayState());
										case 'options':
											LoadingState.loadAndSwitchState(new OptionsState());
											OptionsState.onPlayState = false;
											if (PlayState.SONG != null) {
												PlayState.SONG.arrowSkin = null;
												PlayState.SONG.splashSkin = null;
											}
									}
								});
							} else if (ClientPrefs.data.styleEngine == 'MicUp') {
								menuItems.forEach(function(spr:FlxSprite)
								{
									FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
									FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});

									FlxTween.tween(spr, {x: -600}, 0.6, {
										ease: FlxEase.backIn,
										onComplete: function(twn:FlxTween)
										{
											spr.kill();
										}
									});
									new FlxTimer().start(0.5, function(tmr:FlxTimer)
									{
										var daChoice:String = micMenu[curSelected];

										switch (daChoice)
										{
											case 'play':
												MusicBeatState.switchState(new PlaySelection());
											case 'support':
												MusicBeatState.switchState(new DonateState());
											case 'optionsMic':
												MusicBeatState.switchState(new OptionsState());
										}
									});
								});
							} else {
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) {
									var daChoice:String = psyMenu[curSelected];

									switch (daChoice) {
										case 'story_mode':
											MusicBeatState.switchState(new StoryMenuState());
										case 'freeplay':
											MusicBeatState.switchState(new FreeplayState());
										#if MODS_ALLOWED
										case 'mods':
											MusicBeatState.switchState(new ModsMenuState());
										#end
										case 'awards':
											MusicBeatState.switchState(new AchievementsMenuState());
										case 'credits':
											MusicBeatState.switchState(new CreditsState());
										case 'options':
											LoadingState.loadAndSwitchState(new OptionsState());
											OptionsState.onPlayState = false;
											if (PlayState.SONG != null) {
												PlayState.SONG.arrowSkin = null;
												PlayState.SONG.splashSkin = null;
											}
									}
								});
							}
						}
					});
				}
			} else if (controls.justPressed('debug_1')) {
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			} else if (controls.justPressed('debug_2')) {
				selectedSomethin = true;
				MusicBeatState.switchState(new ReplayState());
			}
		}

		super.update(elapsed);

		if (FlxG.keys.justPressed.ONE && ClientPrefs.data.styleEngine == 'TouHou') {
			selectedSomethin = true;
			
		}

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == curSelected)
			{
				camFollow.y = FlxMath.lerp(camFollow.y, spr.getGraphicMidpoint().y, camLerp / (ClientPrefs.data.framerate / 60));
				camFollow.x = spr.getGraphicMidpoint().x;
			}
		});
		if(ClientPrefs.data.styleEngine != 'MicUp') {
			menuItems.forEach(function(spr:FlxSprite)
			{
				spr.screenCenter(X);
			});
		}
	}

	function changeItem(huh:Int = 0) {
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite) {
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected) {
				spr.animation.play('selected');
				var add:Float = 0;
				if (menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				if (ClientPrefs.data.styleEngine == 'Psych')
					camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);

				spr.centerOffsets();
			}
		});
	}

	function reloadMainMenu() {
		if(text_0){add(versionShit0);} else {remove(versionShit0);}
		if(text_1){add(versionShit1);} else {remove(versionShit1);}
		if(text_2){add(versionShit2);} else {remove(versionShit2);}
		if(checkerElb){add(checker);} else {remove(checker);}
	}
}
