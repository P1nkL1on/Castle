 class utils{
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
 }