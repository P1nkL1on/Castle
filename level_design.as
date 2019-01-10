class level_design {
	
	static function random_level_sequence (){
		var res = new Array(0, -1, 12, 11); //new Array(0, -1, 12, 11, 10);
		return res;
			
	}
	
	static function set_level_design (level_idnex:Number){
		switch(level_idnex){
			 case 10:
				skullKeyMachine(); break;
			 case 11:
				electroMagePrison(); break;
			 case 12:
				deathCorridor(); break;
				
				
			 case -1:
				redRoad('@'); break;
			 case 0:
				testRoom(); break;
				
			 default:
				utils.trace("Can not load level w index " + level_idnex, utils.t_game); return;
		}
		utils.trace("Loaded level w index " + level_idnex, utils.t_game);
	}
	
	
	
	static function skullKeyMachine (){
	
		utils.makeBasicLayers('ground');
		utils.makeHero(300,400);

		_root.exitDoor = 
		levels.makeLevelExit(
		hazards.makeKeyReciever(
		spawning.spawnUnit('door', 300, 135), 90, 4), 0, -40);

		var lever = hazards.spawnLever(300, 300)
		_root.exitDoor.triggerFunction = function(who:MovieClip, kLeft:Number){utils.trace('door will open, til keys: '+kLeft);}
		_root.exitDoor.openFunction = function(who:MovieClip){utils.trace('door OPEN'); _root.exitDoor.opened = true;}

		lever.checkFunction = function(who:MovieClip){
				items.spawnItem('key', 490-random(80),220-random(40));}
		lever.uncheckFunction = function(who:MovieClip){
			items.spawnItem('skull', 220-random(40),220-random(40));}
	}
	
	static function electroMagePrison(){
	
		utils.makeBasicLayers('electro_mage_ground');
		spawning.spawnUnit('foreground_electrmage_dungeon', 305, 455)
		utils.makeHero(300,400);
		var electromage = enemies_elm.spawnElectroMage(300,200);

		_root.exitDoor = 	
		levels.makeLevelExit(
		spawning.spawnUnit('door', 300, 60), 0, -40);

		levels.spawnCamera(300,200,1.43,true,true);
	}
	
	static function testRoom(){
		// !
		utils.hero_has_items[0] = utils.hero_has_items[1] = utils.hero_has_items[2] = utils.hero_has_items[3] = true;
		
		utils.setBasicConsts();
		utils.makeBasicLayers();
		utils.makeHero(300,360);
		
		spawning.spawnGround('ground_fragment');
		_root.alwaysAddReflections = true;
		for (var i = 0; i < 2; ++i){
			var water = spawning.spawnGround('water');
			water._x = 420 - i * 130; water._y = 185 - i * 10; water.drop.gotoAndStop(30);	
			ground.addWaterReflection(water);
		}
			
		_root.exitDoor = 
		levels.makeLevelExit(
		spawning.spawnUnit('door', 300, 130), 0, -50);	

		var lever = hazards.makeKeyReciever(hazards.spawnLever(460, 300), 50, 1);
		lever.checkFunction = function(who:MovieClip){
				_root.exitDoor.opened = true; 
				_root.alwaysAddReflections = undefined;
				//utils.hero_has_items[0] = utils.hero_has_items[1] = utils.hero_has_items[2] = utils.hero_has_items[3] = false;
			}
				// !
			
		var dialog = spawning.spawnUnit('dialog_test', 130, 250, true);
		dialogs.makeModelTalking(dialog.model, new Array(3,6,9,12,15, 18, 21), 'test/test');
		dialog.onTalkFinish = function(who:MovieClip){items.spawnItem('key', who._x + 50, who._y);};
		_root.dialog = dialog;
	}
	
	static function deathCorridor(){
	
		utils.makeBasicLayers('road_ground');
		utils.makeHero(306, 920);
		levels.makeLevelExit(_root.hero,-10,-980);
		// levels.makeLevelExit(spawning.spawnUnit('door', 290,-580), 0, -40);

		enemies_dark.makeShadowCorridor();
		levels.spawnCamera(300,720,.82,true,false);

		spawning.spawnUnit('foreground_corridor_hands', 295, 875);
		utils.setAllQuality('low');
	}
	
	static function redRoad(param){
		var g = utils.makeBasicLayers('none_ground');
		utils.makeHero(300,400);
		levels.makeLevelExit(_root.hero,0,-350);

		var lever = hazards.spawnLever(300, 300);
		lever.dddd = false;
		lever.slotsForExecute.push(function(who:MovieClip){
			if (who.hitTest(_root.hero)){
				
				_root.hero.locked = true;
				if (who.dddd == false){
					who.dddd = true;
					_root.hero.model.gotoAndStop('dead_hit');
					levels.prepareDieScreen();
				}
			}
		});

		g.num.text = param+"";

	}
}