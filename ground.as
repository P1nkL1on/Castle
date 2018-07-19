class ground{
	static var waters:Array = new Array();
	
	static function makeGround (who:MovieClip, typ:String):MovieClip{
		who.groundType = typ;
		who.groundSoundVariant = 1;
		for (var i = 0; i < sounds.footStepsTypes.length; i++)
			if (sounds.footStepsTypes[i] == typ)
			{ who.groundSoundVariant = sounds.footStepsCount[i]; return;}
		trace("Type pf ground '" + typ + "' is strange; No matchs with existed: " + sounds.footStepsTypes);
	}
	static function spawnEffect(effectName:String, X, Y):MovieClip{
		trace(effectName + ' / ' + X +' / ' + Y);
		var dep:Number =  _root.layer_background.getNextHighestDepth();
		var newEffect = _root.layer_background.attachMovie(effectName, "effect_" + effectName + "_" + dep, dep);
		newEffect._x = X; newEffect._y = Y;
		return newEffect;
	}
	static function makeReflection (shad:MovieClip):MovieClip{
		var newReflection:MovieClip = _root.layer_unit_reflection.attachMovie
			(shad.model.modelName, shad.model._name + '_reflection', _root.layer_unit_reflection.getNextHighestDepth());
		//shad.model.duplicateMovieClip(, shad.model.getDepth() * (-1) - 10);
		newReflection._yscale *= -1;
		newReflection._alpha = 50;
		newReflection.shad = shad;
		shad.hasReflection = true;
		newReflection.onEnterFrame = function (){
			this._x = this.shad._x;
			this._y = this.shad._y;
			this.gotoAndStop(this.shad.model._currentframe);
			this._xscale = this.shad.model._xscale;
			if (this.shad.isControllable){
				this.lefthand.gotoAndStop(this.shad.model.lefthand._currentframe);
				this.righthand.gotoAndStop(this.shad.model.righthandthand._currentframe);
			}
		}
		trace('Created reflection for ' + shad + ' :: ' + newReflection);
		return newReflection;
	}	
	static function addWater(X, Y, littrs){
		if (littrs == undefined) littrs = .5;
		var newWater:MovieClip = null;
		for (var i = 0; i < waters.length; ++i)
			if (waters[i].hitTest(X, Y, true)){
				newWater = waters[i];
				newWater.V += littrs;
				return;
			}
		newWater = spawning.spawnGround("water");
		var newReflection:MovieClip = spawning.spawnReflect("effect_water_drop");
		trace(newWater + '/' + newReflection);
		newWater._x = X; newWater._y = Y; newWater.V = littrs;
		// . . . drawing
		newWater.slotsForExecute.push(function(who:MovieClip){
			who.drop.gotoAndStop(1 + Math.round((who.V / 20) * 35));
		});
		newWater.temperature = 20;
		// . . . deleting
		newWater.slotsForExecute.push(function(who:MovieClip){
			// isparenie
		});
		newReflection._x = X; newReflection._y = Y;
		newReflection.water = newWater;
		newWater.reflection = newReflection;
		newReflection._yscale *= .5;
		newReflection.onEnterFrame = function(){
			this.gotoAndStop(this.water.drop._currentframe);
		}
		waters.push(newWater);
		if (waters.length > 0){
			for (var i = 0; i < spawning.units.length; i++)
				if (not(spawning.units[i].hasReflection == true) && spawning.units[i].mustHaveReflection == true)
					makeReflection(spawning.units[i]);
				
		}
		return newWater;
	}
}