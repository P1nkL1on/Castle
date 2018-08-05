class enemies_inv
{

	static function slowFollow(who:MovieClip, toX, toY, spd, dist){
		if (dist == undefined) dist = 3;
		if (Math.abs(who.host._x - who.host.targetX) < 20 && 
			Math.abs(who.host._y - who.host.targetY) < 20)
				spd += 10;
		spawning.lsp_x = spawning.tryMoveX(who, (toX - who._x) / spd);
		spawning.lsp_y = spawning.tryMoveY(who, (toY - who._y) / spd);
		if (who.distanceForStep > 0){
			who.en_lsp = spawning.lsp();
		}
	}
	static function spawnInvisibleLizard (X, Y):MovieClip{
		var shad:MovieClip = heroAbilities.makeHitable(spawning.makeShadowWantMove(spawning.makeShadowMovable(spawning.spawnUnit('lizard_body', X, Y))));
		shad.destroyed = false;
		shad.targetX = X;
		shad.targetY = Y+10;
		// . . . AI
		shad.targetPhase = 0;
		shad.targetRad = 0;
		shad.aiTimer = 0;
		shad.aiState = 0;
		shad.unitTarget = _root.hero;
		shad.breath = 0;
		shad.freeRush = false;
		shad.jumps = 0;
		shad.sppx = 0; shad.sppy = 0;
		shad.model.ignoreTurning = true;
		shad.mouthOpened = false;
		shad.nextState = function(num){
			if (num == undefined)
				shad.aiState++;
			else
				shad.aiState = num;
			shad.aiTimer = 0;
			trace('Lizard state :: ' 	+ shad.aiState);
		}
		shad.head_anim_spd = 30;
		shad.openMouth = function(){
			if (shad.mouthOpened)
				return;
			shad.mouthOpened = true;
			shad.model.head.gotoAndStop('open');
			shad.head_anim_spd = 8;
		}
		shad.closeMouth = function(){
			if (!shad.mouthOpened)
				return;
			shad.mouthOpened = false;
			shad.head_anim_spd = 40;
			shad.model.head.gotoAndStop(1);
		}
		shad.onAttacked = function(byWho:MovieClip){
			trace('Snake attacked by :: ' + byWho._name);
		}
		shad.slotsForExecute.push(function(who:MovieClip){
			who.model._xscale = ((who._x > who.unitTarget._x)*2-1)*100;
			who.nearMouth = who.model.head.hb.hitTest(who.unitTarget);
			if (who.model._xscale > 0)
				who.model.head._rotation = Math.atan2( who.unitTarget._y - who._y, who.unitTarget._x - who._x )/Math.PI*180+180;
			if (who.model._xscale < 0)
				who.model.head._rotation = Math.atan2( who._y - who.unitTarget._y, who.unitTarget._x - who._x )/Math.PI*180;
			animating.animateOnly(who.model.head, 1 / who.head_anim_spd);
			
			if (who.wasNearMouth != who.nearMouth){
				who.wasNearMouth = who.nearMouth;
				if (who.aiState == 3 || who.aiState == 2 || (who.aiState == 0 && who.aiTimer > 150)){
					if (who.nearMouth == true)
						who.openMouth();
					else
						who.closeMouth();
				}
			}
			
			if (who.aiState != 1 && (who.breath < 0 || who.breathStop == true)){
				if (who.breath < 600){
					who.breathStop = true;
					who.breath += 5 * animating.worldTimeSpeed;
				}else
					who.breathStop = false;
				who.sppx = who.sppy = 0;
				return;
			}
			who.aiTimer += animating.worldTimeSpeed;
			if (who.aiState == 0){	// walking by circles
				who.targetPhase += .02 * animating.worldTimeSpeed;
				if (who.aiTimer % 100 == 1)
					who.targetRad = 270+random(120);
				who.targetX = who.unitTarget._x + Math.cos(who.targetPhase) * who.targetRad;
				who.targetY = who.unitTarget._y + .5 * Math.sin(who.targetPhase) * who.targetRad;
				if (who.aiTimer > 180 && who.max_spd > .05){
					who.max_spd -= .05 * animating.worldTimeSpeed;
					who.max_spd_squared = who.max_spd * who.max_spd;
				}else{
					if (who.aiTimer > 180){
						who.nextState();
						who.max_spd = 30; who.max_spd_squared = 900;
						who.targetX = who.unitTarget._x;
						who.targetY = who.unitTarget._y;
						who.openMouth();
					}
				}
				who.jumps = 0;
			}
			if (who.aiState == 1){
				if (who.aiTimer == 1)
					who.lightTimer = who.lightEach - 1;
				if (who.aiTimer < 15){
					who.targetX += (who.targetX - who._x);
					who.targetY += (who.targetY - who._y);
				}
				if (who.aiTimer > 75){
					who.nextState();
					who.max_spd = 5; who.max_spd_squared = 25;
					who.targetX = who._x;
					who.targetY = who._y;
					who.closeMouth();
				}else{
					slowFollow(who, who.unitTarget._x, who.unitTarget._y, 60);
					who.max_spd /= 1.02;
					who.max_spd_squared /= 1.02 * 1.02;
				}
			}
			if (who.aiState == 2){
				if (who.aiTimer % 60 == 0){
					who.targetX = who.unitTarget._x + (random(150)+150)*(random(2)*2-1)
					who.targetY = who.unitTarget._y + (random(75)+75)*(random(2)*2-1)
				}	
				if (Math.abs(who._x - who.targetX) < 40 &&
					Math.abs(who._y - who.targetY) < 40)
						who.freeRush = true;
				if (who.freeRush == true && who.max_spd > .05){
					who.max_spd -= .05 * animating.worldTimeSpeed;
					who.max_spd_squared = who.max_spd * who.max_spd;
				}else{
					if (who.jumps < 2 && who.freeRush == true){
						who.jumps ++;
						who.nextState(1);
						who.max_spd = 30; who.max_spd_squared = 900;
						who.targetX = who.unitTarget._x;
						who.targetY = who.unitTarget._y;
						who.openMouth();
					}
				}
				if (who.aiTimer > 155){
					who.nextState((random(2)==0)? 3 : 0);
					who.max_spd = 8; who.max_spd_squared = 64;
					who.targetX = who._x;
					who.targetY = who._y;
				}
			}
			if (who.aiState == 3){
				who.max_spd = 20;
				who.max_spd_squared = 1;
				spawning.lsp_x = spawning.tryMoveX(who, Math.min(8, Math.max(-8, who.sppx)));
				spawning.lsp_y = spawning.tryMoveY(who, .5*Math.min(8, Math.max(-8, who.sppy)));
				who.stepTimer += spawning.lsp();
				who.sppx += .2 * ((who._x < who.unitTarget._x)*2-1);
				who.sppy += .2 * ((who._y < who.unitTarget._y)*2-1);
				who.targetX = who.unitTarget._x;
				who.targetY = who.unitTarget._y;
				if (who.aiTimer > 265){
					who.nextState(0);
					who.max_spd = 8; who.max_spd_squared = 64;
					who.targetX = who._x;
					who.targetY = who._y;
					who.closeMouth();
				}
			}
			who.breath -= who.spd_mult * animating.worldTimeSpeed;
		});
		shad.wasNearMouth = false;
		// . . . simple chain system
		shad.segmentCount = 17;
		shad.segmentSpd = 5;
		shad.stepOffsetX = 30;
		shad.stepOffsetY = 15;
		shad.segments = new Array();
		var prevSegment:MovieClip = null;
		for (var i = 0; i < shad.segmentCount; ++i){
			var segment:MovieClip = spawning.spawnUnit('lizard_body', X - 20*i, Y-5*i);
			segment.model.gotoAndStop(2+i);
			segment.follow = (prevSegment == null)? shad : prevSegment;
			prevSegment = segment;
			segment.segSpd = shad.segmentSpd - 1;
			segment.host = shad;
			if (i == 2){
				segment.stepOffsetX = 30;
				segment.stepOffsetY = 15;
				segment.stepTimer = 0;
				segment.distanceForStep = 100;
				segment.slotsForExecute.push(function(who:MovieClip){
					if (who.en_lsp > 0)
						who.stepTimer += who.en_lsp;
					var playStep:Boolean = (who.stepTimer > who.distanceForStep );
					while (who.stepTimer > who.distanceForStep )who.stepTimer -= who.distanceForStep;
					if (playStep){
						who.standingOn = who.host.standingOn;
						sounds.playHeroFootStepSound(who);
					}
				});
			}else 
				segment.distanceForStep = -1;
			segment.slotsForExecute.push(function(who:MovieClip){
				slowFollow(who, who.follow._x, who.follow._y, 1+(who.segSpd + Math.max(0, (8 - who.host.max_spd)) * 3)/animating.worldTimeSpeed, 20);	
			});
			shad.segments.push(segment);
			//segment.model._visible = false;
		}
		//shad.model._alpha = 10;//_visible = false;
		// . . . light system
		shad.curSegment = 0;
		shad.lightTimer = 0;
		shad.lightEach = 220;
		shad.timeForEachSegment = 4;
		shad.slotsForExecute.push(function(who:MovieClip){
			if (who.lightTimer >= 0)
				who.lightTimer+= animating.worldTimeSpeed;
			
			if (who.lightTimer > who.lightEach){
				var segmentNumber:Number = Math.round((who.lightTimer - who.lightEach) / who.timeForEachSegment) - 1;
				var seg:MovieClip = who.segments[segmentNumber - 1];
				if (segmentNumber <= 0)	seg = who;
				if (segmentNumber == 3) who.model.activateX = - 30;
				who.segments[segmentNumber - 3].model.activateX = -30;
				seg.model.activateX += 60 / who.timeForEachSegment;
			}
			if (who.lightTimer > who.lightEach + who.timeForEachSegment * who.segmentCount){
				for (var i = 0; i < who.segments.length; ++i)
					who.segments[i].model.activateX = -30;
				who.lightTimer = -60;
			}
					
		});
		// . . . simple movement system
		shad.max_spd = 8;
		shad.max_spd_squared = 64;
		shad.xs_last = shad.model._xscale;
		shad.slotsForExecute.push(function(who:MovieClip){
			if (who.xs_last != who.model._xscale){
				who.model.head._x *= -1;
				who.xs_last = who.model._xscale;
			}
			_root.pp._x = who.targetX;
			_root.pp._y = who.targetY - 30;
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