class sounds
{
	static var isLoaded:Boolean = false;
	//
	static var soundFolder:String = "sounds/";
	static var soundFileType:String = ".mp3";
	static var soundNames:Array = new Array();
	static var soundFiles:Array = new Array();
	
	//
	static function pushSounds(whatSounds:Array){
		for (var i = 0; i < whatSounds.length; i++)
			soundNames.push(whatSounds[i]);
		return;
	}
	static function footStepName(stepGroundType){
		return "footsteps/" + stepGroundType + "/stp";
	}
	static var footStepsTypes:Array = new Array();
	static var footStepsCount:Array = new Array();
	
	static function footstepSounds():Array{
		var sos:Array = new Array();
		footStepsTypes = new Array("ground", "met", "water");
		footStepsCount = new Array(15,		4,	    15		 );
		for (var i = 0; i < footStepsCount.length; i++)
			for (var j = 1; j <= footStepsCount[i]; j++)
				sos.push(footStepName(footStepsTypes[i]+"") + "" + j);
		return sos;
	}
	static function abilitySounds():Array{
		return new Array("footsteps/water/flush","weapons/sword_in","weapons/sword_attack","weapons/sword_out",
		"weapons/item_in","weapons/shield_out","weapons/bottle_out","weapons/shield_block","weapons/shield_unblock",
		"weapons/sword_hit_metall", "weapons/sword_hit_blood", "weapons/sword_parry", "weapons/stunned");
	}
	static function interactiveSounds():Array{
		return new Array("background/lever","background/door_open","background/key_open"
						,"background/shadow_corridor","background/shadow_scream","background/shadow_touch");
	}
	static function voiceName(path, number){
		return "voices/" + path + ""+ number;
	}
	
	static var voicesNames:Array = new Array();
	static var voicesCounts:Array = new Array();
	
	static function voiceSounds():Array{
	
		voicesNames = new Array("default/default", "test/test", "test_fast/test", "electro_mage/dead","GUI/move", "lizard/move","lizard/openmouth","lizard/ship");
		voicesCounts = new Array(1,				   3		   , 3				 ,7,					3,			3,			5,					2);
		var sos:Array = new Array();
		for (var i = 0; i < voicesNames.length; i++){
			for (var j = 1; j <= voicesCounts[i]; j++)
				sos.push(voiceName(voicesNames[i], j));
				/// !!!
			if (voicesNames[i] == "test/test")
				sos.push(voiceName(voicesNames[i], '_out'));
		}
		return sos;
	}
	static function effectSoudns():Array{
		var sos:Array = new Array();
		for (var i = 0; i <= 10; ++i)
			sos.push('effects/crackle' + i);
		for (var i = 0; i <= 1; ++i)
			sos.push('effects/light' + i);
		for (var i = 0; i <= 1; ++i)
			sos.push('effects/prelight' + i);
		return sos;
	}
	static function pushAllSounds(){
		pushSounds(footstepSounds());
		pushSounds(abilitySounds());
		pushSounds(interactiveSounds());
		pushSounds(voiceSounds());
		pushSounds(effectSoudns());
	}
	static function loadAllSounds(){
		if (isLoaded) return;
		utils.trace("Awaits loading of " + soundNames.length + " sounds;");
		for (var i = 0; i < soundNames.length; i++){
			soundFiles.push(new Sound());
										// ставим каждый на загрузку соответствующего адреса
			soundFiles[i].loadSound(soundFolder+"/"+soundNames[i]+soundFileType,false); 
			soundFiles[i].name = soundNames[i];
			soundFiles[i].isLoaded = false;
			soundFiles[i].onLoad = function(success:Boolean):Void { if (success){ this.isLoaded = true;}}	
		}
		isLoaded = true;
	}
	
	// Воспроизвести звук по имени. (Звук выбирается из массива sounds)
	static public function playSound(nam:String, times):Sound{
		if (times == undefined)
			times = 1;
		for (var i=0; i<soundFiles.length; i++)
			if (soundFiles[i].name == nam){ soundFiles[i].start(0, times);return soundFiles[i]; }															//воспроизвести звук совпадающий по имени
		utils.trace("No sound '"+nam+"' in library!", utils.t_error); 																			//если звука нет, бупнем и сообщим об ошибкe
		if (nam.indexOf('voices/') == 0 && nam.indexOf('default1') < 0)
			return playSound('voices/default/default1');
		return null;
	}
	//
	static var stepSoundX:Number = 0;
	static var stepSoundY:Number = 0;
	static public function playHeroFootStepSound(who:MovieClip){
		if (who.standingOn == undefined) who.standingOn = null;
		if (who.standingOn == null){
			if (who.standingOnError == undefined){ who.standingOnError = true;
				utils.trace("This is no step sound for " + who + ". Because he do not standing on anything;", 1);}
			return;
		}
		playSound(footStepName(who.standingOn.groundType) + ""+(random(who.standingOn.groundSoundVariant)+1));
		stepSoundX = who._x + ((who.stepOffsetX == undefined)? 0 : (random(Math.round(who.stepOffsetX))-who.stepOffsetX/2));
		stepSoundY = who._y + ((who.stepOffsetY == undefined)? 0 : (random(Math.round(who.stepOffsetY))-who.stepOffsetY/2));
		
		ground.spawnEffect("effect_step_" + who.standingOn.groundType, stepSoundX, stepSoundY);
	}
}