package states;

import states.MainMenuState;
import flixel.addons.ui.FlxUIInputText;
import sys.io.File;
import openfl.net.FileReference;
import backend.Replay;

class ReplayState extends MusicBeatState {
    private var inputs:Array<FlxUIInputText> = [];
    private var replayList:Array<Dynamic> = [];
    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG'));
    var textTitle:FlxText = new FlxText(0, 50, 0, 'SELECED REPLAY');
    var textVer:FlxText = new FlxText(2, 705, 0, 'Replay Version1.00');
    var curSelected:Int = -1;
    var fileName:FlxUIInputText;
    var doing:Bool = false;
    var items:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

    override function create() {
        add(bg);
        add(items);

        textTitle.setFormat(Language.fonts(), 45, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        textTitle.screenCenter(X);
        add(textTitle);

        textVer.setFormat(Language.fonts(), 15, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(textVer);

        fileName = new FlxUIInputText(0, 125, 100, '');
        fileName.screenCenter(X);
        inputs.push(fileName);

        //for(i in 0...s.length)
    }

    override function update(elapsed:Float) {
        if(!doing) {
            if(controls.BACK) {
                doing = true;
                MusicBeatState.switchState(new MainMenuState());
            }
            if(controls.UI_UP_P) {
                changeItem(-1);
                FlxG.sound.play(Paths.sound('scrollMenuTH'));
            } else if (controls.UI_DOWN_P) {
                changeItem(1);
                FlxG.sound.play(Paths.sound('scrollMenuTH'));
            }
            if(controls.ACCEPT) {
                trace(fileName.text);
            }
        }
    }

    function changeItem(changes:Int = 0) {
		curSelected += changes;

		if (curSelected >= items.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = items.length - 1;
	}
}