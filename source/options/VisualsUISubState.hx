package options;

import objects.Note;
import objects.StrumNote;
import objects.Alphabet;

class VisualsUISubState extends BaseOptionsMenu
{
	var noteOptionID:Int = -1;
	var notes:FlxTypedGroup<StrumNote>;
	var notesTween:Array<FlxTween> = [];
	var noteY:Float = 90;
	public function new()
	{
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		// for note skins
		notes = new FlxTypedGroup<StrumNote>();
		for (i in 0...Note.colArray.length)
		{
			var note:StrumNote = new StrumNote(370 + (560 / Note.colArray.length) * i, -200, i, 0);
			note.centerOffsets();
			note.centerOrigin();
			note.playAnim('static');
			notes.add(note);
		}

		// options

		var noteSkins:Array<String> = Mods.mergeAllTextsNamed('images/noteSkins/list.txt');
		if(noteSkins.length > 0)
		{
			if(!noteSkins.contains(ClientPrefs.data.noteSkin))
				ClientPrefs.data.noteSkin = 'Default'; //Reset to default if saved noteskin couldnt be found

			noteSkins.insert(0, 'Default'); //Default skin always comes first
			var option:Option = new Option('Note Skins:',
			language.States.options.VAU.opt1,
				'noteSkin',
				'string',
				noteSkins);
			addOption(option);
			option.onChange = onChangeNoteSkin;
			noteOptionID = optionsArray.length - 1;
		}
		
		var noteSplashes:Array<String> = Mods.mergeAllTextsNamed('images/noteSplashes/list.txt');
		if(noteSplashes.length > 0)
		{
			if(!noteSplashes.contains(ClientPrefs.data.splashSkin))
				ClientPrefs.data.splashSkin = ClientPrefs.defaultData.splashSkin; //Reset to default if saved splashskin couldnt be found

			noteSplashes.insert(0, ClientPrefs.defaultData.splashSkin); //Default skin always comes first
			var option:Option = new Option('Note Splashes:',
			language.States.options.VAU.opt2,
				'splashSkin',
				'string',
				noteSplashes);
			addOption(option);
		}

		var option:Option = new Option('Note Splash Opacity',
		language.States.options.VAU.opt3,
			'splashAlpha',
			'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Hide HUD',
		language.States.options.VAU.opt4,
			'hideHud',
			'bool');
		addOption(option);

		var option:Option = new Option('Combo Display',
		language.States.options.VAU.opt5,
			'comboDis',
			'bool');
		addOption(option);

		var option:Option = new Option('MS display',
		language.States.options.VAU.opt6,
			'msDisplay',
			'bool');
		addOption(option);		
		var option:Option = new Option('Time Bar:',
		language.States.options.VAU.opt7,
			'timeBarType',
			'string',
			['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Flashing Lights',
		language.States.options.VAU.opt8,
			'flashing',
			'bool');
		addOption(option);

		var option:Option = new Option('Camera Zooms',
		language.States.options.VAU.opt9,
			'camZooms',
			'bool');
		addOption(option);

		var option:Option = new Option('Engine style',
		language.States.options.VAU.opt10,
			'styleEngine', 'string',
			['Psych', 'Kade', 'Vanilla', 'MicUp'/*, 'Touhou'*/]);
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit',
		language.States.options.VAU.opt11,
			'scoreZoom',
			'bool');
		addOption(option);

		var option:Option = new Option('Health Bar Opacity',
		language.States.options.VAU.opt12,
			'healthBarAlpha',
			'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		
		#if !mobile
		var option:Option = new Option('FPS Counter',
		language.States.options.VAU.opt13,
			'showFPS',
			'bool');
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end
		
		var option:Option = new Option('Pause Screen Song:',
		language.States.options.VAU.opt14,
			'pauseMusic',
			'string',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;
		
		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
		language.States.options.VAU.opt15,
			'checkForUpdates',
			'bool');
		addOption(option);
		#end

		var option:Option = new Option('Combo Stacking',
		language.States.options.VAU.opt16,
			'comboStacking',
			'bool');
		addOption(option);

		var option:Option = new Option('Camera Zooming Mult', language.States.options.VAU.opt17, 'camZoomingMult', 'float');
		option.displayFormat = '%vx';
		option.scrollSpeed = 5;
		option.minValue = 0.5;
		option.maxValue = 3;
		option.changeValue = 0.1;
		addOption(option);

		super();
		add(notes);
	}

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		
		if(noteOptionID < 0) return;

		for (i in 0...Note.colArray.length)
		{
			var note:StrumNote = notes.members[i];
			if(notesTween[i] != null) notesTween[i].cancel();
			if(curSelected == noteOptionID)
				notesTween[i] = FlxTween.tween(note, {y: noteY}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
			else
				notesTween[i] = FlxTween.tween(note, {y: -200}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
		}
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.data.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));

		changedMusic = true;
	}

	function onChangeNoteSkin()
	{
		notes.forEachAlive(function(note:StrumNote) {
			changeNoteSkin(note);
			note.centerOffsets();
			note.centerOrigin();
		});
	}

	function changeNoteSkin(note:StrumNote)
	{
		var skin:String = Note.defaultNoteSkin;
		var customSkin:String = skin + Note.getNoteSkinPostfix();
		if(Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;

		note.texture = skin; //Load texture and anims
		note.reloadNote();
		note.playAnim('static');
	}

	override function destroy()
	{
		if(changedMusic && !OptionsState.onPlayState){
			if(ClientPrefs.data.styleEngine == 'Kade')
				FlxG.sound.playMusic(Paths.music('freakyMenuKE'), 1, true);
			else if(ClientPrefs.data.styleEngine == 'TouHou')
				FlxG.sound.playMusic(Paths.music('freakyMenuTH'), 1, true);
			else
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 1, true);
		}
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
	}
	#end
}
