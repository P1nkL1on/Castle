class enemies{
	static function spawnElectroMage (X, Y):MovieClip{
		var shad:MovieClip = spawning.makeShadowMovable(spawning.spawnUnit('electro_mage', X, Y));
		shad.model.handSpd = 10;
		shad.model.stop(); shad.model.head.stop();	
		// . . . want move and some options
		shad = spawning.makeShadowWantMove(shad);
		// . . . parameters of moment
		shad.acs = 0.75;
		shad.max_spd = 4; 
		shad.max_spd_squared = 16;
		shad.distanceForStep = 50;		
		// . . .
		shad.slotsForExecute.push(function(who:MovieClip){
			who.wantLeft = (_root._xmouse < who._x);
			who.wantRight = (_root._xmouse > who._x);
			who.wantUp = (_root._ymouse < who._y);
			who.wantDown = (_root._ymouse > who._y);
		});
		return shad;
	}

}