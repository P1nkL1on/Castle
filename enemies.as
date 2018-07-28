class enemies{
	static function spawnElectroMage (X, Y):MovieClip{
		var shad:MovieClip = spawning.makeShadowMovable(spawning.spawnUnit('electro_mage', X, Y));
		// . . . model problems
		// . . . lastDirection == face side back
		shad.model.xs *= -1;
		shad.model.handSpd = 4;
		shad.model.stop(); shad.model.head.stop();
		shad.stad = 0;
		shad.nowStand = true;
		shad.onStepFunction = function(who:MovieClip){
			who.nowStand = !who.nowStand;
			who.model.gotoAndStop(((who.nowStand == true)? "idle" : "move") + who.stad + "_"+who.direction);
			who.model.head.gotoAndStop(who.head_frames[who.model._currentframe -1] + 1);
			// . . . hand control
			who.model.left_hand.b._x -= (who.model.left_hand._x - who.model.left_hand.b.prevX);
			who.model.left_hand.b.prevX = who.model.left_hand._x;
			who.model.left_hand.b._y -= (who.model.left_hand._y - who.model.left_hand.b.prevY);
			who.model.left_hand.b.prevY = who.model.left_hand._y;
			who.model.left_hand.b._rotation -= (who.model.left_hand._rotation - who.model.left_hand.b.prevRot);
			who.model.left_hand.b.prevRot = who.model.left_hand._rotation;
			
			who.model.right_hand.b._x -= (who.model.right_hand._x - who.model.right_hand.b.prevX);
			who.model.right_hand.b.prevX = who.model.right_hand._x;
			who.model.right_hand.b._y -= (who.model.right_hand._y - who.model.right_hand.b.prevY);
			who.model.right_hand.b.prevY = who.model.right_hand._y;
			who.model.right_hand.b._rotation -= (who.model.right_hand._rotation - who.model.right_hand.b.prevRot);
			who.model.right_hand.b.prevRot = who.model.right_hand._rotation;
		}
		shad.slotsForExecute.push(function(who:MovieClip){
			if (who.spd_squared > .2){
				shad.direction = 'face';
				if (who.sp_y < -.6)
					shad.direction = 'back';
			}	
		});
		// . . . want move and some options
		shad = spawning.makeShadowWantMove(shad);
		// . . . parameters of moment
		shad.acs = 0.15;
		shad.max_spd = 2; 
		shad.max_spd_squared = 4;
		shad.distanceForStep = 40;	
		
		shad.distanceForSteps = new Array(40, 90, 140, 190, 250, 300);
		shad.max_spds = new Array(1.5, 2, 2.5, 3, 4, 6);
		shad.head_frames = new Array();
		for (var i = 0; i < 6; ++i)
			shad.head_frames.push(i*2,i*2+1,i*2,i*2+1);
		trace(shad.head_frames);
		shad.max_spd_squareds = new Array();
		for (var i = 0; i < shad.max_spds.length; ++i)
			shad.max_spd_squareds.push(shad.max_spds[i] * shad.max_spds[i]);
		// . . .
		shad.slotsForExecute.push(function(who:MovieClip){
			who.wantLeft = (_root._xmouse < who._x);
			who.wantRight = (_root._xmouse > who._x);
			who.wantUp = (_root._ymouse < who._y);
			who.wantDown = (_root._ymouse > who._y);
		});
		shad.onMouseUp = function(){
			shad.stad ++;
			shad.max_spd = shad.max_spds[shad.stad];
			shad.max_spd_squared = shad.max_spd_squareds[shad.stad];
			shad.distanceForStep = shad.distanceForSteps[shad.stad];
		}
		return shad;
	}

}