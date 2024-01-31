package lib;

class Resolution {
    public static function change(value:String) {
        var value0:Array<String> = value.split('x');
        #if desktop
        if(!ClientPrefs.data.fullscr) FlxG.resizeWindow(Std.parseInt(value0[0]), Std.parseInt(value0[1]));
        #end
        FlxG.resizeGame(Std.parseInt(value0[0]), Std.parseInt(value0[1]));
    }
}