package substates;

import states.StoryMenuState;
import states.FreeplayState;
import states.PlayState;

class ScoreRank extends MusicBeatSubstate {
	public static var deathSoundName:String = 'biu';
	public static var loopSoundName:String = 'gameOverTH';
	var playingDeathSound:Bool = false;
	var bgGrid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x1AE47FDB, 0x0));
	var pauback:FlxSprite = new FlxSprite(80, 200).loadGraphic(Paths.image('touhou/pause_back'));
	var puatit:FlxSprite = new FlxSprite(80, 220).loadGraphic(Paths.image('touhou/pause_tit-go'));
	var pauser:FlxTypedGroup<FlxSprite>;
	var golist:Array<String> = ['rt', 'sr', 'man', 'rg'];
	var curSelected:Int = -1;
	var Timer:Float = 0;
	var bg:FlxSprite;
	public static var colorR:Int;
	public static var colorG:Int;
	public static var colorB:Int;
	var cnum:Int = 5;

    public static var instance:ScoreRank;

    override function create() {
		instance = this;
		PlayState.instance.callOnScripts('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float) {
		super();

		pauser = new FlxTypedGroup<FlxSprite>();
		add(pauser);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(colorR, colorG, colorB));
		add(bg);
		bg.alpha = 0.75;

		bgGrid.velocity.set(175, 175);
		add(bgGrid);

		var credit:FlxText = new FlxText(0, 700, 0, 'Credit $cnum', 25);
		credit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		credit.screenCenter(X);
		add(credit);

		/*if(PlayState.deathCounter > 10) {
			var lol:FlxSprite = new FlxSprite(540, 0).loadGraphic(Paths.image('hello'));
			lol.screenCenter(Y);
			add(lol);
		}*/

		pauback.color = 0xDD1122;
		add(pauback);
		add(puatit);

		for(i in 0...golist.length) {
			var offset:Float = 108 - (Math.max(golist.length, 4) - 4) * 80;
			var item:FlxSprite = new FlxSprite(puatit.x+30, puatit.y+(i*80)+offset-20).loadGraphic(Paths.image('touhou/${golist[i]}'));
			item.alpha = 0.55;
			item.ID = i;
			pauser.add(item);
			item.updateHitbox();
			add(item);
		}

		PlayState.instance.setOnScripts('inGameOver', true);
		Conductor.songPosition = 0;

		FlxG.sound.play(Paths.sound(deathSoundName));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		FlxG.camera.followLerp = 0;
		FlxG.camera.zoom = 1;
	}

	public var startedDeath:Bool = false;

	override function update(elapsed:Float) {
		pauback.angle = Math.sin(Timer / 240) * 5 / (ClientPrefs.data.framerate / 60);
		Timer += 1;

		super.update(elapsed);
		var isTab = ClientPrefs.data.tabletmode;

		PlayState.instance.callOnScripts('onUpdate', [elapsed]);

		if (controls.ACCEPT || (isTab && MusicBeatState._virtualpad.buttonA.justPressed)) {
			switch(curSelected) {
				case 3:
					if (!isEnding) {
						isEnding = true;
						FlxG.sound.music.stop();
						FlxG.sound.play(Paths.sound('extend'));
						new FlxTimer().start(0.2, function(tmr:FlxTimer) {
							FlxG.camera.fade(FlxColor.BLACK, 2, false, function() {
								MusicBeatState.resetState();
							});
						});
						PlayState.instance.callOnScripts('onGameOverConfirm', [true]);
					}
				case 0:
					FlxG.sound.music.stop();
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					PlayState.chartingMode = false;

					Mods.loadTopMod();
					if (PlayState.isStoryMode)
						MusicBeatState.switchState(new StoryMenuState());
					else
						MusicBeatState.switchState(new FreeplayState());

					FlxG.sound.playMusic(Paths.music('freakyMenuTH'));
					PlayState.instance.callOnScripts('onGameOverConfirm', [false]);
				case 1:
					trace('Cannot');
					FlxG.sound.play(Paths.sound('error'));
				case 2:
					trace('not');
					FlxG.sound.play(Paths.sound('error'));
			}
		}

		if (controls.BACK || (isTab && MusicBeatSubstate._virtualpad.buttonB.justPressed)) {
			curSelected = 0;
		}

		if (controls.UI_UP_P){
			FlxG.sound.play(Paths.sound('scrollMenuTH'));
			changeItem(-1);
		}
		if (controls.UI_DOWN_P) {
			FlxG.sound.play(Paths.sound('scrollMenuTH'));
			changeItem(1);
		}

		if (!playingDeathSound) {
			startedDeath = true;
			if (PlayState.SONG.stage == 'tank') {
				playingDeathSound = true;
				coolStartDeath(0.2);

				var exclude:Array<Int> = [];
				// if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];

				FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + FlxG.random.int(1, 25, exclude)), 1, false, null, true, function() {
					if (!isEnding) {
						FlxG.sound.music.fadeIn(0.2, 1, 4);
					}
				});
			} else {
				playingDeathSound = true;
				coolStartDeath();
				FlxG.sound.music.fadeIn(0.2, 1, 4);
			}
		}

		if (FlxG.sound.music.playing) {
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnScripts('onUpdatePost', [elapsed]);
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void {
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function changeItem(huh:Int = 0) {
		curSelected += huh;

		if (curSelected >= pauser.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = pauser.length - 1;

		pauser.forEach(function(spr:FlxSprite) {
			spr.alpha = 0.55;
			spr.color = 0xA0A0A0;
			//spr.shake(0.5, 0.2);
			spr.updateHitbox();

			if (spr.ID == curSelected) {
				spr.alpha = 1;
				spr.color = 0xFFFFFF;
				FlxTween.shake(spr, 0.05, 0.1, FlxAxes.XY);
				spr.centerOffsets();
			}
		});
	}
}
//							_______________________________________________
//						   /											   \
//						  /													\
//						 /													 \
//						/													  \
//______________________________________________________________________________