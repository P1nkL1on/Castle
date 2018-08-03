class enemies_inv
{

	static function slowFollow(who:MovieClip, toX, toY, spd){
		who._x += (toX - who._x) / spd;
		who._y += (toY - who._y) / spd;
	}
	static function spawnInvisibleLizard (X, Y):MovieClip{
		var shad:MovieClip = heroAbilities.makeHitable(spawning.makeShadowWantMove(spawning.makeShadowMovable(spawning.spawnUnit('lizard_body', X, Y))));
		shad.destroyed = false;
		shad.targetX = X;
		shad.targetY = Y+10;
		// . . . simple chain system
		shad.segmentCount = 10;
		shad.segments = new Array();
		var prevSegment:MovieClip = null;
		for (var i = 0; i < shad.segmentCount; ++i){
			var segment:MovieClip = spawning.spawnUnit('lizard_segment', X - 20*i, Y-5*i);
			segment.follow = (prevSegment == null)? shad : prevSegment;
			prevSegment = segment;
			segment.distanceForStep = -1;
			segment.slotsForExecute.push(function(who:MovieClip){
				slowFollow(who, who.follow._x, who.follow._y, 1+3/animating.worldTimeSpeed);	
			});
			shad.segments.push(segment);
		}
		// . . . simple movement system
		shad.max_spd = 8;
		shad.max_spd_squared = 64;
		shad.slotsForExecute.push(function(who:MovieClip){
			who.targetX = _root._xmouse;
			who.targetY = _root._ymouse;
			if (who.destroyed == true || (Math.abs(who._x - who.targetX) < 20 && Math.abs(who._y - who.targetY) < 20))
				{ who.wantLeft = who.wantRight = who.wantUp = who.wantDown = false; return;}
			who.wantLeft = (who.targetX < who._x - 5);
			who.wantRight = (who.targetX > who._x + 5);
			who.wantUp = (who.targetY < who._y - 5);
			who.wantDown = (who.targetY > who._y + 5);
		});
		return shad;
	}
}