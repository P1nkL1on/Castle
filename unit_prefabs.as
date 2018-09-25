 class unit_prefabs{
	static function spawnPrincessGuard(X, Y, xscal, torch):MovieClip{
		if (xscal == undefined)
			xscal = random(2)*2-1;
		var guard:MovieClip = 
			spawning.makeShadowMovable(spawning.spawnUnit('princessknight', X, Y));
		guard.model._xscale =  85 * xscal;
		guard.weapon_model = 1+random(5);
		guard.head_model = 1+random(7);
		guard.hand2_model = 1+random(5);
		if (torch != undefined)
			guard.weapon_model = 6;
		
		guard.model.gotoAndStop(random(6));
		guard.prevFr = guard.model._currentframe;
		guard.slotsForExecute.push(function(who:MovieClip){
			animating.animateOnly(who.model, 1/15);
			animating.animateOnly(who.model.body , 1 / 15);
			if (who.model.body._currentframe == 8)
				who.model.body.gotoAndStop('g1');
			// after all movements set frames
			who.model.hand_left.gotoAndStop(who.hand2_model);
			who.model.hand_right.gotoAndStop(who.weapon_model);
			who.model.head.gotoAndStop(who.head_model);
			
			if (who.prevFr != who.model._currentframe){
				who.prevFr = who.model._currentframe;
				princessColor(new Array(who.model.head, who.model.hand_right, 
										who.model.hand_left, who.model.body));
			}
		});
		
		return guard;
	}
	
	static function princessColor(what:Array){
		for (var i = 0; i < what.length; ++i){
			spawning.colorSomething(what[i].tintBlue, utils.princess_color[0], utils.princess_color[1], utils.princess_color[2]);
			spawning.colorSomething(what[i].tintYellow, utils.princess_color[3], utils.princess_color[4], utils.princess_color[5]);
		}
	}
 }