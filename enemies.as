class enemies{
	static function spawnElectroMage (X, Y):MovieClip{
		var shad:MovieClip = spawning.makeShadowMovable(spawning.spawnUnit('electro_mage', X, Y));
		// . . . model problems
		// . . . lastDirection == face side back
		// cause unit is watching in other then usuall side
		shad.model.xs *= -1;
		// speed of hands following on model
		shad.model.handSpd = 7;
		// blocks
		shad.model.stop(); shad.model.head.stop();
		// the level of fury (recieved by pain, descreced by time)
		shad.stad = 0;
		// is the frame 0 or 1 for movement
		shad.nowStand = true;
		shad.model.cosPhase = 0; // phase of all coses
		shad.model.cosA = 0;	// amplitudes
		shad.model.flyHeight = 0;	// height of flying
		
		// set random sparkle on body
		shad.setElectricity = function(who:MovieClip){
			ground.spawnEffect(
			'effect_electro_circle',
			(random(61)-30) / 60 * who.model._width * .5,
			-random(100)/100 * who.model._height * .6 - 20,
			undefined, who.model);
		}
		// each step what
		shad.onStepFunction = function(who:MovieClip){
			// spawn electricity if cool
			if (who.stad >= 3)
				who.setElectricity(who);
			// reset speed (cause stepping)
			shad.max_spd = shad.max_spds[shad.stad];
			shad.max_spd_squared = shad.max_spd_squareds[shad.stad];
			// stand toggle
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
		// direction detection
		shad.slotsForExecute.push(function(who:MovieClip){
			if (who.spd_squared > .2){
				shad.direction = 'face';
				if (who.sp_y < -.3)
					shad.direction = 'back';
				if (who.stad < 4){
					who.max_spd /= (1.05);
					who.max_spd_squared /= (1.05 * 1.05);
				}
			}else{
				//who.stand = true;
				if (animating.each(who, 1/ 45) > 0){
					if ((who.stad <= 1 || who.stad >= 4))
						who.onStepFunction(who);
					if (who.stad >= 3)
						who.setElectricity(who);
				}
			}
			// . . . model animation
			who.model.cosPhase += .6 * animating.worldTimeSpeed;
			if (who.model.cosA > .3){
				who.model.cosA /= (1 + .15 * animating.worldTimeSpeed);
				who.model._yscale = 100 - who.model.cosA * Math.cos(who.model.cosPhase);
			}
			// . . . extra
			if (who.stad >= 4 && random(35) == 0)
				who.setElectricity(who);
			// . . . flying
			who._z = who.model.flyHeight + Math.cos(who.model.cosPhase / 10) * who.model.flyHeight * .5;
			if (Math.abs(who.model.flyHeight - who.required_height)){
				if (who.model.flyHeight < who.required_height)
					who.model.flyHeight += animating.worldTimeSpeed * .5;
				if (who.model.flyHeight > who.required_height)
					who.model.flyHeight -= animating.worldTimeSpeed * 3.5;
			}
		});
		// . . . want move and some options
		shad = spawning.makeShadowWantMove(shad);
		// . . . parameters of moment
		shad.acs = 0.15;
		shad.max_spd = 2; 
		shad.max_spd_squared = 4;
		shad.distanceForStep = 40;	
		
		shad.distanceForSteps = new Array(60, 70, 100, 150, 160, 170);
		shad.max_spds = new Array(1.5, 2, 2.5, 5, 4, 6);
		shad.required_heights = new Array(0,0,0,0, 18, 40);
		shad.required_height = 0;
		shad.head_frames = new Array();
		for (var i = 0; i < 6; ++i)
			shad.head_frames.push(i*2,i*2+1,i*2,i*2+1);
		trace(shad.head_frames);
		shad.max_spd_squareds = new Array();
		for (var i = 0; i < shad.max_spds.length; ++i)
			shad.max_spd_squareds.push(shad.max_spds[i] * shad.max_spds[i]);
		// . . .
		shad.targetX = shad._x;
		shad.targetY = shad._y;
		shad.slotsForExecute.push(function(who:MovieClip){
			who.targetX = _root._xmouse;
			who.targetY = _root._ymouse;
			if (Math.abs(who._x - who.targetX) < 40 && Math.abs(who._y - who.targetY) < 40)
				{ who.wantLeft = who.wantRight = who.wantUp = who.wantDown = false; return;}
			who.wantLeft = (who.targetX < who._x - 5);
			who.wantRight = (who.targetX > who._x + 5);
			who.wantUp = (who.targetY < who._y - 5);
			who.wantDown = (who.targetY > who._y + 5);
		});
		shad.changeStad = function(who:MovieClip, addStad:Number){
			if (addStad == 0 || (who.stad + addStad < 0) || (who.stad + addStad > 5))
				return;
			shad.stad += addStad;
			shad.distanceForStep = shad.distanceForSteps[shad.stad];
			shad.model.cosPhase = 0;
			shad.model.cosA = 30;
			shad.onStepFunction(shad);
			shad.required_height = shad.required_heights[shad.stad];
		}
		shad.onMouseUp = function(){
			if (Key.isDown(Key.UP))
				shad.changeStad(shad, 1);
			else
				if (Key.isDown(Key.DOWN))
					shad.changeStad(shad, -1);
			
		}
		return shad;
	}

}