class enemies_inv
{

	static function slowFollow(who:MovieClip, toX, toY, spd, dist){
		if (dist == undefined) dist = -1;
		// if (Math.abs(who.host._x - who.host.targetX) < 20 && 
			// Math.abs(who.host._y - who.host.targetY) < 20)
				// spd += 10;
		spawning.lsp_x = spawning.lsp_y = 0;
		spawning.lsp_x += spawning.tryMoveX(who, (toX - who._x) / spd);
		spawning.lsp_y += spawning.tryMoveY(who, (toY - who._y) / spd);
		if (dist > 10)
			while (Math.sqrt((who._x - toX)*(who._x - toX)+(who._y - toY)*(who._y - toY)) > dist){	
				spawning.lsp_x += spawning.tryMoveX(who, (toX - who._x) / 8);
				spawning.lsp_y += spawning.tryMoveY(who, (toY - who._y) / 8);
			}
		who.model.body._rotation = Math.atan2(spawning.lsp_y, spawning.lsp_x)/Math.PI*180+180;
		who.last_sp_x = spawning.lsp_x;
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
			sounds.playSound('voices/lizard/openmouth4');
			shad.sound_khh = sounds.playSound('voices/lizard/openmouth1');
		}
		shad.closeMouth = function(){
			if (!shad.mouthOpened)
				return;
			shad.mouthOpened = false;
			shad.head_anim_spd = 40;
			shad.model.head.gotoAndStop(1);
			shad.sound_khh.stop();
			sounds.playSound('voices/lizard/openmouth3');
		}
		shad.injures = 0;
		shad.injures_min = -3;	// bravery
		shad.injures_max = 3;
		shad.regen_spd = 1 / (5 * 60);
		
		shad.onAttacked = function(byWho:MovieClip, hited){
			if (who.destroyed == true)
				return;	
			trace('Snake attacked by :: ' + byWho._name);
			shad.nextState(-1);
			shad.aiTimer = 0;
			
			shad.max_spd = 30;
			var ddx = (shad._x > shad.unitTarget._x) * 2 - 1;
			var ddy = (shad._y > shad.unitTarget._y) * 2 - 1;
			shad.targetX = shad._x + ddx * 180;
			shad.targetY = shad._y + ddy * 90;
			if (hited){
				shad.injures++;
				trace('Lizard injures = ' + shad.injures + '/' + shad.injures_max);
			}
		}
		
		// . . . health system
		shad.slotsForExecute.push(function(who:MovieClip){
			if (who.injures > who.injures_min)
				who.injures -= who.regen_spd * animating.worldTimeSpeed;
			if (who.injures > who.injures_max && !who.destroyed){
				who.destroyed = true;
				who.die();
			}
		});
		shad.die = function(){
			shad.sp_x = shad.sp_y = 0;
			shad.max_spd = 0;
			trace('Lizard destroyed!');
		}
		
		
		shad.slotsForExecute.push(function(who:MovieClip){	
			if (who.destroyed == true)
				return;	
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
			if (who.aiState == -1 && who.aiTimer > 50)
				who.nextState(random(4));
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
				if (who.aiTimer == 180)
					sounds.playSound('voices/lizard/openmouth2');
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
				if (who.aiTimer == 1 && who.lightTimer < 0){
					who.lightTimer = who.lightEach - 1;
					who.runS = sounds.playSound('voices/lizard/ship1');
				}
				if (who.aiTimer < 15){
					who.targetX += (who.targetX - who._x);
					who.targetY += (who.targetY - who._y);
				}
				if (who.aiTimer == 55){
					who.runS.stop();
					sounds.playSound('voices/lizard/ship2');
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
					Math.abs(who._y - who.targetY) < 40 && 
					who.freeRush == false){
						who.freeRush = true; who.battlecryed = false;}
				if (who.freeRush == true && who.max_spd > .05){
					if (who.battlecryed == false)
						{who.battlecryed = true ;
						sounds.playSound('voices/lizard/openmouth5');}
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
						who.freeRush = false;
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
		shad.segmentCount = 15;
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
			segment.ww = 20;
			trace(i+' ;; ' + segment.ww);
			segment.slotsForExecute.push(function(who:MovieClip){
				slowFollow(who, who.follow._x, who.follow._y, 20, who.ww);	
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
			if (who.destroyed == true)
				return;	
			if (who.lightTimer >= 0)
				who.lightTimer+= animating.worldTimeSpeed;
			
			if (who.lightTimer > who.lightEach){
				var segmentNumber:Number = Math.round((who.lightTimer - who.lightEach) / who.timeForEachSegment) - 3;
				var seg:MovieClip = who.segments[segmentNumber].model;
				if (segmentNumber == -2)seg = who.model.liss;
				if (segmentNumber == -1)seg = who.model;
				if (segmentNumber == 2) who.model.liss.activateX = - 30;
				if (segmentNumber == 3) who.model.activateX = - 30;
				who.segments[segmentNumber - 3].model.activateX = -30;
				seg.activateX += 60 / who.timeForEachSegment;
			}
			if (who.lightTimer > who.lightEach + who.timeForEachSegment * (who.segmentCount + 2)){
				for (var i = 0; i < who.segments.length; ++i)
					who.segments[i].model.activateX = -30;
				who.lightTimer = (random(2)==0)? -60 : 10;
			}
					
		});
		// . . . simple movement system
		shad.max_spd = 8;
		shad.max_spd_squared = 64;
		shad.xs_last = shad.model._xscale;
		shad.slotsForExecute.push(function(who:MovieClip){
			if (who.destroyed == true)
				return;	
			if (who.xs_last != who.model._xscale){
				who.model.head._x *= -1;
				who.xs_last = who.model._xscale;
			}
			who.model.liss._x = who.model.head._x;
			who.model.liss._rotation = who.model.head._rotation;
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