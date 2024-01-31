package states;

import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import lib.AlphabetMic;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import flixel.util.FlxGradient;

import shaders.ColorSwap;

import states.StoryMenuState;
import states.OutdatedState;
import states.MainMenuState;

typedef TitleData =
{
	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Float
}

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var credTextShitMic:AlphabetMic;
	var textGroup:FlxGroup;
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);
	var ngSpr:FlxSprite;
	var hplogo:FlxSprite;
	
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;
	var FNF_Logo:FlxSprite;
	var FNF_EX:FlxSprite;

	var Timer:Float = 0;

	#if TITLE_SCREEN_EASTER_EGG
	var easterEggKeys:Array<String> = [
		'SHADOW', 'RIVER', 'BBPANZU'
	];
	var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var easterEggKeysBuffer:String = '';
	#end

	var titleJSON:TitleData;

	override public function create():Void
	{
		Language.init();
		Paths.clearStoredMemory();
		Language.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		super.create();

		// IGNORE THIS!!!
		titleJSON = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		#if TITLE_SCREEN_EASTER_EGG
		if (FlxG.save.data.psychDevsEasterEgg == null) FlxG.save.data.psychDevsEasterEgg = ''; //Crash prevention
		switch(FlxG.save.data.psychDevsEasterEgg.toUpperCase())
		{
			case 'SHADOW':
				titleJSON.gfx += 210;
				titleJSON.gfy += 40;
			case 'RIVER':
				titleJSON.gfx += 180;
				titleJSON.gfy += 40;
			case 'BBPANZU':
				titleJSON.gfx += 45;
				titleJSON.gfy += 100;
		}
		#end

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			if (initialized)
				startIntro();
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startIntro();
				});
			}
		}
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			if(FlxG.sound.music == null) {
				if(ClientPrefs.data.styleEngine == 'Kade')
					FlxG.sound.playMusic(Paths.music('freakyMenuKE'), 0);
				else if(ClientPrefs.data.styleEngine == 'Touhou')
					FlxG.sound.playMusic(Paths.music('freakyMenuTH'), 0);
				else
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			}
		}

		if(ClientPrefs.data.styleEngine != 'Touhou')
			Conductor.bpm = titleJSON.bpm;
		else
			Conductor.bpm = 150;
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();
		bg.antialiasing = ClientPrefs.data.antialiasing;

		if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.length > 0 && titleJSON.backgroundSprite != "none"){
			bg.loadGraphic(Paths.image(titleJSON.backgroundSprite));
		}else{
			bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		}

		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		if (ClientPrefs.data.styleEngine == 'MicUp') {
			logoBl = new FlxSprite(142, -17);
			logoBl.frames = Paths.getSparrowAtlas('logoBumpin');

			logoBl.antialiasing = ClientPrefs.data.antialiasing;
			logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
			logoBl.animation.play('bump');
			logoBl.updateHitbox();
			// logoBl.screenCenter();
			// logoBl.color = FlxColor.BLACK;
			logoBl.visible = false;
		} else if(ClientPrefs.data.styleEngine == 'Touhou'){
			logoBl = new FlxSprite(0, 0);
			logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
			logoBl.antialiasing = ClientPrefs.data.antialiasing;

			logoBl.screenCenter();

			logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
			logoBl.animation.play('bump');
			logoBl.updateHitbox();
		} else if (ClientPrefs.data.styleEngine != 'Kade') {
			logoBl = new FlxSprite(-1500, titleJSON.titley);
			logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
			logoBl.antialiasing = ClientPrefs.data.antialiasing;

			logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
			logoBl.animation.play('bump');
			logoBl.updateHitbox();
			// logoBl.screenCenter();
			// logoBl.color = FlxColor.BLACK;
		} else if (ClientPrefs.data.styleEngine == 'Kade') {
			var rA:Bool = true;
			logoBl = new FlxSprite(-120, 1500);
			logoBl.frames = Paths.getSparrowAtlas('KadeEngineLogoBumpin');
			logoBl.antialiasing = ClientPrefs.data.antialiasing;
			logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
			logoBl.animation.play('bump');
			logoBl.updateHitbox();
		} 
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		if(ClientPrefs.data.shaders) swagShader = new ColorSwap();
		if(ClientPrefs.data.styleEngine != 'MicUp')
			gfDance = new FlxSprite(1500, titleJSON.gfy);
		else
			gfDance = new FlxSprite(FlxG.width * 0.35, FlxG.height * 1.2);
		gfDance.antialiasing = ClientPrefs.data.antialiasing;

		var easterEgg:String = FlxG.save.data.psychDevsEasterEgg;
		if(easterEgg == null) easterEgg = ''; //html5 fix

		switch(easterEgg.toUpperCase())
		{
			// IGNORE THESE, GO DOWN A BIT
			#if TITLE_SCREEN_EASTER_EGG
			case 'SHADOW':
				gfDance.frames = Paths.getSparrowAtlas('ShadowBump');
				gfDance.animation.addByPrefix('danceLeft', 'Shadow Title Bump', 24);
				gfDance.animation.addByPrefix('danceRight', 'Shadow Title Bump', 24);
			case 'RIVER':
				gfDance.frames = Paths.getSparrowAtlas('RiverBump');
				gfDance.animation.addByIndices('danceLeft', 'River Title Bump', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				gfDance.animation.addByIndices('danceRight', 'River Title Bump', [29, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			case 'BBPANZU':
				gfDance.frames = Paths.getSparrowAtlas('BBBump');
				gfDance.animation.addByIndices('danceLeft', 'BB Title Bump', [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27], "", 24, false);
				gfDance.animation.addByIndices('danceRight', 'BB Title Bump', [27, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "", 24, false);
			#end

			default:
			//EDIT THIS ONE IF YOU'RE MAKING A SOURCE CODE MOD!!!!
			//EDIT THIS ONE IF YOU'RE MAKING A SOURCE CODE MOD!!!!
			//EDIT THIS ONE IF YOU'RE MAKING A SOURCE CODE MOD!!!!
				gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
				gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		}

		add(gfDance);
		if(ClientPrefs.data.styleEngine != 'MicUp')
			add(logoBl);
		if(swagShader != null)
		{
			gfDance.shader = swagShader.shader;
			logoBl.shader = swagShader.shader;
		}

		if(ClientPrefs.data.styleEngine != 'MicUp')
			titleText = new FlxSprite(titleJSON.startx, 1500);
		else
			titleText = new FlxSprite(titleJSON.startx, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		var animFrames:Array<FlxFrame> = [];
		@:privateAccess {
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}
		
		if (animFrames.length > 0) {
			newTitle = true;
			
			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', ClientPrefs.data.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else {
			newTitle = false;
			
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		if(ClientPrefs.data.styleEngine != 'MicUp')
			add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.antialiasing = ClientPrefs.data.antialiasing;
		logo.screenCenter();
		// add(logo);

		if (ClientPrefs.data.styleEngine != 'Kade' && ClientPrefs.data.styleEngine != 'MicUp')
			FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		if (ClientPrefs.data.styleEngine == 'MicUp') {
			gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x553D0468, 0xAABF1943], 1, 90, true);
			gradientBar.y = FlxG.height - gradientBar.height;
			gradientBar.scale.y = 0;
			gradientBar.updateHitbox();
			add(gradientBar);
			gradientBar.shader = swagShader.shader;
			FlxTween.tween(gradientBar, {'scale.y': 1.3}, 4, {ease: FlxEase.quadInOut});

			add(logoBl);
			logoBl.visible = false;
			add(titleText);
			titleText.visible = false;
		}

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		credTextShitMic = new AlphabetMic(0, 0, "", true);
		credTextShitMic.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;
		credTextShitMic.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.data.antialiasing;

		hplogo = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('hplogo'));
		add(hplogo);
		hplogo.visible = false;
		hplogo.setGraphicSize(Std.int(ngSpr.width * 0.8));
		hplogo.updateHitbox();
		hplogo.screenCenter(X);
		hplogo.antialiasing = ClientPrefs.data.antialiasing;

		FNF_Logo = new FlxSprite(0, 0).loadGraphic(Paths.image('FNF_Logo'));
		FNF_EX = new FlxSprite(0, 0).loadGraphic(Paths.image('FNF_MU'));
		add(FNF_EX);
		add(FNF_Logo);
		FNF_EX.shader = swagShader.shader;
		FNF_Logo.shader = swagShader.shader;
		FNF_EX.scale.set(0.6, 0.6);
		FNF_Logo.scale.set(0.6, 0.6);
		FNF_EX.updateHitbox();
		FNF_Logo.updateHitbox();
		FNF_EX.antialiasing = true;
		FNF_Logo.antialiasing = true;

		FNF_EX.x = -1500;
		FNF_EX.y = 300;
		FNF_Logo.x = -1500;
		FNF_Logo.y = 300;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});
		FlxTween.tween(credTextShitMic, {y: credTextShitMic.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		Paths.clearUnusedMemory();
		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		#if MODS_ALLOWED
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt', Paths.getSharedPath());
		#else
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		#end
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT || FlxG.mouse.justPressed;
		var pressedESC:Bool = controls.BACK;

		if (skippedIntro)
			logoBl.angle = Math.sin(Timer / 270) * 5 / (ClientPrefs.data.framerate / 60);

		Timer += 1;
		gradientBar.scale.y += Math.sin(Timer / 10) * 0.001 / (ClientPrefs.data.framerate / 60);
		gradientBar.updateHitbox();
		gradientBar.y = FlxG.height - gradientBar.height;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		
		if (newTitle) {
			titleTimer += FlxMath.bound(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;
				
				timer = FlxEase.quadInOut(timer);
				
				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}
			
			if(pressedEnter)
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;
				
				if(titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				if(ClientPrefs.data.styleEngine == 'MicUp' || ClientPrefs.data.styleEngine == 'Psych') {
					FlxTween.tween(gfDance, {x: 1500}, 0.8, {
						ease: FlxEase.expoIn
					});
					FlxTween.tween(logoBl, {x: -1500}, 0.8, {
						ease: FlxEase.expoIn
					});
					FlxTween.tween(titleText, {y: 1500}, 0.8, {
						ease: FlxEase.expoIn
					});
				}
				// FlxG.sound.music.stop();

				new FlxTimer().start(1, function(tmr:FlxTimer) { MusicBeatState.switchState(new MainMenuState()); closedState = true; });
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
			if (pressedESC) {
				FlxG.sound.music.fadeOut(0.8);
				if (FreeplayState.vocals != null) {
					FreeplayState.vocals.fadeOut(0.8);
					FreeplayState.vocals = null;
				}
				if(ClientPrefs.data.styleEngine == 'MicUp'){
					FlxTween.tween(gfDance, {x: 1500}, 0.8, {
						ease: FlxEase.expoInOut
					});
					FlxTween.tween(logoBl, {x: -1500}, 0.8, {
						ease: FlxEase.expoInOut
					});
					FlxTween.tween(titleText, {y: 1500}, 0.8, {
						ease: FlxEase.expoInOut
					});
				}

				new FlxTimer().start(1, function(tmr:FlxTimer) {
					trace('Exited Game!');
					Sys.exit(1);
				});
			}
			#if TITLE_SCREEN_EASTER_EGG
			else if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
			{
				var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
				var keyName:String = Std.string(keyPressed);
				if(allowedKeys.contains(keyName)) {
					easterEggKeysBuffer += keyName;
					if(easterEggKeysBuffer.length >= 32) easterEggKeysBuffer = easterEggKeysBuffer.substring(1);
					//trace('Test! Allowed Key pressed!!! Buffer: ' + easterEggKeysBuffer);

					for (wordRaw in easterEggKeys)
					{
						var word:String = wordRaw.toUpperCase(); //just for being sure you're doing it right
						if (easterEggKeysBuffer.contains(word))
						{
							//trace('YOOO! ' + word);
							if (FlxG.save.data.psychDevsEasterEgg == word)
								FlxG.save.data.psychDevsEasterEgg = '';
							else
								FlxG.save.data.psychDevsEasterEgg = word;
							FlxG.save.flush();

							FlxG.sound.play(Paths.sound('ToggleJingle'));

							var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
							black.alpha = 0;
							add(black);

							FlxTween.tween(black, {alpha: 1}, 1, {onComplete:
								function(twn:FlxTween) {
									FlxTransitionableState.skipNextTransIn = true;
									FlxTransitionableState.skipNextTransOut = true;
									MusicBeatState.switchState(new TitleState());
								}
							});
							FlxG.sound.music.fadeOut();
							if(FreeplayState.vocals != null)
							{
								FreeplayState.vocals.fadeOut();
							}
							closedState = true;
							transitioning = true;
							playJingle = true;
							easterEggKeysBuffer = '';
							break;
						}
					}
				}
			}
			#end
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, FlxMath.bound(1 - (elapsed * 3.125), 0, 1));

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function createCoolTextMic(textArray:Array<String>) {
		for (i in 0...textArray.length) {
			var money:AlphabetMic = new AlphabetMic(0, 0, textArray[i], true, false);
			money.x = -1500;
			FlxTween.quadMotion(money, -300, -100, 30 + (i * 70), 150 + (i * 130), 100 + (i * 70), 80 + (i * 130), 0.4, true, {ease: FlxEase.quadInOut});
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreTextMic(text:String, ?offset:Float = 0) {
		var coolText:AlphabetMic = new AlphabetMic(0, 0, text, true, false);
		coolText.x = -1500;
		coolText.y = offset;
		FlxTween.quadMotion(coolText, -300, -100, 10
			+ (textGroup.length * 40), 150
			+ (textGroup.length * 130), 30
			+ (textGroup.length * 40),
			80
			+ (textGroup.length * 130), 0.4, true, {
				ease: FlxEase.quadInOut
			});
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function addMoreTextNew(text:String, tweens:Float = 0, ?offset:Float = 0) {
		if (textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			var ran = FlxG.random.bool(50);
			if (ran)
				coolText.x = -1500;
			else
				coolText.x = 1500;

			FlxTween.tween(coolText, {x: tweens}, 0.4, {
				ease: FlxEase.expoInOut
			});

			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if (FlxG.camera.zoom < 1.35 && ClientPrefs.data.camZooms)
		{
			if (ClientPrefs.data.styleEngine != 'Touhou')
				FlxG.camera.zoom += 0.02;
			else
				FlxG.camera.zoom += 0.01;
		}

		if(logoBl != null)
			logoBl.animation.play('bump', true);

		if(gfDance != null) {
			danceLeft = !danceLeft;
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					//FlxG.sound.music.stop();
					if(ClientPrefs.data.styleEngine == 'Kade')
						FlxG.sound.playMusic(Paths.music('freakyMenuKE'), 0);
					else if(ClientPrefs.data.styleEngine == 'Touhou')
						FlxG.sound.playMusic(Paths.music('freakyMenuTH'), 0);
					else
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					if (ClientPrefs.data.styleEngine == 'Psych') {
						addMoreTextNew('To Funkin Engine', 301);
						addMoreTextNew('By', 589.5);
					} else if (ClientPrefs.data.styleEngine == 'Kade')
						createCoolText(['Kade Engine', 'By']);
					else if (ClientPrefs.data.styleEngine == 'Vanilla')
						createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
					else if (ClientPrefs.data.styleEngine == 'MicUp')
						createCoolTextMic(["Mic'd up Engine", "By"]);
					else if(ClientPrefs.data.styleEngine == 'Touhou')
						createCoolText(["Touhou Project", "Copyright"]);

				case 4:
					if (ClientPrefs.data.styleEngine == 'Psych')
						addMoreTextNew('Comes_FromBack', 321);
					else if (ClientPrefs.data.styleEngine == 'Kade')
						addMoreText('Kadedeveloper', 40);
					else if (ClientPrefs.data.styleEngine == 'Vanilla')
						addMoreText('present');
					else if (ClientPrefs.data.styleEngine == 'MicUp') {
						addMoreTextMic('Verwex');
						addMoreTextMic('Kadedev', 15);
						addMoreTextMic('Ash237', 30);
					} else if(ClientPrefs.data.styleEngine == 'Touhou') {
						addMoreText('ZUN');
						addMoreText('All right reserved', 80);
					}
				case 5:
					deleteCoolText();
				case 6:
					if (ClientPrefs.data.styleEngine == 'Kade' || ClientPrefs.data.styleEngine == 'TouHou')
						createCoolText(['Not associated', 'with'], -40);
					else if (ClientPrefs.data.styleEngine == 'Psych') {
						addMoreTextNew('Not associated', 305.5, -40);
						addMoreTextNew('with', 554, -40);
					} else if (ClientPrefs.data.styleEngine == 'MicUp')
						createCoolTextMic(['Not associated', 'with']);
					else
						createCoolText(['In association', 'with'], -40);
				case 8:
					if (ClientPrefs.data.styleEngine == 'MicUp')
						addMoreTextMic('newgrounds', -40);
					else if (ClientPrefs.data.styleEngine == 'Psych')
						addMoreTextNew('newgrounds', 394.5, -20);
					else
						addMoreText('newgrounds', -40);

					ngSpr.visible = true;
				case 9:
					deleteCoolText();
					ngSpr.visible = false;
				case 10:
					if (ClientPrefs.data.styleEngine == 'MicUp')
						createCoolTextMic([curWacky[0]]);
					/*else if (ClientPrefs.data.styleEngine == 'Psych')
						addMoreTextNew(curWacky[0], 480.5); */
					else
						createCoolText([curWacky[0]]);
				case 12:
					if (ClientPrefs.data.styleEngine == 'MicUp')
						addMoreTextMic(curWacky[1]);
					else
						addMoreText(curWacky[1]);
				case 13:
					if(ClientPrefs.data.styleEngine == 'MicUp')
						FlxTween.tween(FNF_Logo, {y: 120, x: 210}, 0.8, {ease: FlxEase.backOut});
					deleteCoolText();
				case 14:
					if (ClientPrefs.data.styleEngine == 'Psych')
						addMoreTextNew('Friday', 490.5);
					else if (ClientPrefs.data.styleEngine != 'Touhou')
						addMoreText('Friday');
					else
						addMoreText('TH15 By');
				case 15:
					if (ClientPrefs.data.styleEngine == 'MicUp')
						FlxTween.tween(FNF_EX, {y: 48, x: 403}, 0.8, {ease: FlxEase.backOut});
					else if (ClientPrefs.data.styleEngine == 'Psych')
						addMoreTextNew('Night', 523.5);
					else if (ClientPrefs.data.styleEngine != 'Touhou')
						addMoreText('Night');
				case 16:
					if (ClientPrefs.data.styleEngine == 'Psych'){
						addMoreTextNew('Funkin', 506.5);
						addMoreTextNew('To Funkin Engine(DEMO)', 171);
					} else if (ClientPrefs.data.styleEngine != 'Touhou')
						addMoreText('Funkin'); // credTextShit.text += '\nFunkin';
					else 
						hplogo.visible = true;

					if (ClientPrefs.data.styleEngine == 'Kade')
						addMoreText('Kade Engine');
				case 17:
					if (ClientPrefs.data.styleEngine != 'Touhou')
						skipIntro();
				case 20:
					if(ClientPrefs.data.styleEngine == 'Touhou'){
						deleteCoolText();
						hplogo.visible = false;
					}
				case 21:
					if(ClientPrefs.data.styleEngine == 'Touhou')
						addMoreText('Friday');
				case 22:
					if(ClientPrefs.data.styleEngine == 'Touhou')
						addMoreText('Night');
				case 23:
					if(ClientPrefs.data.styleEngine == 'Touhou')
						addMoreText('Funkin');
				case 24:
					if(ClientPrefs.data.styleEngine == 'Touhou')
						addMoreText('TouHou Style');
				case 26:
					if(ClientPrefs.data.styleEngine == 'Touhou')
						skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(FNF_Logo);
			remove(FNF_EX);
			if(ClientPrefs.data.styleEngine != 'MicUp') {
				FlxTween.tween(gfDance, {x: titleJSON.gfx}, 0.8, {
					ease: FlxEase.expoInOut
				});
				FlxTween.tween(logoBl, {x: titleJSON.titlex}, 0.8, {
					ease: FlxEase.expoInOut
				});
				FlxTween.tween(titleText, {y: titleJSON.starty}, 0.8, {
					ease: FlxEase.expoInOut
				});
			} else {

			}

			if(ClientPrefs.data.styleEngine == 'Touhou')
				gfDance.visible = false;

			if (ClientPrefs.data.styleEngine == 'Kade') {
				FlxTween.tween(logoBl, {y: -100}, 1.4, {ease: FlxEase.expoInOut});

				logoBl.angle = -4;

				new FlxTimer().start(0.01, function(tmr:FlxTimer) {
					if (logoBl.angle == -4)
						FlxTween.angle(logoBl, logoBl.angle, 4, 4, {ease: FlxEase.quartInOut});
					if (logoBl.angle == 4)
						FlxTween.angle(logoBl, logoBl.angle, -4, 4, {ease: FlxEase.quartInOut});
				}, 0);
			}
			if (playJingle) //Ignore daze
			{
				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null) easteregg = '';
				easteregg = easteregg.toUpperCase();

				var sound:FlxSound = null;
				switch(easteregg)
				{
					case 'RIVER':
						sound = FlxG.sound.play(Paths.sound('JingleRiver'));
					case 'SHADOW':
						FlxG.sound.play(Paths.sound('JingleShadow'));
					case 'BBPANZU':
						sound = FlxG.sound.play(Paths.sound('JingleBB'));

					default: //Go back to normal ugly ass boring GF
						remove(ngSpr);
						remove(credGroup);
						FlxG.camera.flash(FlxColor.WHITE, 2);
						skippedIntro = true;
						playJingle = false;

						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						return;
				}

				transitioning = true;
				if(easteregg == 'SHADOW')
				{
					new FlxTimer().start(3.2, function(tmr:FlxTimer)
					{
						remove(ngSpr);
						remove(credGroup);
						FlxG.camera.flash(FlxColor.WHITE, 0.6);
						transitioning = false;
					});
				}
				else
				{
					remove(ngSpr);
					remove(credGroup);
					FlxG.camera.flash(FlxColor.WHITE, 3);
					sound.onComplete = function() {
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						transitioning = false;
					};
				}
				playJingle = false;
			}
			else //Default! Edit this one!!
			{
				remove(ngSpr);
				remove(credGroup);
				FlxG.camera.flash(FlxColor.WHITE, 4);

				if(ClientPrefs.data.styleEngine == 'MicUp') {
					FlxTween.tween(logoBl, {
						'scale.x': 0.45,
						'scale.y': 0.45,
						x: -165,
						y: -125
					}, 1.3, {ease: FlxEase.expoInOut, startDelay: 1.3});
					FlxTween.tween(gfDance, {y: 20}, 2.3, {ease: FlxEase.expoInOut, startDelay: 0.8});
				}

				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null) easteregg = '';
				easteregg = easteregg.toUpperCase();
				#if TITLE_SCREEN_EASTER_EGG
				if(easteregg == 'SHADOW')
				{
					FlxG.sound.music.fadeOut();
					if(FreeplayState.vocals != null)
					{
						FreeplayState.vocals.fadeOut();
					}
				}
				#end
			}
			skippedIntro = true;
			titleText.visible = true;
			logoBl.visible = true;
		}
	}
}
