class hazards{
	static function manFree(who, from){
		if (from.man == null)
			return;
		trace('Free from '+from.model._name+' :: ' + who);
		who.stat = 'idle_side';
		who.locked = false;
		from.CD = 40;
		from.checked = !from.checked;
		from.model.stat = 'none';
		from.man = null;
	}
	
	static function makeKeyReciever(shad:MovieClip, rad, keyCount){
		if (keyCount == undefined)
			shad.keyLeft = 1;
		else
			shad.keyLeft = keyCount;
		shad.triggerFunction;
		shad.openFunction;
		shad.slotsForExecute.push(function(who:MovieClip){
		if (who.keyLeft <= 0)
			return;
		if (animating.each(who, 1 / 15) > 0)
			for (var i = 0; i < spawning.units.length; ++i)
				if (Math.abs(spawning.units[i]._x - who._x) < rad
					&& Math.abs(spawning.units[i]._y - who._y) < rad / 2){
						//
						if (spawning.units[i].canHandleItems != true)
							continue;
						who.devour = 'none';	
						if (spawning.units[i].leftItem.itemName == 'key')
							who.devour = 'left';
						if (who.devour == 'none' && spawning.units[i].rightItem.itemName == 'key')		
							who.devour = 'right';
						if (who.devour == 'none')
							continue;
						var droppedItem:MovieClip = null;
						if (who.devour == 'left')
							droppedItem = heroAbilities.dropLeftItem(spawning.units[i]);
						if (who.devour == 'right')
							droppedItem = heroAbilities.dropRightItem(spawning.units[i]);
						//
						items.removeItem(droppedItem);
						levels.checkGUI();
						//
						sounds.playSound("background/key_open");
						trace('Keys need to interact '+who.keyLeft+'->'+(who.keyLeft-1)+' :: ' + who);
						who.keyLeft--;
						who.triggerFunction(who, who.keyLeft);
						if (who.keyLeft == 0)
							who.openFunction(who);
					}
		});
		return shad;	
	}
	static function spawnLever (X, Y, checked):MovieClip{
		var newLever:MovieClip = spawning.spawnUnit("lever", X, Y);
		if (!(newLever._x > Number.MIN_VALUE))
			{trace('Can not spawn a lever;'); return null;}
		if (checked == undefined)
			newLever.checked = false;	
		else
			newLever.checked = checked;
		newLever.model.gotoAndStop(14*(1+1*(!newLever.checked)));
		newLever.canBeActivatedBy = new Array();
		for (var i = 0; i < spawning.units.length; ++i)
			if (spawning.units[i].isControllable)
				newLever.canBeActivatedBy.push(spawning.units[i]);
		trace('Lever can be activated by ('+newLever.canBeActivatedBy.length+'): ' + newLever.canBeActivatedBy);
		newLever.man = null;
		newLever.hX = 0;
		newLever.CD = 0;
		newLever.checkFunction;
		newLever.uncheckFunction;
		newLever.slotsForExecute.push(function(who:MovieClip){
			//who.model.tt.text = who.man;
			//who.model.tt2.text = who.model.stat+'  '+who.model._currentframe+'----'+who.man.model.stat;
			animating.animateOnly(who.model, 1/6);
			if (who.CD >= 0){who.CD -= animating.worldTimeSpeed; return;}
			if (who.man == null){	
				for (var i = 0; i < who.canBeActivatedBy.length; ++i){
					who.h = who.canBeActivatedBy[i];
					if (who.hitTest(who.h) && heroAbilities.anyKeyPressed() == true && who.h.locked == false){
						trace('Lock on lever '+who.model._name+' :: ' + who.h);
						who.man = who.h;
						who.man.locked = true;
						who.hX = who._x - 30 * (who.checked * 2 - 1);
						who.man.sp_x = who.man.sp_y = 0;
						who.man.model._xscale = - (who.man.model.xs * (who.checked * 2 - 1));
						animating.changeStat(who.man.model, 'run_side');
						break;
					}
				}
				return;
			}
			
			if (who.model.stat == 'idle' && (Math.abs(who.man._y - who._y) > .6 || Math.abs(who.hX - who.man._x)> .6) ){
				who.attachSpd = (1 + 4 / animating.worldTimeSpeed);
				who.man._x += (who.hX - who.man._x) / who.attachSpd;
				who.man._y += (who._y - who.man._y) / who.attachSpd;
				return;
			}
			if (who.man.model.stat != 'lever_pull'
				&& who.model._currentframe != 14
				&& who.model._currentframe != 28){
				animating.changeStat(who.man.model, 'lever_pull');
				animating.changeStat(who.model, 'check_' + who.checked);
			}
		});
		// newLever.slotsForExecute.push(function(who:MovieClip){
			// who.hs = _root.layer_background.effect_sword_slash;
			// if (who.hs == undefined || who.hs == null)
				// return;
			// if (who.model.stat == 'idle' && who.hs.hitTest(who._x, who._y)){
				// who.hs._alpha -= 20;
				// if ((who.checked == false && who.hs._x > who._x) || (who.checked == true && who.hs._x < who._x)){
					// who.checked = !who.checked;
					// animating.changeStat(who.model, 'check_' + who.checked);
					// nextFrame();nextFrame();nextFrame();nextFrame();nextFrame();
				// }
			// }
		// });
		return newLever;	
	}
}