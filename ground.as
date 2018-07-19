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
	static function makeReflection (shad:MovieClip, mask:MovieClip):MovieClip{
		trace("Made reflection for " + shad +' (' + shad.model + ') :: with mask :: ' + mask);
		var newReflection:MovieClip = shad.model.duplicateMovieClip(shad.model._name + '_reflection', shad.model.getDepth() - 1);
		newReflection._yscale *= -1;
		newReflection._alpha = 30;
		newReflection.shad = shad;
		newReflection.setMask(mask);
		if (mask.reflections == undefined)
			mask.reflections = new Array();
		mask.reflections.push(newReflection);
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
		newWater.slotsForExecute.push(function(who:MovieClip){
			who.drop.gotoAndStop(1 + Math.round((who.V / 20) * 35));
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
				if (not(spawning.units[i].hasReflection == true))
					makeReflection(spawning.units[i], _root.layer_reflection);
				
		}
		return newWater;
	}
}