package lib;

typedef LangData = {
	lang:Array<Dynamic>
}

class Language {
    public static var language:Dynamic = text();
    private static var lists:LangData = Json.parse(Paths.langfile('langlist'));
    public static var langualist:Array<String> = [];
    public static var fonlist:Array<String> = [];

    public static function init() {
        trace('language/${ClientPrefs.data.language}.json');

        for(i in 0...lists.lang.length)
            langualist.push(lists.lang[i][1]);

        if(FileSystem.readDirectory('assets/fonts/language/${ClientPrefs.data.language}').length > 1) fonlist = FileSystem.readDirectory('assets/fonts/language/${ClientPrefs.data.language}')
        else fonlist = [FileSystem.readDirectory('assets/fonts/language/${ClientPrefs.data.language}')[0]];

        language = text();
    }

    private static function text() {
        var l:Dynamic = Json.parse(Paths.langfile('${ClientPrefs.data.language}'));
        return l;
    }

    public static function fonts(fontsFile:String = ''){
        //trace(ClientPrefs.data.language);
        if(fontsFile == '') {
            if(ClientPrefs.data.languagefonts) return 'assets/fonts/language/${ClientPrefs.data.language}/${ClientPrefs.data.usingfont}';
            else     return Paths.font("vcr.ttf");
        } else {
            return Paths.font('language/$fontsFile');
        }
    }
}