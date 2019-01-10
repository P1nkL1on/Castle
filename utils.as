 class utils{
 
	static var t_info = 0;
	static var t_warning = 1;
	static var t_error = 2;
	static var t_saveinfo = 3;
	static var t_dialoginfo = 4;
	static var t_create = 5;
	static var t_delete = 6;
	static var t_game = 7;
	static var t_combat = 8;
	static var able_messages =  "+++++++++";
	static var symbols:String = ">*#$%+~@!";
	static var ignored_messages = new Array();
	static var ignore_message_count = 0;
	static function clearIgnoredMessages(){
		ignored_messages = new Array();
		ignore_message_count = 0;
		for (var i = 0; i < able_messages.length; ++i)
			ignored_messages.push(0);
	}
	static function checkIgnoredMessages(){
		var missed:String = "You missed : ";
		for (var i = 0; i < ignored_messages.length; ++i)
			missed += symbols.charAt(i) + ' '+ignored_messages[i]+';  ';
		trace(missed);
		clearIgnoredMessages();
	}
	static function trace(S, traceType){
		if (S == undefined)
			S = "output error";
		if (traceType == undefined)
			traceType = 0;
		if (able_messages.charAt(traceType) == '-')
			{	if(ignored_messages.length == 0)clearIgnoredMessages(); ignored_messages[traceType]++; ignore_message_count++; return;}
		
		trace(symbols.charAt(traceType)+ " : " + S);
		if (ignore_message_count > 50)
			checkIgnoredMessages();
	}
 
	static function setBasicConsts(){
		sounds.pushAllSounds();
		sounds.loadAllSounds();
		animating.worldTimeSpeed = 1;
	}
 
	static function makeBasicLayers(basicGroundName):MovieClip{
		if (basicGroundName == undefined)
			basicGroundName = "ground_test_met";
		var basicGroundSpawned:MovieClip = spawning.spawnGround(basicGroundName);
		spawning.createLayer("layer_reflection");
		spawning.createLayer("layer_unit_reflection");
		_root.layer_unit_reflection.setMask(_root.layer_reflection);
		spawning.createLayer(spawning.shadowLayer);
		spawning.createLayer(spawning.unitLayer);
		spawning.createLayer("layer_effects");
		spawning.createLayer("layer_filters");
		levels.defaultCamera();
		fps.spawnCounter();
		utils.setAllQuality('high');
		return basicGroundSpawned;
	}
	
	// . . . color selectio
	static var hero_armor_color:Array = new Array(235, 70, 70);
	static var princess_color:Array = new Array(
				//72, 175, 242, // -- blue	
				//136, 182, 90,	// -- green
				//240, 163, 49, // -- orange
				//128, 129, 109, // -- gray
				208, 210, 206, // -- near white
				//24, 87, 132, // -- dark blue
				//15, 10, 10,	// -- black
				
				189, 153, 117 // -- mid
				//227, 87, 143 // -- bubblegum
				//69, 75, 61 // -- black
				//68, 124, 255 // -- cool blue
				);
	static var hero_has_items:Array = new Array(false, false, false, false);
	// sword , book , shield, bottle
	
	
	
	// more things
	static var game_difficulty:Number = 1;	// 0 - waffle, 1 - novice, .. 3 - master
	//static var game_timer_max:Number = -1;	// -1 == none, 120 = 120 mins
	static var game_timer_lasts:Number = -1;
	static var game_save_princess:Boolean = true;	// false - save prince
	
	static var graphics_quality:String = 'high';
	static var level_sequence:Array = new Array();
	
	static var lives_max = -1;
	static var lives = lives_max;
	static var lives_per_level_finish = 0;
	
	static function setLivesByDifficulty(diff){
		if (diff == 0){ lives = lives_max = -1; lives_per_level_finish = 0; }
		if (diff == 1){ lives = lives_max = 30; lives_per_level_finish = 5; }
		if (diff == 2){ lives = lives_max = 10; lives_per_level_finish = 1; }
		if (diff == 3){ lives = lives_max = 2; lives_per_level_finish = 2; }
	}
	
	static function diff_name():String{
		var diff:String = "---";
		if (game_difficulty == 0) diff = 'waffle';
		if (game_difficulty == 1) diff = 'novice';
		if (game_difficulty == 2) diff = 'experienced';
		if (game_difficulty == 3) diff = 'master';
		return diff;
	}
	
	static function setAllQuality (qual){
		if (graphics_quality == 'high'){
			_quality = qual;
			return;
		}
		if (graphics_quality == 'medium'){
			if (qual == 'high') _quality = 'medium';
			else	_quality = 'low';
			return;
		}
		_quality = 'low';
	}
	
	static function makeHero(X, Y){
		_root.hero = 
			heroAbilities.canHandleItems(
			spawning.makeHeroAnimation(
			spawning.makeShadowControllable(
			spawning.spawnUnit("hero", X, Y, true))));
		
		if (hero_has_items[0] == true)
			_root.hero = heroAbilities.giveSword(_root.hero);
		if (hero_has_items[1] == true)
			_root.hero = heroAbilities.giveCross(_root.hero);	
		if (hero_has_items[2] == true)
			_root.hero = heroAbilities.giveShield(_root.hero);
		if (hero_has_items[3] == true)
			_root.hero = heroAbilities.giveBottle(_root.hero);		
		levels.hero = _root.hero;
		levels.makeGUI();
		_root.hero = 
			spawning.makeDrawedHitbox(
			spawning.makeHealthy(_root.hero, 3, 2, 120, 150, 240));
	}
	
	static function makeHeroOnly(X, Y){
		spawning.createLayer(spawning.shadowLayer);
		spawning.createLayer(spawning.unitLayer);
		_root.hero = 
			spawning.makeHeroAnimation(
			spawning.makeShadowControllable(
			spawning.spawnUnit("hero", X, Y)));
	}

	static function spawnTutorialKeys (cas){
		var nam:String = (cas == 0)? 'GUI_tutorial_menu' : 'GUI_character_select_menu';
		var tutKey:MovieClip = _root.layer_GUI.attachMovie(nam, 
					'keyTutorial', _root.layer_GUI.getNextHighestDepth());
		tutKey._x = 320 - tutKey._width / 2;
		tutKey._y = 390;
	}
 }