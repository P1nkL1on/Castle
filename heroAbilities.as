﻿class heroAbilities{
	static var bottleKey:Number = 87;
	static var bottleFrame:Number = -1;
	static var swordKey:Number = 65;
	static var swordFrame:Number = -1;
	
	static function listenKey(now:Number, key:Number):Number{
		if (Key.isDown(key))
			return now+1;
		return 0;
	}
	static function move(who, spd, ang){
		who._x += spd * Math.cos(ang) * animating.worldTimeSpeed;
		who._y += spd * Math.sin(ang) * animating.worldTimeSpeed;
	}
	static function moveBullet(bul){
		bul.ang = bul._rotation / 180 * Math.PI;
		if (bul.spd == undefined){ bul.spd = 10; move(bul, 20 / animating.worldTimeSpeed, bul.ang);}
		bul._visible = true;
		move(bul, bul.spd, bul.ang);
		bul.spd /= 1 + (.2* animating.worldTimeSpeed);
		bul._alpha = bul.spd * 20;
		if (bul._alpha < 3)
			bul.removeMovieClip();
	}
	static var nowFrame = 0;
	static var bottleCd = 0;
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
			if (nowFrame == 5 || nowFrame == 6){
				if (bottleCd > 0) 
					bottleCd -= animating.worldTimeSpeed;
				else {
						bottleCd = 10;
						ground.addWater(who._x + (who.model._xscale / who.model.xs)*(20), who._y, 1);
					}
			}				
			// . . . key listener
			who.bottleUse = listenKey(who.bottleUse, bottleKey);
			
			who.model.lefthand.bottle._rotation = -who.model.lefthand._rotation - 30;
			who.model.lefthand.bottle_use._rotation = -who.model.lefthand._rotation;
			who.lastCreatedReflection.lefthand.bottle_use.gotoAndStop(who.model.lefthand.bottle_use._currentframe);
			animating.animateOnly(who.model.lefthand.bottle_use, 1/4);
		});
		return shad;
	}
	static var swordRotation:Number = 0;
	static var swordModelRotation:Number = 0;
	static var swordNowRotation:Number = 0;
	static function giveSword(shad:MovieClip):MovieClip{
		shad.swordUse = 0;
		shad.slotsForExecute.push(function(who:MovieClip){
			// where does the sword projectile flew
			if (who.dir_x == 1 && who.dir_y == 1) swordRotation = 45;
			if (who.dir_x == -1 && who.dir_y == -1) swordRotation = -135;
			if (who.dir_x == 1 && who.dir_y == -1) swordRotation = -45;
			if (who.dir_x == -1 && who.dir_y == 1) swordRotation = 135;
			if (who.dir_x == 1 && who.dir_y == 0) swordRotation = 0;
			if (who.dir_x == -1 && who.dir_y == 0) swordRotation = 180;
			if (who.dir_x == 0 && who.dir_y == 1) swordRotation = 90;
			if (who.dir_x == 0 && who.dir_y == -1) swordRotation = -90;
			
			// position of drawed sword
			if (who.dir_x != 0) swordModelRotation = 0;
				else {
					if (who.dir_x == -1) swordModelRotation = 90;
					if (who.dir_y == 1) swordModelRotation = -90;
				}
			swordNowRotation += (swordModelRotation - swordNowRotation) / (1 + .1 * animating.worldTimeSpeed);
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
			if (who.swordUse > 15 /* && listenKey(0, swordKey) == 0 */
				&& (who.model.righthand._currentframe == 2 || who.model.righthand.sword_use.stat == 'stop')){ // still pressed
				who.model.righthand.gotoAndStop('sword_use');
				animating.changeStat(who.model.righthand.sword_use, 'start');
				swordFrame = who.model.righthand._currentframe;
				who.model.righthand.attacked = false;
			}
			if (who.model.righthand.attacked == false && who.model.righthand.sword_use._currentframe == 6){
				who.model.righthand.attacked = true;
				var newEffect:MovieClip = ground.spawnEffect('effect_sword_slash', who.model._x, who.model._y - 20);
				newEffect._rotation = swordRotation;
			}
			// spawnEffect
			// . . . key listener
			who.swordUse = listenKey(who.swordUse, swordKey);
			animating.animateOnly(who.model.righthand.sword_use, 1/4);
			who.model.righthand.sword_use._rotation = who.model.righthand._rotation * (-1) + swordNowRotation;
			who.lastCreatedReflection.righthand.sword_use.gotoAndStop(who.model.righthand.sword_use._currentframe);
			
		});
		return shad;
	}
}