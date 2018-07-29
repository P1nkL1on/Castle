class enemies{
	static var boltVariants:Array = new Array(2,2,2);
	static var boltFrameLength:Array = new Array(3,2,1,5,6,7,8,9,10,11,12,13,14,15,16);//(5,5,5,10,16,12,10,8,6,6,4,4,2,2,2,1);
	static var soundNumber:Number = 0;
	static function spawnBolt(X,Y,Xt,Yt){
		var pre:Sound = sounds.playSound('effects/prelight'+((++soundNumber)%2));
		pre.onSoundComplete = function(){
			sounds.playSound('effects/light'+((soundNumber)%2));
			var bolt:Array = new Array();
			var boltNames:String = "bme";
			var dirX:Number = (X < Xt)? 1 : -1;
			var dirY:Number = (Y < Yt)? 1 : -1;
			var deltaX = Math.abs(X - Xt);
			var deltaY = Math.abs(Y - Yt);
			var coordMid:Array = new Array(
				X + dirX * (random(Math.round(deltaX * .4)) + deltaX * .1),
				Y + dirY * random(Math.round(deltaY)) - 80 - random(100),
				Xt - dirX * (random(Math.round(deltaX * .4)) + deltaX * .1),
				Yt - dirY * random(Math.round(deltaY)) - 80 - random(100)
			);
			for (var i = 0; i < 3; ++i){
				var last = ground.spawnEffect('effect_bolt', 0, 0, undefined, _root.layer_effects);
				last.gotoAndStop(boltNames.charAt(i) + random(boltVariants[i]));
				last.t = 3-i;
				last.onEnterFrame = function(){
					if (animating.each(this, 1 / enemies.boltFrameLength[this.t]) > 0){
						this.nextFrame(); ++this.t;
					}
				}
				bolt.push(last);
			}
			bolt[0]._xscale *= random(2)*2-1;
			bolt[1]._yscale *= random(2)*2-1;
			bolt[2]._xscale *= random(2)*2-1;
			
			bolt[0]._x = X; bolt[0]._y = Y;
			bolt[0]._height *= distanceKBetween(X, Y, coordMid[0], coordMid[1], 100);
			bolt[0]._rotation = angleBetween(X, Y, coordMid[0], coordMid[1]) + 90;
			
			bolt[1]._x = coordMid[0]; bolt[1]._y = coordMid[1];
			bolt[1]._width *= distanceKBetween(coordMid[0], coordMid[1],coordMid[2], coordMid[3], 150);
			bolt[1]._rotation = angleBetween(coordMid[0], coordMid[1], coordMid[2], coordMid[3]);
			
			bolt[2]._x = coordMid[2]; bolt[2]._y = coordMid[3];
			bolt[2]._height *= distanceKBetween(coordMid[2], coordMid[3], Xt, Yt, 150);
			bolt[2]._rotation = angleBetween(coordMid[2], coordMid[3], Xt, Yt) - 90;
		}
	}
	static function angleBetween(x0,y0,x1,y1):Number{
		return Math.atan2(y1-y0, x1-x0)/Math.PI * 180;
	}
	static function distanceKBetween(x0,y0,x1,y1, originalDistance):Number{
		return Math.sqrt(Math.pow(x0-x1,2) + Math.pow(y0-y1,2)) / originalDistance;
	}
	//static function 
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
			if (who.stad >= 4 && (random(350)<= 5 * animating.worldTimeSpeed * (who.stad - 3)))
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
		shad.targetY = shad._y + 30;
		shad.slotsForExecute.push(function(who:MovieClip){
			/* who.targetX = _root._xmouse;
			who.targetY = _root._ymouse; */
			if (Math.abs(who._x - who.targetX) < 20 && Math.abs(who._y - who.targetY) < 20)
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
			shad.targetX = 100+random(600);
			shad.targetY = 100+random(270);
		}
		return shad;
	}

}