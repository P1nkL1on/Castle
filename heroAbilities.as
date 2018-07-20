class heroAbilities{
	static var bottleKey:Number = 87;
	static var bottleFrame:Number = -1;
	static var swordKey:Number = 65;
	static var swordFrame:Number = -1;
	
	static function listenKey(now:Number, key:Number):Number{
		if (Key.isDown(key))
			return now+1;
		return 0;
	}
	static function moveBullet(bul){
		if (bul.spd == undefined) bul.spd = 10;
		bul._x -= bul.spd * Math.cos(bul._rotation / 180 * Math.PI) * animating.worldTimeSpeed;
		bul._y += bul.spd * Math.sin(bul._rotation / 180 * Math.PI) * animating.worldTimeSpeed;
		bul.spd /= 1 + (.2* animating.worldTimeSpeed);
		bul._alpha = bul.spd * 20;
	}
	static var nowFrame = 0;
	static function giveBottle(shad:MovieClip):MovieClip{
		shad.bottleUse = 0;
		shad.slotsForExecute.push(function(who:MovieClip){
			
			// . . . using
			if (who.bottleUse > 3 && who.bottleUse <= 20 && listenKey(0, bottleKey) == 0){
				if (who.model.lefthand._currentframe == 1){
					who.model.lefthand.gotoAndStop('bottle');
				} else {
					who.model.lefthand.gotoAndStop('empty');
					sounds.playSound('weapons/item_in');
				}
			}
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
			who.lastCreatedReflection.lefthand.bottle_use.gotoAndStop(who.model.lefthand.bottle_use._currentframe);
			animating.animateOnly(who.model.lefthand.bottle_use, 1/4);
		});
		return shad;
	}
	
	static function giveSword(shad:MovieClip):MovieClip{
		shad.swordUse = 0;
		shad.slotsForExecute.push(function(who:MovieClip){
			// . . . using
			if (who.swordUse > 3 && who.swordUse <= 15 && listenKey(0, swordKey) == 0){
				if (who.model.righthand._currentframe == 1){
					who.model.righthand.gotoAndStop('sword');
					sounds.playSound('weapons/sword_in');
				} else {
					who.model.righthand.gotoAndStop('empty');
					sounds.playSound('weapons/sword_out');
				}
			}
			// , , ,
			if (who.swordUse > 15 && listenKey(0, swordKey) == 1){ // still pressed
				who.model.righthand.gotoAndStop('sword_use');
				animating.changeStat(who.model.righthand.sword_use, 'start');
				swordFrame = who.model.righthand._currentframe;
			}
			// . . . key listener
			who.swordUse = listenKey(who.swordUse, swordKey);
			animating.animateOnly(who.model.righthand.sword_use, 1/2);
		});
		return shad;
	}
}