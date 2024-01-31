package options;

class ExtraSettingsSubState extends BaseOptionsMenu {
	public function new() {
		title = 'Experimental Setting';
		rpcTitle = 'Warning: Some experimental options may break your game, so be turned on with caution'; // for Discord Rich Presence

		var option:Option = new Option('blueberry', '${language.States.options.ES.opt1}', 'blueberry', 'bool');
		addOption(option);

		/*var option:Option = new Option('Old Version support', '${language.States.options.ES.opt2}', 'oldVHB', 'bool');
		addOption(option);*/

		var option:Option = new Option('Tablet Mode', '${language.States.options.ES.opt3}', 'tabletmode', 'bool');
		addOption(option);

		var option:Option = new Option('Zoom Mode', '${language.States.options.ES.opt4}', 'zoomMode', 'string', ['Section', 'Beat', 'Step']);
		addOption(option);

		var option:Option = new Option('Uesr Mouse', '${language.States.options.ES.opt5}', 'um', 'bool');
		addOption(option);
		option.onChange = onChangeMouse;
		  
		var option:Option = new Option('Space Location:',
		'${language.States.options.ES.opt6}',
			'hitboxLocation',
			'string',
			['Bottom', 'Middle', 'Top']);
		  addOption(option);  
		  
		var option:Option = new Option('Hitbox Alpha:', //mariomaster was here again
		'${language.States.options.ES.opt7}',
			'hitboxalpha',
			'float');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		
		var option:Option = new Option('VirtualPad Alpha:', //mariomaster was here again
		'${language.States.options.ES.opt8}',
			'VirtualPadAlpha',
			'float');
		option.scrollSpeed = 1.6;
		option.minValue = 0.1;
		option.maxValue = 1;
		option.changeValue = 0.01;
		option.decimals = 2;
		addOption(option);
        option.onChange = onChangePadAlpha;

		super();
	}

	var OGpadAlpha:Float = ClientPrefs.data.VirtualPadAlpha;
	function onChangePadAlpha()
	{
		ClientPrefs.saveSettings();
		MusicBeatState._virtualpad.alpha = ClientPrefs.data.VirtualPadAlpha / OGpadAlpha;
	}

	function onChangeMouse() {
		ClientPrefs.saveSettings();
		FlxG.mouse.useSystemCursor = ClientPrefs.data.um;
	}
}
