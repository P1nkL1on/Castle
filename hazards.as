class hazards{
	static function spawnLever (X, Y):MovieClip{
		var newLever:MovieClip = spawning.spawnUnit("lever", X, Y);
		if (!(newLever._x > Number.MIN_VALUE))
			{trace('Can not spawn a lever;'); return null;}
			
		return newLever;	
	}
}