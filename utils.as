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
	static var able_messages =  "-++++++++";
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
		fps.spawnCounter();
		return basicGroundSpawned;
	}
	
	// . . . color selectio
	static var hero_armor_color:Array = new Array(255, 40, 40);
	static var hero_has_items:Array = new Array(true, false, false, true);
	// sword , book , shield, bottle
	
	static function makeHero(X, Y){
		_root.hero = 
			heroAbilities.canHandleItems(
			spawning.makeHeroAnimation(
			spawning.makeShadowControllable(
			spawning.spawnUnit("hero", X, Y))));
		
		if (hero_has_items[0] == true)
			_root.hero = heroAbilities.giveSword(_root.hero);
		if (hero_has_items[2] == true)
			_root.hero = heroAbilities.giveShield(_root.hero);
		if (hero_has_items[3] == true)
			_root.hero = heroAbilities.giveBottle(_root.hero);		
		levels.hero = _root.hero;
		levels.makeGUI();
	}
	
	static function makeHeroOnly(X, Y){
		spawning.createLayer(spawning.shadowLayer);
		spawning.createLayer(spawning.unitLayer);
		_root.hero = 
			spawning.makeHeroAnimation(
			spawning.makeShadowControllable(
			spawning.spawnUnit("hero", X, Y)));
	}

	
 }