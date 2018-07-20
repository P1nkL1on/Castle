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
		//trace(effectName + ' / ' + X +' / ' + Y);
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
		shad.lastCreatedReflection = newReflection;
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
	static var waterCollisionK = .45;
	static var deltaWater:Number = 0;
	static var waterExchangeSpeed = .05;
	static var xOff:Number = 0;
	static var yOff:Number = 0;
	static var angOff:Number = 0;
	static function addWater(X, Y, littrs){
		if (littrs == undefined) littrs = .5;
		var newWater:MovieClip = null;
		for (var i = 0; i < waters.length; ++i)
			if (waters[i].hitTest(X, Y, true)){
				newWater = waters[i];
				newWater.V += littrs;
				newWater.checkingForOther = true;
				return;
			}
		newWater = spawning.spawnGround("water");
		var newReflection:MovieClip = spawning.spawnReflect("effect_water_drop");
		trace(newWater + '/' + newReflection);
		newWater._x = X; newWater._y = Y; newWater.V = littrs;
		newWater.maxFrame = 35;
		newWater.isWater = true;
		//newWater.instanciateCD = 0;
		// . . . drawing
		newWater.slotsForExecute.push(function(who:MovieClip){
			who.needFrame = 1 + Math.round((who.V / 30) * who.maxFrame);
			/* who.instanciateCD -= animating.worldTimeSpeed;
			if (who.instanciateCD <= 0 && who.needFrame > who.maxFrame){
				who.rad = who._width / 2;
				angOff = random(629)/100;
				xOff = who.rad * Math.cos(angOff);
				yOff = who.rad * Math.sin(angOff) / 2;
				ground.addWater(who._x + xOff, who._y + yOff, 1);
				who.V -= 1;
				who.instanciateCD = 10 * 60;
			} */
			who.drop.gotoAndStop(who.needFrame);
		});
		// . . . newightboor checkong
		newWater.checkingForOther = true;
		for (var i = 0; i < spawning.grounds.length; ++i)
			if (spawning.grounds[i].isWater == true)
				spawning.grounds[i].checkingForOther = true;	// at first moment make all water searching
		newWater.temperature = 20;
		// . . . deleting
		newWater.slotsForExecute.push(function(who:MovieClip){
			if (who.V < .1){
				who.reflection.removeMovieClip();
				trace('Removed water :: ' + who);
				who.waterLeft = 0;
				for (var i = 0; i < spawning.grounds.length; i++)
					if (spawning.grounds[i].isWater == true)
						who.waterLeft ++;
				if (who.waterLeft == 1)
					for (var i = 0; i < spawning.units.length; i++)
						if (spawning.units[i].hasReflection == true){
							trace('Removed a reflection :: ' + spawning.units[i].lastCreatedReflection);
							spawning.units[i].lastCreatedReflection.removeMovieClip();
							spawning.units[i].hasReflection = false;
						}
				who.removeMovieClip();
			}
		});
		newWater.slotsForExecute.push(function(who:MovieClip){
			// isparenie
			who.tt.text = Math.round(who.V * 1000) / 1000;
			if (animating.each(who, 1 / 15) > 0){
				who.V -= animating.worldTimeSpeed * (who.maxFrame + 2 - who.drop._currentframe) / (15 * /*number of seconds*/ 30 * 20 / who.temperature);
				who.foundNeightboors = 0;
				if (who.checkingForOther == true)
					for (var i = 0; i < spawning.grounds.length; i++){
						var gr:MovieClip = spawning.grounds[i];
						if (gr != who && gr.isWater == true && (
							gr._x + gr._width * waterCollisionK > who._x - who._width * waterCollisionK
							&& gr._x - gr._width * waterCollisionK < who._x + who._width * waterCollisionK
							&& gr._y + gr._height * waterCollisionK > who._y - who._height * waterCollisionK
							&& gr._y - gr._height * waterCollisionK < who._y + who._height * waterCollisionK)){
								// exchange V
								who.foundNeightboors++;
								if (Math.abs(gr.V - who.V) > 1){
									gr.checkingForOther = true;
									deltaWater = (gr.V - who.V) * waterExchangeSpeed * animating.worldTimeSpeed;
									gr.V -= deltaWater;
									who.V += deltaWater;
								}
							}
					}
				//who._alpha = 50 + 50 * who.checkingForOther;	
				who.checkingForOther = (who.foundNeightboors > 0);
			}
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