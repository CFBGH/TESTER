package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;
import sys.io.File;
import sys.FileSystem;
import substates.Survival_GameOptions;
import substates.Survival_Substate;

using StringTools;

typedef SurvivalVars =
{
	var songNames:Array<String>;
	var songDifficulties:Array<String>;
}

class MenuSurvival extends MusicBeatState
{
	public static var _survival:SurvivalVars;

	var bg:FlxSprite = new FlxSprite(-89).loadGraphic(Paths.image('sBG_Main'));
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Survival_Checker'), FlxAxes.XY, 0.2, 0.2);
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);
	var side:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('Survival_Side'));

    public static var curSelected:Int = 0;

	public var targetY:Float = 0;
	public var targetX:Float = 0;
	var camLerp:Float = 0.1;
	var selectable:Bool = false;

    var songs:Array<SongTitlesS> = [];

	public static var curDifficulty:Int = 2;

    private var grpSongs:FlxTypedGroup<MicAlphabet>;
	var sprDifficulty:FlxSprite;

	public static var substated:Bool = false;
	public static var no:Bool = false;
	private var camGame:FlxCamera;
	public var camOther:FlxCamera;
	var tracksUsed:FlxText;

    override function create()
    {
		camGame = new FlxCamera();
		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0;
		
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;
		substated = false;
		no = false;

		PlayState.isStoryMode = false;
		PlayState.isEndless = false;
		PlayState.isMarathon = false;
		PlayState.isFreeplay = false;
		PlayState.isSurvival = true;

        lime.app.Application.current.window.title = lime.app.Application.current.meta.get('name');

		loadCurrent();
		Survival_GameOptions.load();

		PlayState.timeLeftOver = 0;

        persistentUpdate = persistentDraw = true;

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			songs.push(new SongTitlesS(data[0]));
		}

		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.03;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55FFCAA9, 0xAAFFDBF6], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		add(checker);
		checker.scrollFactor.set(0.07, 0.07);

		side.scrollFactor.x = 0;
		side.scrollFactor.y = 0;
		side.x = -20 - side.width;
		side.antialiasing = true;
		add(side);

		grpSongs = new FlxTypedGroup<MicAlphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:MicAlphabet = new MicAlphabet(0, (70 * i) + 30, songs[i].songName, true);
			// songText.itemType = "Vertical";
			songText.targetY = i;
			songText.targetX = -45;
			grpSongs.add(songText);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		tracksUsed = new FlxText(FlxG.width * 0.7, 635, 0, "0 TRACKS USED\nPERSONAL BEST", 20);
		tracksUsed.setFormat(Language.fonts(), 32, FlxColor.WHITE, RIGHT);
		tracksUsed.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		add(tracksUsed);

		var diffTex = Paths.getSparrowAtlas('difficulties');
		sprDifficulty = new FlxSprite(130, 0);
		sprDifficulty.frames = diffTex;
		sprDifficulty.animation.addByPrefix('noob', 'NOOB');
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.addByPrefix('expert', 'EXPERT');
		sprDifficulty.animation.addByPrefix('insane', 'INSANE');
		sprDifficulty.animation.play('easy');
		sprDifficulty.x = 1240 - sprDifficulty.width;
		sprDifficulty.y = tracksUsed.y - sprDifficulty.height - 8;
		add(sprDifficulty);

		changeSelection();
		changeDiff();

		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			selectable = true;
		});

		#if android
		addVirtualPad(UP_DOWN, A_B);
		#else
		if(ClientPrefs.data.tabletmode)
			addVirtualPad(UP_DOWN, A_B);
		#end

		super.create();
		CustomFadeTransition.nextCamera = camOther;

		FlxTween.tween(bg, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
		FlxTween.tween(side, {x: 0}, 0.8, {ease: FlxEase.quartInOut});
		camGame.zoom = 0.6;
		camGame.alpha = 0;
		FlxTween.tween(camGame, {zoom: 1, alpha: 1}, 0.7, {ease: FlxEase.quartInOut});
    }

	var score = Std.int(FlxG.save.data.survivalScore);
	var minutes = Std.int(FlxG.save.data.survivalTime / 1000 / 60);
	var seconds = Std.int((FlxG.save.data.survivalTime / 1000) % 60);
	var milliseconds = Std.int((FlxG.save.data.survivalTime / 10) % 100);

    override function update(elapsed:Float)
    {
		var isTab:Bool = ClientPrefs.data.tabletmode;
        checker.x -= -0.67 / (ClientPrefs.data.framerate/60);
		checker.y -= 0.2 / (ClientPrefs.data.framerate/60);

		tracksUsed.text = PlayState.storyPlaylist.length + '/5 TRACKS USED\nPERSONAL BEST: $minutes:$seconds:$milliseconds - $score';
		tracksUsed.x = 1240 - tracksUsed.width;

        super.update(elapsed);

		var bullShit:Int = 0;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

				var scaledY = FlxMath.remapToRange(item.targetY, 0, 1, 0, 1.3);

				item.y = FlxMath.lerp(item.y, (scaledY * 120) + (FlxG.height * 0.5), 0.16/(ClientPrefs.data.framerate / 60));
				item.x = FlxMath.lerp(item.x, (targetY * 0) + 308, 0.16/(ClientPrefs.data.framerate / 60));
				item.x += -45/(ClientPrefs.data.framerate / 60);
		}

        var upP = controls.UI_UP_P || (isTab && MusicBeatState._virtualpad.buttonUp.justPressed);
		var downP = controls.UI_DOWN_P || (isTab && MusicBeatState._virtualpad.buttonDown.justPressed);
		var accepted = controls.ACCEPT || (isTab && MusicBeatState._virtualpad.buttonA.justPressed);
		var back = controls.BACK || (isTab && MusicBeatState._virtualpad.buttonB.justPressed);

		if (selectable && !substated)
		{
			if (upP)
				changeSelection(-1);
			if (downP)
				changeSelection(1);

			if (controls.UI_LEFT_P)
				changeDiff(-1);
			if (controls.UI_RIGHT_P)
				changeDiff(1);

			if (back)
				{
					substated = true;
	
					FlxG.sound.play(PathsList.themeSound('cancelMenu'), ClientPrefs.data.soundVolume);
	
					FlxG.state.openSubState(new Survival_Substate());
				}

			if (accepted)
				{
					if (PlayState.difficultyPlaylist.length < 5)
					{
						PlayState.difficultyPlaylist.push(Std.string(curDifficulty));
						PlayState.storyPlaylist.push(Std.string(songs[curSelected].songName.toLowerCase()));
		
						FlxG.sound.play(PathsList.themeSound('confirmMenu'), ClientPrefs.data.soundVolume);
		
						saveCurrent();
					}
					else
						FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, 'shared'), FlxG.random.float(0.5, 0.7));
				}
		}

		if (no)
			{
				bg.kill();
				gradientBar.kill();
				checker.kill();
				sprDifficulty.kill();
				grpSongs.clear();
				tracksUsed.kill();
				side.kill();
			}
    }

    function changeDiff(change:Int = 0)
        {
            curDifficulty += change;
    
            if (curDifficulty < 0)
                curDifficulty = 5;
            if (curDifficulty > 5)
                curDifficulty = 0;
    
            switch (curDifficulty)
            {
                case 0:
                    sprDifficulty.animation.play('noob');
                case 1:
                    sprDifficulty.animation.play('easy');
                case 2:
                    sprDifficulty.animation.play('normal');
                case 3:
                    sprDifficulty.animation.play('hard');
                case 4:
                    sprDifficulty.animation.play('expert');
                case 5:
                    sprDifficulty.animation.play('insane');
            }
    
            sprDifficulty.alpha = 0;
    
            sprDifficulty.y = tracksUsed.y - sprDifficulty.height - 38;
            FlxTween.tween(sprDifficulty, {y: tracksUsed.y - sprDifficulty.height - 8, alpha: 1}, 0.04);
            sprDifficulty.x = 1240 - sprDifficulty.width;
        }
    
    function changeSelection(change:Int = 0)
    {
        // NGio.logEvent('Fresh');
        FlxG.sound.play(PathsList.themeSound('scrollMenu'), ClientPrefs.data.soundVolume);
    
        curSelected += change;
    
        if (curSelected < 0)
            curSelected = songs.length - 1;
        if (curSelected >= songs.length)
            curSelected = 0;
    
        var bullShit:Int = 0;
    
        for (item in grpSongs.members)
        {
            item.targetY = bullShit - curSelected;
            bullShit++;
    
            item.alpha = 0.6;
            // item.setGraphicSize(Std.int(item.width * 0.8));
    
        if (item.targetY == 0)
            {
                item.alpha = 1;
                // item.setGraphicSize(Std.int(item.width));
            }
        }
    }

	function loadCurrent()
		{
			if (!FileSystem.isDirectory('presets/survival'))
				FileSystem.createDirectory('presets/survival');
	
			if (!FileSystem.exists('presets/survival/current'))
			{
				_survival = {
					songDifficulties: [],
					songNames: []
				}
	
				File.saveContent(('presets/survival/current'), Json.stringify(_survival, null, '    '));
			}
			else
			{
				var data:String = File.getContent('presets/survival/current');
				_survival = Json.parse(data);
				PlayState.difficultyPlaylist = _survival.songDifficulties;
				PlayState.storyPlaylist = _survival.songNames;
			}
		}
	
	public static function saveCurrent()
		{
			_survival = {
				songDifficulties: PlayState.difficultyPlaylist,
				songNames: PlayState.storyPlaylist
			}
			File.saveContent(('presets/survival/current'), Json.stringify(_survival, null, '    '));
		}
	
	public static function loadPreset(input:String):Void
		{
			var data:String = File.getContent('presets/survival/' + input);
			_survival = Json.parse(data);
	
			PlayState.difficultyPlaylist = _survival.songDifficulties;
			PlayState.storyPlaylist = _survival.songNames;
	
			saveCurrent();
		}
	
	public static function savePreset(input:String):Void
		{
			_survival = {
				songDifficulties: PlayState.difficultyPlaylist,
				songNames: PlayState.storyPlaylist
			}
			File.saveContent(('presets/survival/' + input), Json.stringify(_survival, null, '    ')); // just an example for now
		}
}

class SongTitlesS
{
	public var songName:String = "";

	public function new(song:String)
	{
		this.songName = song;
	}
}