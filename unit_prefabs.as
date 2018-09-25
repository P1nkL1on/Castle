 class unit_prefabs{
	static var guard_spd = new Array( 0.1, .3, .8, .2, .6, .7, .2, .5);
 
	static function spawnPrincessGuard(X, Y, xscal, torch):MovieClip{
		if (xscal == undefined)
			xscal = random(2)*2-1;
		var guard:MovieClip = 
			spawning.makeShadowWantMove(spawning.makeShadowMovable(spawning.spawnUnit('princessknight', X, Y)));
		guard.model._xscale =  85 * xscal;
		guard.weapon_model = 1+random(5);
		guard.head_model = 1+random(7);
		guard.hand2_model = 1+random(5);
		if (torch != undefined)
			guard.weapon_model = 6;
		
		guard.model.stop();
		guard.model.body.stop();
		guard.prevFr = guard.model._currentframe;
		guard.prevBFr = guard.model.body._currentframe;
		
		guard.idle = true; guard.idle_spd = 2+random(9)
		guard.max_spd = 0; guard.max_spd_squared = 0;
		
		guard.slotsForExecute.push(function(who:MovieClip){
			animating.animateOnly(who.model, 1/(15 + who.idle * (5 + who.idle_spd)));
			if (!who.idle)
				animating.animateOnly(who.model.body , 1 / 18);
				
			if (who.model.body._currentframe == 8)
				who.model.body.gotoAndStop('g1');
			// after all movements set frames
			who.model.hand_left.gotoAndStop(who.hand2_model);
			who.model.hand_right.gotoAndStop(who.weapon_model);
			who.model.head.gotoAndStop(who.head_model);
			
			if (who.prevFr != who.model._currentframe || 
				guard.prevBFr != guard.model.body._currentframe){
				who.prevFr = who.model._currentframe;
				guard.prevBFr = guard.model.body._currentframe;
				princessColor(new Array(who.model.head, who.model.hand_right, 
										who.model.hand_left, who.model.body));
			}
			
			who.max_spd = guard_spd[who.model.body._currentframe - 1];
			who.max_spd_squared = who.max_spd * who.max_spd;
		});
		guard.slotsForExecute.push(function(who:MovieClip){
			if (who.travelTo != undefined){
				if (who.travelFrom == undefined)
					who.travelFrom = who._x;
				if (who.dir == undefined)
					who.dir = 1;
					
				if (who.dir > 0) who.wantRight = true;
				if (who.dir < 0) who.wantLeft = true;
				who.idle = who.dir == 0;
				if ((who.dir > 0 && who._x > who.travelTo) || 
					(who.dir < 0 && who._x < who.travelFrom)){
					who.wantLeft = who.wantRight = false;
					if (true) { who.dir *= -1;
										who._x += who.dir * 2; trace('a');}
				}
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