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
		footStepsCount = new Array(15,		4,	  4		 );
		for (var i = 0; i < footStepsCount.length; i++)
			for (var j = 1; j <= footStepsCount[i]; j++)
				sos.push(footStepName(footStepsTypes[i]+"") + "" + j);
		return sos;
	}
	static function abilitySounds():Array{
		return new Array("footsteps/water/flush","weapons/sword_in","weapons/sword_attack","weapons/sword_out","weapons/item_in");
	}
	static function pushAllSounds(){
		pushSounds(footstepSounds());
		pushSounds(abilitySounds());
	}
	static function loadAllSounds(){
		if (isLoaded) return;
		trace("Awaits loading of " + soundNames.length + " sounds;");
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
	static public function playSound(nam:String){
		for (var i=0; i<soundFiles.length; i++)
			if (soundFiles[i].name == nam){ soundFiles[i].start(0,1);return; }															//воспроизвести звук совпадающий по имени
		trace("No sound '"+nam+"' in library!"); 																			//если звука нет, бупнем и сообщим об ошибкe
	}
	//
	static public function playHeroFootStepSound(who:MovieClip){
		if (who.standingOn == undefined) who.standingOn = null;
		if (who.standingOn == null){
			trace("This is no step sound for " + who + ". Because he do not standing on anything;");
			return;
		}
		playSound(footStepName(who.standingOn.groundType) + ""+(random(who.standingOn.groundSoundVariant)+1));
		ground.spawnEffect("effect_step_" + who.standingOn.groundType, who._x, who._y);
	}
}