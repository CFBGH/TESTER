package states;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width,
			"Sup bro, looks like you're running an   \n
			outdated version of Psych Engine (" + MainMenuState.psychEngineVersion + "),\n
			please update to " + PreloadState.updateVersion + "!\n
			Press ESCAPE to proceed anyway.\n
			\n
			Thank you for using the Engine!",
			32);
		warnText.setFormat(Language.fonts(), 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);

		#if android
		addVirtualPad(NONE, A_B);
		#else
		if(ClientPrefs.data.tabletmode)
			addVirtualPad(NONE, A_B);
		#end
	}

	override function update(elapsed:Float)
	{
		var isTab:Bool = ClientPrefs.data.tabletmode;
		if(!leftState) {
			if (controls.ACCEPT || (isTab && MusicBeatState._virtualpad.buttonA.justPressed)) {
				leftState = true;
				CoolUtil.browserLoad("https://github.com/ShadowMario/FNF-PsychEngine/releases");
			}
			else if(controls.BACK || (isTab && MusicBeatState._virtualpad.buttonB.justPressed)) {
				leftState = true;
			}

			if(leftState)
			{
				FlxG.sound.play(PathsList.themeSound('cancelMenu'), ClientPrefs.data.soundVolume);
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						MusicBeatState.switchState(new TitleState());
					}
				});
			}
		}
		super.update(elapsed);
	}
}
