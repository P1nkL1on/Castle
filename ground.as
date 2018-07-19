class ground{
	static function makeGround (who:MovieClip, typ:String):MovieClip{
		who.groundType = typ;
		who.groundSoundVariant = 1;
		for (var i = 0; i < sounds.footStepsTypes.length; i++)
			if (sounds.footStepsTypes[i] == typ)
			{ who.groundSoundVariant = sounds.footStepsCount[i]; return;}
		trace("Type pf ground '" + typ + "' is strange; No matchs with existed: " + sounds.footStepsTypes);
	}
}