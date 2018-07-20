class heroAbilities{
	static var bottleKey:Number = 65;
	static var bottleFrame:Number = -1;
	static function listenKey(now:Number, key:Number):Number{
		if (Key.isDown(key))
			return now+1;
		return 0;
	}
	static var nowFrame = 0;
	static function giveBottle(shad:MovieClip):MovieClip{
		shad.bottleUse = 0;
		shad.slotsForExecute.push(function(who:MovieClip){
			
			// . . . using
			if (who.bottleUse > 3 && who.bottleUse <= 20 && listenKey(0, bottleKey) == 0)
				trace('drink');
			if (who.bottleUse > 20 && listenKey(0, bottleKey) == 0){
				animating.changeStat(who.model.lefthand.bottle_use, 'stop');
				trace('stop');
			}
			if (/* who.model.lefthand._currentframe != bottleFrame &&  */
				who.model.lefthand.bottle_use.stat != 'start'
				&& who.bottleUse > 20 && listenKey(0, bottleKey) == 1){ // still pressed
				who.model.lefthand.gotoAndStop('bottle_use');
				animating.changeStat(who.model.lefthand.bottle_use, 'start');
				bottleFrame = who.model.lefthand._currentframe;
				trace('flush');
			}
			nowFrame = who.model.lefthand.bottle_use._currentframe;
			if (nowFrame == 5 || nowFrame == 6)
				ground.addWater(who._x + (who.model._xscale / who.model.xs)*(20), who._y, .3);
				
			// . . . key listener
			who.bottleUse = listenKey(who.bottleUse, bottleKey);
			
			who.model.lefthand.bottle._rotation = -who.model.lefthand._rotation - 30;
			who.model.lefthand.bottle_use._rotation = -who.model.lefthand._rotation;
			animating.animateOnly(who.model.lefthand.bottle_use, 1/4);
		});
		return shad;
	}
}