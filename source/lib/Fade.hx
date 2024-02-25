package lib;

typedef MovePosJson = {
    movein:Array<Array<Int>>,
    moveout:Array<Array<Int>>
}

class Fade {
    private static var positionData:MovePosJson = pos();
    public static var movein:Array<Array<Int>> = positionData.movein;
    public static var moveout:Array<Array<Int>> = positionData.moveout;
    private static function pos() {
        var l:Dynamic = Json.parse(Paths.getTextFromFile('images/CustomFadeTransition/${ClientPrefs.data.fadeStyle}/fade.json'));
        return l;
    }
    /*public static function movePos(mode:String = 'x', in:Bool = true){
        

        if (mode == 'x') {
            if(in)
            
        }
        if (mode == 'y')
            return y;
    }*/
}