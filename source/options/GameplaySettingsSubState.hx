package options;

import lib.PathsList;

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Gameplay Settings';
		rpcTitle = 'Gameplay Settings Menu'; //for Discord Rich Presence

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', //Name
		language.States.options.gameplay.opt1, //Description
			'downScroll', //Save data variable name
			'bool'); //Variable type
		addOption(option);

		var option:Option = new Option('Middlescroll',
		language.States.options.gameplay.opt2,
			'middleScroll',
			'bool');
		addOption(option);

		var option:Option = new Option('Have Voices',
		language.States.options.gameplay.opt3,
			'haveVoices',
			'bool');
		addOption(option);

		var option:Option = new Option('Opponent Notes',
		language.States.options.gameplay.opt4,
			'opponentStrums',
			'bool');
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
		language.States.options.gameplay.opt5,
			'ghostTapping',
			'bool');
		addOption(option);

		var option:Option = new Option('Health Mode',
		language.States.options.gameplay.opt6,
			'keHealth',
			'string',
			['Psych', 'Kade']);
		addOption(option);
		
		var option:Option = new Option('Auto Pause',
		language.States.options.gameplay.opt7,
			'autoPause',
			'bool');
		addOption(option);
		option.onChange = onChangeAutoPause;

		var option:Option = new Option('Disable Reset Button',
		language.States.options.gameplay.opt8,
			'noReset',
			'bool');
		addOption(option);

		var option:Option = new Option('Language Change',
		language.States.options.gameplay.opt15,
			'language',
			'string',
			Language.langualist);
		addOption(option);
		option.onChange = onChangeLanguage;

		var option:Option = new Option('Fonts Change',
		language.States.options.gameplay.opt16,
			'usingfont',
			'string',
			Language.fonlist);
		addOption(option);
		option.onChange = onChangeLanguage;

		var option:Option = new Option('Fonts Change',
		language.States.options.gameplay.opt17,
			'languagefonts',
			'bool');
		addOption(option);

		var option:Option = new Option('Hitsound Volume',
		language.States.options.gameplay.opt9,
			'hitsoundVolume',
			'percent');
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option('Hitsound Change',
		language.States.options.gameplay.opt18,
			'hitsound',
			'string',
			PathsList.hitsoundList());
		addOption(option);
		option.onChange = onChangeHitsound;

		var option:Option = new Option('Rating Offset',
		language.States.options.gameplay.opt10,
			'ratingOffset',
			'int');
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window',
		language.States.options.gameplay.opt11,
			'sickWindow',
			'int');
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 45;
		addOption(option);

		var option:Option = new Option('Good Hit Window',
		language.States.options.gameplay.opt12,
			'goodWindow',
			'int');
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15;
		option.maxValue = 90;
		addOption(option);

		var option:Option = new Option('Bad Hit Window',
		language.States.options.gameplay.opt13,
			'badWindow',
			'int');
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15;
		option.maxValue = 135;
		addOption(option);

		var option:Option = new Option('Safe Frames',
		language.States.options.gameplay.opt14,
			'safeFrames',
			'float');
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		super();
	}

	function onChangeHitsoundVolume()
	{
		FlxG.sound.play(Paths.sound('hitsounds/${ClientPrefs.data.hitsound}'), ClientPrefs.data.hitsoundVolume);
	}

	function onChangeHitsound() {
		ClientPrefs.saveSettings();
		FlxG.sound.play(Paths.sound('hitsounds/${ClientPrefs.data.hitsound}'), ClientPrefs.data.hitsoundVolume);
	}

	function onChangeAutoPause()
	{
		FlxG.autoPause = ClientPrefs.data.autoPause;
	}

	function onChangeLanguage() {
		ClientPrefs.saveSettings();
		Language.init();
	}
}