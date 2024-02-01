package objects;

import flixel.group.FlxGroup;
import flixel.ui.FlxBar;
import flixel.util.FlxStringUtil;
import states.FreeplayState;

/**
 * Music player used for Freeplay
 */
@:access(states.FreeplayState)
class MusicPlayer extends FlxGroup 
{
	public var instance:FreeplayState;

	public var playing(get, never):Bool;
	public var paused(get, never):Bool;

	public var playingMusic:Bool = false;
	public var curTime:Float;

	var songBG:FlxSprite;
	var songTxt:FlxText;
	var timeTxt:FlxText;
	var progressBar:FlxBar;
	
	var wasPlaying:Bool;

	var holdPitchTime:Float = 0;

	public function new(instance:FreeplayState)
	{
		super();

		this.instance = instance;

		var xPos:Float = FlxG.width * 0.7;

		songBG = new FlxSprite(xPos - 6, 0).makeGraphic(1, 100, 0xFF000000);
		songBG.alpha = 0.6;
		add(songBG);
		
		songTxt = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		songTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		add(songTxt);

		timeTxt = new FlxText(xPos, songTxt.y + 60, 0, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		add(timeTxt);

		for (i in 0...2)
		{
			var text:FlxText = new FlxText();
			text.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, CENTER);
			text.text = '^';
			if (i == 1)
				text.flipY = true;
			text.visible = false;
			add(text);
		}

		progressBar = new FlxBar(timeTxt.x, timeTxt.y + timeTxt.height, LEFT_TO_RIGHT, Std.int(timeTxt.width), 8, null, "", 0, Math.POSITIVE_INFINITY);
		progressBar.createFilledBar(FlxColor.WHITE, FlxColor.BLACK);
		add(progressBar);

		switchPlayMusic();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!playingMusic)
		{
			return;
		}

		if (paused && !wasPlaying)
			songTxt.text = '${language.States.Free.song_player.playing}${instance.songs[FreeplayState.curSelected].songName}${language.States.Free.song_player.pause}';
		else
			songTxt.text = '${language.States.Free.song_player.playing}${instance.songs[FreeplayState.curSelected].songName}';

		positionSong();

		if (instance.controls.UI_LEFT_P)
		{
			if (playing)
				wasPlaying = true;

			pauseOrResume();

			curTime = FlxG.sound.music.time - 1000;
			instance.holdTime = 0;

			if (curTime < 0)
				curTime = 0;

			FlxG.sound.music.time = curTime;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.time = curTime;
		}
		if (instance.controls.UI_RIGHT_P)
		{
			if (playing)
				wasPlaying = true;

			pauseOrResume();

			curTime = FlxG.sound.music.time + 1000;
			instance.holdTime = 0;

			if (curTime > FlxG.sound.music.length)
				curTime = FlxG.sound.music.length;

			FlxG.sound.music.time = curTime;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.time = curTime;
		}
	
		updateTimeTxt();

		if(instance.controls.UI_LEFT || instance.controls.UI_RIGHT)
		{
			instance.holdTime += elapsed;
			if(instance.holdTime > 0.5)
			{
				curTime += 40000 * elapsed * (instance.controls.UI_LEFT ? -1 : 1);
			}

			var difference:Float = Math.abs(curTime - FlxG.sound.music.time);
			if(curTime + difference > FlxG.sound.music.length) curTime = FlxG.sound.music.length;
			else if(curTime - difference < 0) curTime = 0;

			FlxG.sound.music.time = curTime;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.time = curTime;

			updateTimeTxt();
		}

		if(instance.controls.UI_LEFT_R || instance.controls.UI_RIGHT_R)
		{
			FlxG.sound.music.time = curTime;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.time = curTime;

			if (wasPlaying)
			{
				pauseOrResume(true);
				wasPlaying = false;
			}

			updateTimeTxt();
		}
		if (FreeplayState.vocals != null && FlxG.sound.music.time > 5)
		{
			var difference:Float = Math.abs(FlxG.sound.music.time - FreeplayState.vocals.time);
			if (difference >= 5 && !paused)
			{
				pauseOrResume();
				FreeplayState.vocals.time = FlxG.sound.music.time;
				pauseOrResume(true);
			}
		}
	
		if (instance.controls.RESET)
		{
			FlxG.sound.music.time = 0;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.time = 0;

			updateTimeTxt();
		}
	}

	public function pauseOrResume(resume:Bool = false) 
	{
		if (resume)
		{
			FlxG.sound.music.resume();
			instance.bottomText.text = language.States.Free.song_player.cons[0];

			if (FreeplayState.vocals != null)
				FreeplayState.vocals.resume();
		}
		else 
		{
			FlxG.sound.music.pause();
			instance.bottomText.text = language.States.Free.song_player.cons[1];

			if (FreeplayState.vocals != null)
				FreeplayState.vocals.pause();
		}
		positionSong();
	}

	public function switchPlayMusic()
	{
		FlxG.autoPause = (!playingMusic && ClientPrefs.data.autoPause);
		active = visible = playingMusic;

		instance.scoreBG.visible = instance.diffText.visible = instance.scoreText.visible = !playingMusic; //Hide Freeplay texts and boxes if playingMusic is true
		songTxt.visible = timeTxt.visible = songBG.visible = progressBar.visible = playingMusic; //Show Music Player texts and boxes if playingMusic is true
		
		holdPitchTime = 0;
		instance.holdTime = 0;

		if (playingMusic)
		{
			instance.bottomText.text = language.States.Free.song_player.cons[0];
			positionSong();
			
			progressBar.setRange(0, FlxG.sound.music.length);
			progressBar.setParent(FlxG.sound.music, "time");
			progressBar.numDivisions = 1600;

			updateTimeTxt();
		}
		else
		{
			progressBar.setRange(0, Math.POSITIVE_INFINITY);
			progressBar.setParent(null, "");
			progressBar.numDivisions = 0;

			instance.bottomText.text = instance.bottomString;
			instance.positionHighscore();
		}
		progressBar.updateBar();
	}

	function positionSong() 
	{
		var length:Int = instance.songs[FreeplayState.curSelected].songName.length;
		var shortName:Bool = length < 5; // Fix for song names like Ugh, Guns
		songTxt.x = FlxG.width - songTxt.width - 6;
		if (shortName)
			songTxt.x -= 10 * length - length;
		songBG.scale.x = FlxG.width - songTxt.x + 12;
		if (shortName) 
			songBG.scale.x += 6 * length;
		songBG.x = FlxG.width - (songBG.scale.x / 2);
		timeTxt.x = Std.int(songBG.x + (songBG.width / 2));
		timeTxt.x -= timeTxt.width / 2;
		if (shortName)
			timeTxt.x -= length - 5;

		progressBar.setGraphicSize(Std.int(songTxt.width), 5);
		progressBar.y = songTxt.y + songTxt.height + 10;
		progressBar.x = songTxt.x + songTxt.width / 2 - 15;
		if (shortName)
		{
			progressBar.scale.x += length / 2;
			progressBar.x -= length - 10;
		}
	}

	function updateTimeTxt()
	{
		var text = FlxStringUtil.formatTime(FlxG.sound.music.time / 1000, false) + ' / ' + FlxStringUtil.formatTime(FlxG.sound.music.length / 1000, false);
		timeTxt.text = '< ' + text + ' >';
	}

	function get_playing():Bool 
	{
		return FlxG.sound.music.playing;
	}

	function get_paused():Bool 
	{
		@:privateAccess return FlxG.sound.music._paused;
	}
}
