package backend;

import sys.io.File;
import backend.Controls;
import flixel.FlxG;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileReference;
import haxe.Json;
import flixel.input.keyboard.FlxKey;
import openfl.utils.Dictionary;

class Ana
{
	public var hitTime:Float;
	public var nearestNote:Array<Dynamic>;
	public var hit:Bool;
	public var hitJudge:String;
	public var key:Int;

	public function new(_hitTime:Float, _nearestNote:Array<Dynamic>, _hit:Bool, _hitJudge:String, _key:Int)
	{
		hitTime = _hitTime;
		nearestNote = _nearestNote;
		hit = _hit;
		hitJudge = _hitJudge;
		key = _key;
	}
}

class Analysis
{
	public var anaArray:Array<Ana>;

	public function new()
	{
		anaArray = [];
	}
}

typedef ReplayJSON =
{
	public var replayGameVer:String;
	public var timestamp:Date;
	public var songName:String;
	public var songDiff:Int;
	public var songNotes:Array<Dynamic>;
	public var songJudgements:Array<String>;
	public var noteSpeed:Float;
	public var week:Int;
	public var chartPath:String;
	public var isDownscroll:Bool;
	public var sf:Int;
	public var ana:Analysis;
	public var keysarray:Array<Dynamic>;
}

class Replay
{
	public static var version:String = "ToFunkin-1.0"; // replay file version

	public var path:String = "";
	public var replay:ReplayJSON;

	public function new(path:String)
	{
		this.path = path;
		replay = {
			songName: "Null Song Found",
			songDiff: 1,
			noteSpeed: 1.5,
			isDownscroll: false,
			songNotes: [],
			replayGameVer: version,
			chartPath: "",
			week: 0,
			timestamp: Date.now(),
			sf: Std.int(ClientPrefs.data.safeFrames),
			ana: new Analysis(),
			songJudgements: [],
			keysarray: []
		};
	}

	public static function LoadReplay(path:String):Replay
	{
		var rep:Replay = new Replay(path);

		rep.LoadFromJSON();

		trace('basic replay data:\nSong Name: ' + rep.replay.songName + '\nSong Diff: ' + rep.replay.songDiff);

		return rep;
	}

	/*public static function existReplays(?bm:Bool = false, ?paths:Bool = false):Dynamic {
		var path:String = 'assets/replays/tfe10_';
		var ret:Dynamic = null;
		for(i in 0...ClientPrefs.data.replayNum) {
			if(!FileSystem.exists('$path$i.rep')) {
				if(!bm)
					ret = i;
				else if(!bm && !paths)
					ret = false;

				if(paths)
					ret = path+i+'.rep';
				
			}
		}
		trace(ret);
		return ret;
	}*/

	public function SaveReplay(notearray:Array<Dynamic>, judge:Array<String>, ana:Analysis, keysarray:Array<Dynamic>)
	{
		if (!FileSystem.isDirectory('assets/replays'))
			FileSystem.createDirectory('assets/replays');

		var chartPath = "";

		var json = {
			"songName": PlayState.SONG.song,
			"songDiff": PlayState.storyDifficulty,
			"chartPath": chartPath,
			"timestamp": Date.now(),
			"replayGameVer": version,
			"week": PlayState.storyWeek,
			"sf": Std.int(ClientPrefs.data.safeFrames),
			"noteSpeed": (ClientPrefs.getGameplaySetting('scrollspeed') > 1 ? ClientPrefs.getGameplaySetting('scrollspeed') : PlayState.SONG.speed),
			"isDownscroll": ClientPrefs.data.downScroll,
			"songNotes": notearray,
			"songJudgements": judge,
			"ana": ana,
			"keys": keysarray
		};

		var data:String = Json.stringify(json, null, "");

		var time = Date.now().getTime();

		try {
			if (!FileSystem.isDirectory('assets/replays/${PlayState.SONG.song}')) FileSystem.createDirectory('assets/replays/${PlayState.SONG.song}');
			File.saveContent('assets/replays/${PlayState.SONG.song}/${PlayState.SONG.song}-${PlayState.storyDifficulty}_$time.rep', data);
		} catch(e:Dynamic) {trace(e);}

		path = '${PlayState.SONG.song}/${PlayState.SONG.song}-${PlayState.storyDifficulty}_$time.rep'; // for score screen shit

		LoadFromJSON();

		replay.ana = ana;
	}

	public function LoadFromJSON()
	{
		trace('loading ' + Sys.getCwd() + 'assets/replays/' + path + ' replay...');
		try
		{
			var repl:ReplayJSON = Json.parse(File.getContent(Sys.getCwd() + "assets/replays/" + path));
			replay = repl;
		}
		catch (e)
		{
			trace('failed!\n' + e.message);
		}
	}
}
