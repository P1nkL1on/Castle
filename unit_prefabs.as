 class unit_prefabs{
	static function spawnPrincessGuard(X, Y):MovieClip{
		var shad:MovieClip = 
			spawning.makeShadowMovable(spawning.spawnUnit('princessknight', X, Y));
		return shad;
	}
 }