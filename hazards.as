class hazards{
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
		newLever.slotsForExecute.push(function(who:MovieClip){
			if (who.man == null){	
				for (var i = 0; i < who.canBeActivatedBy.length; ++i){
					who.h = who.canBeActivatedBy[i];
					if (who.hitTest(who.h) && heroAbilities.anyKeyPressed() == true && who.h.lockPose == false){
						trace('Okay, lock this guy in a lever');
						who.man = who.h;
						who.man.lockPose = true;
						who.man.slowing = 1;
						who.hX = who._x - 30 * (who.checked * 2 - 1);
						break;
					}
				}
				return;
			}
			if (who.hX != 0 && (Math.abs(who.man._y - who._y) > 1 || Math.abs(who.hX - who.max._x))){
				trace('Moving');
				who.attachSpd = (1 + 4 / animating.worldTimeSpeed);
				who.man._x += (who.hX - who.man._x) / who.attachSpd;
				who.man._y += (who._y - who.man._y) / who.attachSpd;
				return;
			}
			if (who.man.model.stat != 'level_pull'){
				who.hX = 0;
				animating.changeStat(who.h.model, 'level_pull');
				animating.changeStat(who, 'check_' + (1==1));
			}
			animating.animateOnly(who, 1/6);
		});
		return newLever;	
	}
}