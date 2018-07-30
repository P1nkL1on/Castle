 class utils{
 
	static var t_info = 0;
	static var t_warning = 1;
	static var t_error = 2;
	static var t_saveinfo = 3;
	
	static var symbols:String = ">*#$";
	
	static function trace(S, traceType){
		if (traceType == undefined)
			traceType = 0;
		trace(symbols.charAt(traceType)+ " : " + S);
	}
 
	static function setBasicConsts(){
		sounds.pushAllSounds();
		sounds.loadAllSounds();
		animating.worldTimeSpeed = 1;
	}
 
	static function makeBasicLayers(basicGroundName){
		if (basicGroundName == undefined)
			basicGroundName = "ground_test_met";
		spawning.spawnGround(basicGroundName);
		spawning.createLayer("layer_reflection");
		spawning.createLayer("layer_unit_reflection");
		_root.layer_unit_reflection.setMask(_root.layer_reflection);
		spawning.createLayer(spawning.shadowLayer);
		spawning.createLayer(spawning.unitLayer);
		spawning.createLayer("layer_effects");
		spawning.createLayer("layer_filters");
		fps.spawnCounter();
	}
	
	// . . . color selectio
	static var hero_armor_color:Array = new Array(255, 40, 40);
	
	static function makeHero(X, Y){
		_root.hero = 
			heroAbilities.giveSword(
			heroAbilities.giveShield(
			heroAbilities.giveBottle(
			heroAbilities.canHandleItems(
			spawning.makeHeroAnimation(
			spawning.makeShadowControllable(
			spawning.spawnUnit("hero", X, Y)))))));
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