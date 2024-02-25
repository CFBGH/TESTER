package backend;

import flixel.util.FlxGradient;
import flixel.FlxSubState;
import openfl.utils.Assets;
import flixel.FlxObject;
import lib.Fade;
 
class CustomFadeTransition extends MusicBeatSubState {
	public static var finishCallback:Void->Void;
	private var leTween:FlxTween = null;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;
	var duration:Float;
	
	var loadLeft:FlxSprite;
	var loadRight:FlxSprite;
	var loadAlpha:FlxSprite;
	var WaterMark:FlxText;
	var EventText:FlxText;
	
	var loadLeftTween:FlxTween;
	var loadRightTween:FlxTween;
	var loadAlphaTween:FlxTween;
	var EventTextTween:FlxTween;
	var loadTextTween:FlxTween;

	public function new(duration:Float, isTransIn:Bool) {
		super();

		this.isTransIn = isTransIn;
		this.duration = duration;

		//trace(Fade.positionData);
		if(ClientPrefs.data.fadeStyle != 'default') {
			if(ClientPrefs.data.fademode == 'Move'){
				loadRight = new FlxSprite(isTransIn ? 0 : 1280, 0).loadGraphic(Paths.image('CustomFadeTransition/${ClientPrefs.data.fadeStyle}/MR'));
				loadRight.scrollFactor.set();
				loadRight.antialiasing = ClientPrefs.data.antialiasing;		
				add(loadRight);
				loadRight.setGraphicSize(FlxG.width, FlxG.height);
				loadRight.updateHitbox();
				
				loadLeft = new FlxSprite(isTransIn ? 0 : -1280, 0).loadGraphic(Paths.image('CustomFadeTransition/${ClientPrefs.data.fadeStyle}/ML'));
				loadLeft.scrollFactor.set();
				loadLeft.antialiasing = ClientPrefs.data.antialiasing;
				add(loadLeft);
				loadLeft.setGraphicSize(FlxG.width, FlxG.height);
				loadLeft.updateHitbox();
				
				WaterMark = new FlxText(isTransIn ? 50 : -1230, 720 - 50 - 50 * 2, 0, '${Main.MAIN_Version}' #if BETA +'${Main.BETA_Version}'#end, 50);
				WaterMark.scrollFactor.set();
				WaterMark.setFormat(Language.fonts(), 50, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				WaterMark.antialiasing = ClientPrefs.data.antialiasing;
				add(WaterMark);
				
				EventText= new FlxText(isTransIn ? 50 : -1230, 720 - 50 - 50, 0, 'Please Wait.....', 50);
				EventText.scrollFactor.set();
				EventText.setFormat(Language.fonts(), 50, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				EventText.antialiasing = ClientPrefs.data.antialiasing;
				add(EventText);
				
				if(!isTransIn) {
					FlxG.sound.play('assets/shared/images/CustomFadeTransition/${ClientPrefs.data.fadeStyle}/loading_start.ogg',ClientPrefs.data.soundVolume);
					if (!ClientPrefs.data.fadeText) {
						EventText.text = '';
						WaterMark.text = '';
					}

					trace('MOVEIN:[ LX: ${Fade.movein[0][0]}, LY: ${Fade.movein[0][1]}, RX:${Fade.movein[1][0]}, RL:${Fade.movein[1][1]} ]');

					loadLeftTween = FlxTween.tween(loadLeft, {x: Fade.movein[0][0], y: Fade.movein[0][1]}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								finishCallback();
							}
						},
					ease: FlxEase.expoInOut});
					
					loadRightTween = FlxTween.tween(loadRight, {x: Fade.movein[1][0], y: Fade.movein[1][1]}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								finishCallback();
							}
						},
					ease: FlxEase.expoInOut});
					
					loadTextTween = FlxTween.tween(WaterMark, {x: 50}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								finishCallback();
							}
						},
					ease: FlxEase.expoInOut});
					
					EventTextTween = FlxTween.tween(EventText, {x: 50}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								finishCallback();
							}
						},
					ease: FlxEase.expoInOut});
					
				} else {
					FlxG.sound.play('assets/shared/images/CustomFadeTransition/${ClientPrefs.data.fadeStyle}/loading_done.ogg',ClientPrefs.data.soundVolume);
					EventText.text = 'Loading Completed!';
					if (!ClientPrefs.data.fadeText) {
						EventText.text = '';
						WaterMark.text = '';
					}

					trace('MOVEOUT:[ LX: ${Fade.moveout[0][0]}, LY: ${Fade.moveout[0][1]}, RX:${Fade.moveout[1][0]}, RL:${Fade.moveout[1][1]} ]');

					loadLeftTween = FlxTween.tween(loadLeft, {x: Fade.moveout[0][0], y: Fade.moveout[0][1]}, duration, {
						onComplete: function(twn:FlxTween) {
							close();
						},
					ease: FlxEase.expoInOut});
					
					loadRightTween = FlxTween.tween(loadRight, {x: Fade.moveout[1][0], y: Fade.moveout[1][1]}, duration, {
						onComplete: function(twn:FlxTween) {
							close();
						},
					ease: FlxEase.expoInOut});
					
					loadTextTween = FlxTween.tween(WaterMark, {x: -1230}, duration, {
						onComplete: function(twn:FlxTween) {
							close();
						},
					ease: FlxEase.expoInOut});
					
					EventTextTween = FlxTween.tween(EventText, {x: -1230}, duration, {
						onComplete: function(twn:FlxTween) {
							close();
						},
					ease: FlxEase.expoInOut});
					
					
				}
			} else{
				loadAlpha = new FlxSprite(0, 0).loadGraphic(Paths.image('CustomFadeTransition/${ClientPrefs.data.fadeStyle}/MA'));
				loadAlpha.scrollFactor.set();
				loadAlpha.antialiasing = ClientPrefs.data.antialiasing;		
				add(loadAlpha);
				loadAlpha.setGraphicSize(FlxG.width, FlxG.height);
				loadAlpha.updateHitbox();
				
				WaterMark = new FlxText(50, 720 - 50 - 50 * 2, 0, '${Main.MAIN_Version}' #if BETA +'${Main.BETA_Version}'#end, 30);
				WaterMark.scrollFactor.set();
				WaterMark.setFormat(Language.fonts(), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				WaterMark.antialiasing = ClientPrefs.data.antialiasing;
				#if BETA
				WaterMark.color = 0xFFFFFF00;
				#end
				add(WaterMark);
				
				EventText= new FlxText(50, 720 - 50 - 50, 0, 'Please Wait.....', 35);
				EventText.scrollFactor.set();
				EventText.setFormat(Language.fonts(), 35, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				EventText.antialiasing = ClientPrefs.data.antialiasing;
				add(EventText);
				
				if(!isTransIn) {
					FlxG.sound.play('assets/shared/images/CustomFadeTransition/${ClientPrefs.data.fadeStyle}/loading_start.ogg',ClientPrefs.data.soundVolume);
					if (!ClientPrefs.data.fadeText) {
						EventText.text = '';
						WaterMark.text = '';
					}
					WaterMark.alpha = 0;
					EventText.alpha = 0;
					loadAlpha.alpha = 0;
					loadAlphaTween = FlxTween.tween(loadAlpha, {alpha: 1}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								finishCallback();
							}
						},
					ease: FlxEase.sineInOut});
					
					loadTextTween = FlxTween.tween(WaterMark, {alpha: 1}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								finishCallback();
							}
						},
					ease: FlxEase.sineInOut});
					
					EventTextTween = FlxTween.tween(EventText, {alpha: 1}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								finishCallback();
							}
						},
					ease: FlxEase.sineInOut});
					
				} else {
					FlxG.sound.play('assets/shared/images/CustomFadeTransition/${ClientPrefs.data.fadeStyle}/loading_done.ogg',ClientPrefs.data.soundVolume);
					EventText.text = 'Loading Completed!';
					if (!ClientPrefs.data.fadeText) {
						EventText.text = '';
						WaterMark.text = '';
					}
					loadAlphaTween = FlxTween.tween(loadAlpha, {alpha: 0}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								close();
							}
						},
					ease: FlxEase.sineInOut});
					
					loadTextTween = FlxTween.tween(WaterMark, {alpha: 0}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								close();
							}
						},
					ease: FlxEase.sineInOut});
					
					EventTextTween = FlxTween.tween(EventText, {alpha: 0}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								close();
							}
						},
					ease: FlxEase.sineInOut});
				}
			}

			if(nextCamera != null) {
				if (loadLeft != null) loadLeft.cameras = [nextCamera];
				if (loadRight != null) loadRight.cameras = [nextCamera];			
				if (loadAlpha != null) loadAlpha.cameras = [nextCamera];

				WaterMark.cameras = [nextCamera];
				EventText.cameras = [nextCamera];
			}
			nextCamera = null;
		}
	}

	override function create() {
		if(ClientPrefs.data.fadeStyle == 'default') {
			cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
			var width:Int = Std.int(FlxG.width / Math.max(camera.zoom, 0.001));
			var height:Int = Std.int(FlxG.height / Math.max(camera.zoom, 0.001));
			transGradient = FlxGradient.createGradientFlxSprite(1, height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
			transGradient.scale.x = width;
			transGradient.updateHitbox();
			transGradient.scrollFactor.set();
			transGradient.screenCenter(X);
			add(transGradient);

			transBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
			transBlack.scale.set(width, height + 400);
			transBlack.updateHitbox();
			transBlack.scrollFactor.set();
			transBlack.screenCenter(X);
			add(transBlack);

			if(isTransIn)
				transGradient.y = transBlack.y - transBlack.height;
			else
				transGradient.y = -transGradient.height;
		}

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(ClientPrefs.data.fadeStyle == 'default') {
			final height:Float = FlxG.height * Math.max(camera.zoom, 0.001);
			final targetPos:Float = transGradient.height + 50 * Math.max(camera.zoom, 0.001);
			if(duration > 0)
				transGradient.y += (height + targetPos) * elapsed / duration;
			else
				transGradient.y = (targetPos) * elapsed;

			if(isTransIn)
				transBlack.y = transGradient.y + transGradient.height;
			else
				transBlack.y = transGradient.y - transBlack.height;

			if(transGradient.y >= targetPos)
			{
				close();
				if(finishCallback != null) finishCallback();
				finishCallback = null;
			}
		}
	}

	override function destroy() {
		if(leTween != null && ClientPrefs.data.fadeStyle != 'default') {
			finishCallback();
			leTween.cancel();
			
			if (loadLeftTween != null) loadLeftTween.cancel();
			if (loadRightTween != null) loadRightTween.cancel();
			if (loadAlphaTween != null) loadAlphaTween.cancel();
			
			loadTextTween.cancel();
			EventTextTween.cancel();
		}
		super.destroy();
	}
}
