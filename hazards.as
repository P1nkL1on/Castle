class hazards{
	static function manFree(who, from){
		if (from.man == null)
			return;
		trace('Free ' + who);
		who.stat = 'idle_side';
		who.locked = false;
		from.CD = 30;
		from.checked = !from.checked;
		from.man = null;
	}
	static function spawnLever (X, Y, checked):MovieClip{
		var newLever:MovieClip = spawning.spawnUnit("lever", X, Y);
		if (!(newLever._x > Number.MIN_VALUE))
			{trace('Can not spawn a lever;'); return null;}
		if (checked == undefined)
			newLever.checked = false;	
		else
			newLever.checked = checked;
		newLever.canBeActivatedBy = new Array();
		for (var i = 0; i < spawning.units.length; ++i)
			if (spawning.units[i].isControllable)
				newLever.canBeActivatedBy.push(spawning.units[i]);
		trace('Lever can be activated by ('+newLever.canBeActivatedBy.length+'): ' + newLever.canBeActivatedBy);
		newLever.man = null;
		newLever.hX = 0;
		newLever.CD = 0;
		newLever.slotsForExecute.push(function(who:MovieClip){
			if (who.model._currentframe >= 3)
				animating.animateOnly(who.model, 1/6);
			if (who.CD > 0){who.CD -= animating.worldTimeSpeed; return;}
			if (who.man == null){	
				for (var i = 0; i < who.canBeActivatedBy.length; ++i){
					who.h = who.canBeActivatedBy[i];
					if (who.hitTest(who.h) && heroAbilities.anyKeyPressed() == true && who.h.locked == false){
						trace('Lock on lever :: ' + who.h);
						who.man = who.h;
						who.man.locked = true;
						who.hX = who._x - 30 * (who.checked * 2 - 1);
						who.man.model._xscale = - (who.man.model.xs * (who.checked * 2 - 1));
						break;
					}
				}
				return;
			}
			if (who.hX != 0 && (Math.abs(who.man._y - who._y) > 1 || Math.abs(who.hX - who.man._x)> 1) ){
				who.attachSpd = (1 + 4 / animating.worldTimeSpeed);
				who.man._x += (who.hX - who.man._x) / who.attachSpd;
				who.man._y += (who._y - who.man._y) / who.attachSpd;
				return;
			}
			
			if (who.man.model.stat != 'level_pull'){
				who.hX = 0;
				animating.changeStat(who.man.model, 'level_pull');
				animating.changeStat(who.model, 'check_true');
				trace('Lever is pulled');
			}
		});
		return newLever;	
	}
}