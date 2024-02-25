package states;

import states.MainMenuState;
import backend.WeekData;
import sys.io.File;
import backend.Highscore;
import openfl.net.FileReference;
import backend.Replay;
import backend.Song;

class ReplayState extends MusicBeatState {
    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG'));
    var textTitle:FlxText = new FlxText(0, 50, 0, 'SELECED REPLAY');
    var textVer:FlxText = new FlxText(2, 705, 0, 'Replay Version1.00');
    var curSelected:Int = -1;
    var two:Bool = false;
    var doing:Bool = false;
    var items:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();
    var menuItems:Array<String>;

    public static var directory:Array<String> = [];
    var files:Array<String> = [];
    public static var selected:String = '';
    var nofile:Bool = false;
    public static var curSelecteds:Int;

    override function create() {
        directory = FileSystem.readDirectory('assets/replays');
        trace(directory.length);
        
        if(directory.length == 0) {
            directory.push("No Replay Directory");
            nofile = true;
        }
        menuItems = directory;
        
        add(bg);
        add(items);

        textTitle.setFormat(Language.fonts(), 45, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        textTitle.screenCenter(X);
        add(textTitle);

        textVer.setFormat(Language.fonts(), 15, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(textVer);

        regenMenu();
        
		curSelected = 0;
		changeSelection();
	}

        //for(i in 0...s.length)

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(!doing) {
            if(controls.BACK) {
                if(!two) {
                    doing = true;
                    FlxG.sound.play(PathsList.themeSound('cancelMenu'), ClientPrefs.data.soundVolume);
                    MusicBeatState.switchState(new MainMenuState());
                } else {
                    two = false;
                    menuItems = FileSystem.readDirectory('assets/replays');
                    regenMenu();
                }
            }
            if(controls.UI_UP_P) {
                changeSelection(-1);
                FlxG.sound.play(PathsList.themeSound('scrollMenu'), ClientPrefs.data.soundVolume);
            } else if (controls.UI_DOWN_P) {
                changeSelection(1);
                FlxG.sound.play(PathsList.themeSound('scrollMenu'), ClientPrefs.data.soundVolume);
            }
            if(controls.ACCEPT) {
                if(!nofile) {
                    if(!two) {
                        FlxG.sound.play(PathsList.themeSound('confirmMenu'), ClientPrefs.data.soundVolume);
                        files = FileSystem.readDirectory('assets/replays/${directory[curSelected]}');
                        menuItems = files;
                        two = true;
                        regenMenu();
                    } else {
                        FlxG.sound.play(PathsList.themeSound('confirmMenu'), ClientPrefs.data.soundVolume);

                        selected = files[curSelected];
                        trace(selected);
                        curSelecteds = curSelected;

                        var lv0:Array<String> = [];
                        var lv1:Array<String> = [];
                        lv0 = selected.split('-');
                        lv1 = lv0[1].split("_");

                        trace('Songname: ${lv0[0]}, Diff: ${lv1[0]}');

                        var songLowercase:String = Paths.formatToSongPath(lv0[0]);
                        var poop:String = Highscore.formatSong(songLowercase, Std.parseInt(lv1[0]));

                        PlayState.loadRep = true;
                        PlayState.chartingMode = false;

                        FlxG.sound.music.volume = 0;
                        trace('assets/replays/${directory[curSelected]}/${selected}');
                        PlayState.rep = Replay.LoadReplay('assets/replays/${directory[curSelected]}/${selected}');

                        WeekData.reloadWeekFiles(false);
                        WeekData.setDirectoryFromWeek(WeekData.getCurrentWeekFromWeekNum(PlayState.rep.replay.week));
                        Difficulty.loadFromWeek();
                        trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
                        PlayState.SONG = Song.loadFromJson(poop, songLowercase);
                        PlayState.isStoryMode = false;
                        PlayState.replaying = true;
                        PlayState.storyDifficulty = PlayState.storyDifficulty;
                        LoadingState.loadAndSwitchState(new PlayState());
                    }
                } else {
                    FlxG.sound.play(Paths.sound('error'), ClientPrefs.data.soundVolume);
                }
            }
        }
    }

    function changeSelection(change:Int = 0):Void {
		curSelected += change;

		FlxG.sound.play(PathsList.themeSound('scrollMenu'), ClientPrefs.data.soundVolume);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

        var bullShit:Int = 0;
        for (item in items.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0) {
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		var bullShit:Int = 0;
	}

	function regenMenu():Void {
		for (i in 0...items.members.length) {
			var obj = items.members[0];
			obj.kill();
			items.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var item = new Alphabet(90, 320, menuItems[i], true);
			item.isMenuItem = true;
			item.targetY = i;
			items.add(item);
		}
		curSelected = 0;
		changeSelection();
	}
}