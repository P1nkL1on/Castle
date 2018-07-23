class heroAbilities{
	static var bottleKey:Number = 87;
	static var bottleFrame:Number = -1;
	static var swordKey:Number = 65;
	static var swordFrame:Number = -1;
	static var shieldKey:Number = 83;
	static var shieldFrame:Number = -1;
	static var bookKey:Number = 81;
	
	static var anyKey:Array = new Array(bottleKey, swordKey, shieldKey, bookKey);
	static var anyLeftKey:Array = new Array(bottleKey, shieldKey);
	static var anyRightKey:Array = new Array(swordKey, bookKey);
	
	static function listenKey(now:Number, key:Number):Number{
		if (Key.isDown(key))
			return now+1;
		return 0;
	}
	static function anyLeftKeyPress():Boolean{
		return aKeyPressedIn(anyLeftKey);
	}
	static function anyRightKeyPress():Boolean{
		return aKeyPressedIn(anyRightKey);
	}
	static function anyKeyPressed():Boolean{
		return aKeyPressedIn(anyKey);
	}
	static function aKeyPressedIn(arr:Array):Boolean{
		for (var i = 0; i < arr.length; ++i)
			if (Key.isDown(arr[i]))
				return true;
		return false;
	}
	static function move(who, spd, ang){
		who._x += spd * Math.cos(ang) * animating.worldTimeSpeed;
		who._y += spd * Math.sin(ang) * animating.worldTimeSpeed;
	}
	static function dropLeftIfCan(shad:MovieClip, key:Number){
		if (shad.abilityLockedLeft==true){
				if (Key.isDown(key))
					dropLeftItem(shad);
				if (anyLeftKeyPress() == false)
					shad.leftItem.canBeDropped = true;
			}
	}
	static function dropRightIfCan(shad:MovieClip, key:Number){
		if (shad.abilityLockedRight==true){
				if (Key.isDown(key))
					dropRightItem(shad);
				if (anyRightKeyPress() == false)
					shad.rightItem.canBeDropped = true;
			}
	}
	static function dropLeftItem(shad:MovieClip, instant):MovieClip{
		if (shad.canHandleItems != true)
			return;
		if (shad.leftItem == null)
			return;
		if (shad.leftItem.canBeDropped != true && instant == undefined)
			return;
		trace('Dropped item (left) :: ' + shad.leftItem);
		shad.leftItem.canBeDropped = false;
		shad.leftItem._x = shad._x + 30;
		shad.leftItem._y = shad._y;
		shad.leftItem._z = 80;
		shad.leftItem.sp_z = 5;
		shad.leftItem.model._visible = true;
		shad.leftItem.model._x = shad._x + 30;
		shad.leftItem.model._y = shad._y - 80;
		shad.leftItem.CD = 95;
		var droppedItem:MovieClip = shad.leftItem;
		shad.leftItem = null;
		shad.model.lefthand.gotoAndStop('empty');
		shad.abilityLockedLeft = false;
		return droppedItem;
	}
	static function dropRightItem(shad:MovieClip, instant):MovieClip{
		if (shad.canHandleItems != true)
			return;
		if (shad.rightItem == null)
			return;
		if (shad.rightItem.canBeDropped != true && instant == undefined)
			return;
		trace('Dropped item (right) :: ' + shad.rightItem);
		shad.rightItem.canBeDropped = false;
		shad.rightItem._x = shad._x - 30;
		shad.rightItem._y = shad._y;
		shad.rightItem._z = 80;
		shad.rightItem.sp_z = 5;
		shad.rightItem.model._visible = true;
		shad.rightItem.model._x = shad._x - 30;
		shad.rightItem.model._y = shad._y - 80;
		shad.rightItem.CD = 95;
		var droppedItem:MovieClip = shad.rightItem;
		shad.rightItem = null;
		shad.model.righthand.gotoAndStop('empty');
		shad.abilityLockedRight = false;
		return droppedItem;
	}
	static function canHandleItems(shad:MovieClip):MovieClip{
		shad.leftItem = null;
		shad.rightItem = null;
		shad.canHandleItems = true;
		//
		shad.slotsForExecute.push(function(who:MovieClip){
			dropLeftIfCan(who, bottleKey);
			dropLeftIfCan(who, shieldKey);
			dropRightIfCan(who, swordKey);
			dropRightIfCan(who, bookKey);
		});
		shad.slotsForExecute.push(function(who:MovieClip){
			who.abilityLockedItem = false;
			who.wantFirstItem = null;
			for (var i = 0; i < items.allItems.length; ++i)
				if (items.allItems[i].CD < 0){
					who.wantItem = items.allItems[i];
					if (who.hitTest(who.wantItem)){
						if (who.wantItem.model._visible == true)
							who.abilityLockedItem = true;
						if (who.wantItem == who.leftItem
							|| who.wantItem == who.rightItem)
							continue;
						if (who.wantFirstItem == null)
							who.wantFirstItem = who.wantItem;
						if (who.leftItem == null && anyLeftKeyPress()){
							who.leftItem = who.wantItem;
							who.model.lefthand.gotoAndStop('item');
							who.wantItem.model._visible = false;
							who.abilityLockedLeft = true;
							trace('Geted item (left) :: ' + shad.leftItem);
							levels.checkGUI();
							break;
						}
						if (who.rightItem == null && anyRightKeyPress()){
							who.rightItem = who.wantItem;
							who.model.righthand.gotoAndStop('item');
							who.wantItem.model._visible = false;
							who.abilityLockedRight = true;
							trace('Geted item (right) :: ' + shad.rightItem);
							levels.checkGUI();
							break;
						}
					}
				}
			who.model.lefthand.item.gotoAndStop(who.leftItem.itemName);
			who.model.righthand.item.gotoAndStop(who.rightItem.itemName);
			who.lastCreatedReflection.righthand.item.gotoAndStop(who.rightItem.itemName);
			who.lastCreatedReflection.lefthand.item.gotoAndStop(who.leftItem.itemName);
		});
		return shad;
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
			if (who.locked == true || who.abilityLockedItem == true || who.abilityLockedLeft == true)
				return;
			if (who.shieldUse > 0)
				who.bottleUse = 0;
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
			
			animating.animateOnly(who.model.lefthand.bottle_use, 1/4);
			who.model.lefthand.bottle._rotation = -who.model.lefthand._rotation - 30;
			who.model.lefthand.bottle_use._rotation = -who.model.lefthand._rotation;
			who.lastCreatedReflection.lefthand.bottle_use.gotoAndStop(who.model.lefthand.bottle_use._currentframe);
		});
		return shad;
	}
	static var swordRotation:Number = 0;
	static var swordNowRotation:Number = 0;
	static var swordModelRotation:Number = 0;
	static function giveSword(shad:MovieClip):MovieClip{
		shad.swordUse = 0;
		shad.slotsForExecute.push(function(who:MovieClip){
			if (who.locked == true || who.abilityLockedItem == true || who.abilityLockedRight == true)
				return;
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
			if (who.dir_x != 0) swordNowRotation = 0;
				else {
					if (who.dir_x == -1) swordNowRotation = 90;
					if (who.dir_y == 1) swordNowRotation = -90;
				}
			swordModelRotation += (swordNowRotation - swordModelRotation) / (1 + 4 / animating.worldTimeSpeed);
			// . . . using
			if (who.swordUse > 3 && (who.swordUse <= 15) && listenKey(0, swordKey) == 0){
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
				var newEffect:MovieClip = ground.spawnEffect('effect_sword_slash', who.model._x, who.model._y - 20, true);
				newEffect._rotation = swordRotation;
			}
			// spawnEffect
			// . . . key listener
			who.swordUse = listenKey(who.swordUse, swordKey);
			animating.animateOnly(who.model.righthand.sword_use, 1/4);
			who.model.righthand.sword_use._rotation = who.model.righthand._rotation * (-1) + swordModelRotation;
			who.lastCreatedReflection.righthand.sword_use.gotoAndStop(who.model.righthand.sword_use._currentframe);
			
		});
		return shad;
	}
	static function giveShield(shad:MovieClip):MovieClip{
		shad.shieldUse = 0;
		shad.isBlocking = false;
		shad.slotsForExecute.push(function(who:MovieClip){
			if (who.abilityLockedLeft==true && Key.isDown(shieldKey))
				dropLeftItem(who);
			if (who.locked == true || who.abilityLockedItem == true || who.abilityLockedLeft == true)
				return;
			if (who.bottleUse > 0)
				who.shieldUse = 0;
			// . . . using
			if (who.shieldUse > 3 && who.shieldUse <= 20 && listenKey(0, shieldKey) == 0){
				if (who.model.lefthand._currentframe == 1){
					who.model.lefthand.gotoAndStop('shield');
				} else {
					who.model.lefthand.gotoAndStop('empty');
					sounds.playSound('weapons/item_in');
				}
			}
			// . . . using
			if (who.model.lefthand.shield_use.stat != 'start'
				&& who.shieldUse > 20 && listenKey(0, shieldKey) == 1){ // still pressed
				who.model.lefthand.gotoAndStop('shield_use');
				animating.changeStat(who.model.lefthand.shield_use, 'start');
				shieldFrame = who.model.lefthand._currentframe;
				who.isBlocking = true;
				trace('block');
			}
			if (who.shieldUse > 20 && listenKey(0, shieldKey) == 0){
				animating.changeStat(who.model.lefthand.shield_use, 'stop');
				who.slowing = 0;
				who.isBlocking = false;
				trace('stop');
			}
			// . . . action
			if (who.model.lefthand.shield_use._currentframe == 4)
				who.slowing = .6;
			// . . . key listener
			who.shieldUse = listenKey(who.shieldUse, shieldKey);
			
			who.model.lefthand.shield._rotation = -who.model.lefthand._rotation;
			who.model.lefthand.shield._xscale = 100 * ((who.lastDirection == "back")*(-2) + 1);
			who.model.lefthand.shield.gotoAndStop(1 + 1 * (who.lastDirection == "side"));
			/*who.lastCreatedReflection.lefthand.bottle_use.gotoAndStop(who.model.lefthand.bottle_use._currentframe); */
			animating.animateOnly(who.model.lefthand.shield_use, 1/2);
			//who.model.lefthand.shield_use._rotation = -who.model.lefthand._rotation;
		});
		return shad;
	}
}