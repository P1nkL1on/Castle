class ground{
	static var waters:Array = new Array();
	
	static function makeGround (who:MovieClip, typ:String):MovieClip{
		who.groundSoundVariant = 1;
		for (var i = sounds.footStepsTypes.length - 1; i >= 0; i--)
			if (typ.indexOf(sounds.footStepsTypes[i]) >= 0)
			{ who.groundSoundVariant = sounds.footStepsCount[i]; who.groundType = sounds.footStepsTypes[i];
			  utils.trace("Decided, that ground type " + typ + " will use a sound " + sounds.footStepsTypes[i] + ";");return;}
		utils.trace("Type of ground '" + typ + "' is strange; No matchs with existed: " + sounds.footStepsTypes, 1);
	}
	static function spawnEffect(effectName:String, X, Y, notUniqName, layer):MovieClip{
		//trace(effectName + ' / ' + X +' / ' + Y);
		if (layer == undefined)
			layer = _root.layer_background;
		var dep:Number =  layer.getNextHighestDepth();
		var newEffect = layer.attachMovie(effectName, effectName + ((notUniqName == undefined)?("_" + dep):""), dep);
		newEffect._x = X; newEffect._y = Y;
		return newEffect;
	}
	static function spawnSlashWithHitbox (slashName, X, Y, notUniqName):MovieClip{
		var hb:MovieClip = spawnEffect(slashName +"_hitbox", X, Y, notUniqName);
		var effect:MovieClip  = spawnEffect(slashName, X, Y, notUniqName, _root.layer_effects);
		effect.hb = hb;
		hb.effect = effect;
		hb._visible = false;
		hb.ignore = false;
		return effect;
	}
	static var trueDep = 0;
	static function makeReflection (shad:MovieClip):MovieClip{
		var newReflection:MovieClip = _root.layer_unit_reflection.attachMovie
			(shad.model.modelName, shad.model._name + '_reflection', /*_root.layer_unit_reflection.getNextHighestDepth()*/ -(++trueDep));
		//shad.model.duplicateMovieClip(, shad.model.getDepth() * (-1) - 10);
		newReflection._yscale *= -1;
		//newReflection._alpha = 50;
		spawning.colorSomething(newReflection, 30, 50, 80);
		newReflection.shad = shad;
		shad.hasReflection = true;
		shad.lastCreatedReflection = newReflection;
		newReflection.onEnterFrame = function (){
			this._x = this.shad._x;
			this._y = this.shad._y + this.shad._z;
			this._visible = this.shad.model._visible;
			this.gotoAndStop(this.shad.model._currentframe);
			this._xscale = this.shad.model._xscale;
			//this.swapDepths(this.shad.model.getDepth());
			
			if (this.shad.isControllable == true){
				this.lefthand.gotoAndStop(this.shad.model.lefthand._currentframe);
				this.righthand.gotoAndStop(this.shad.model.righthand._currentframe);
				spawning.colorSomething(this.tint, utils.hero_armor_color[0], utils.hero_armor_color[1], utils.hero_armor_color[2]);
			}
		}
		utils.trace('Created reflection for ' + shad + ' :: ' + newReflection, utils.t_create);
		return newReflection;
	}	
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
		newWater._x = X; newWater._y = Y; newWater.V = littrs;
		newWater.maxFrame = 69;
		newWater.isWater = true;
		newWater.areFrame = 0;
		//newWater.instanciateCD = 0;
		// . . . drawing
		newWater.slotsForExecute.push(function(who:MovieClip){
			who.needFrame = Math.round((who.V / 30) * who.maxFrame);
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
			who.areFrame += (who.needFrame - who.areFrame) / (1 + 10/ animating.worldTimeSpeed); 
			who.drop.gotoAndStop(Math.round(who.areFrame) + 1);
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
				utils.trace('Removed water :: ' + who, utils.t_delete);
				who.waterLeft = 0;
				for (var i = 0; i < spawning.grounds.length; i++)
					if (spawning.grounds[i].isWater == true)
						who.waterLeft ++;
				if (who.waterLeft == 1){
					trueDep = 0;
					for (var i = 0; i < spawning.units.length; i++)
						if (spawning.units[i].hasReflection == true){
							utils.trace('Removed a reflection :: ' + spawning.units[i].lastCreatedReflection, utils.t_delete);
							spawning.units[i].lastCreatedReflection.removeMovieClip();
							spawning.units[i].hasReflection = false;
						}
					}
				who.removeMovieClip();
			}
		});
		newWater.slotsForExecute.push(function(who:MovieClip){
			// isparenie
			who.tt.text = Math.round(who.V * 1000) / 1000;
			if (animating.each(who, 1 / 15) > 0){
				who.V -= animating.worldTimeSpeed * (who.maxFrame + 2 - who.drop._currentframe)/who.maxFrame / (10 * 20 / who.temperature);
				who.foundNeightboors = 0;
				if (who.checkingForOther == true){
					var neis = foundAllWaterNeightBoors(who);
					who.foundNeightboors = neis.length;
					for (var i = 0; i < neis.length; ++i){
						// exchange V
						var gr = neis[i];
						if (Math.abs(gr.V - who.V) > 1){
							gr.checkingForOther = true;
							deltaWater = (gr.V - who.V) * waterExchangeSpeed * animating.worldTimeSpeed;
							gr.V -= deltaWater;
							who.V += deltaWater;
							if (who.isBlessed == true || gr.isBlessed == true)
								who.isBlessed = gr.isBlessed = true;
						}
					}
				}
				//who._alpha = 50 + 50 * who.checkingForOther;	
				who.checkingForOther = (who.foundNeightboors > 0);
			}
		});
		if (newWater._name.indexOf("reflection") < 0){
			newWater.isBlessed = false;
			newWater.blessTimer = 0;
			newWater.slotsForExecute.push(function(who:MovieClip){
				if (!who.isBlessed) 
					return;
				who.blessTimer -= animating.worldTimeSpeed;
				if (who.blessTimer < 0){
					who.blessTimer = (100 - who.drop._currentframe) / 5;
					
					who.lastSpawnedBless = ground.spawnEffect('effect_blessing', 
					who._x + random(Math.round(who._width)) - who._width / 2, 
					who._y+ random(Math.round(who._height)) - who._height / 2, 
					undefined, _root.layer_effects);
					who.lastSpawnedBless.isSmall = true;
				}
			});
		}
		addWaterReflection(newWater);
		waters.push(newWater);
		maybeAddReflections();
		
		return newWater;
	}
	static var waterCollisionKDefault = .45;
	static function foundAllWaterNeightBoors (who:MovieClip, waterCollisionK) : Array{
		var arr = new Array();
		if (waterCollisionK == undefined) 
			waterCollisionK = waterCollisionKDefault;
		if (who == null) 
			return arr;
		for (var i = 0; i < spawning.grounds.length; i++){
			var gr:MovieClip = spawning.grounds[i];
			if (gr != who && gr.isWater == true && (
				gr._x + gr._width * waterCollisionK > who._x - who._width * waterCollisionK
				&& gr._x - gr._width * waterCollisionK < who._x + who._width * waterCollisionK
				&& gr._y + gr._height * waterCollisionK > who._y - who._height * waterCollisionK
				&& gr._y - gr._height * waterCollisionK < who._y + who._height * waterCollisionK))
			arr.push(gr);
		}
		return arr;
	}
	
	static function foundALLWaterNeightBoors (who:MovieClip):Array{
		var resArr = new Array();
		var startFrom = 0;
		resArr.push(who)
		for (var step = 0; step < 5; ++step){
			var newRes = resArr;
			var added = 0;
			for (var cW = startFrom; cW < resArr.length; ++cW){
				var addToArr = foundAllWaterNeightBoors(resArr[cW], .5);
				added += addToArr;
				if (added == 0) continue;
				for (var i = 0; i < addToArr.length; ++i){
					var canAdd = true;
					for (var j = 0; j < newRes.length; ++j)
						if (newRes[j] == addToArr[i])
							{canAdd = false; break;}
					if (canAdd)
						newRes.push(addToArr[i]);
				}
			}
			if (added == 0) return resArr;
			startFrom = resArr.length;
			resArr = newRes;
		}
		return resArr;
	}
	
	static function isAnyWaterIn (X, Y):MovieClip{
		for (var i = 0; i < spawning.grounds.length; i++)
			if (spawning.grounds[i].isWater == true && (spawning.grounds[i].drop.hitTest(X, Y, true))) 
				return spawning.grounds[i];
		return null;
	}
	static var zoneFromX = -1;
	static var zoneFromY = -1;
	static var zoneToX = -1;
	static var zoneToY = -1;
	static function findHitBoxOfMovieClips(selectedMCs:Array){
		zoneFromX = selectedMCs[0]._x - selectedMCs[0]._width / 2;
		zoneFromY = selectedMCs[0]._y - selectedMCs[0]._height / 2;
		zoneToX = zoneFromX + selectedMCs[0]._width;
		zoneToY = zoneFromY + selectedMCs[0]._height;
		for (var i = 1; i < selectedMCs.length; ++i){
			var zoneFromXp = selectedMCs[i]._x - selectedMCs[i]._width / 2;
			var zoneFromYp = selectedMCs[i]._y - selectedMCs[i]._height / 2;
			var zoneToXp = zoneFromXp + selectedMCs[i]._width;
			var zoneToYp = zoneFromYp + selectedMCs[i]._height;
			
			if (zoneFromXp < zoneFromX) zoneFromX = zoneFromXp;
			if (zoneFromYp < zoneFromY) zoneFromY = zoneFromYp;
			if (zoneToXp > zoneToX) zoneToX = zoneToXp;
			if (zoneToYp > zoneToY) zoneToY = zoneToYp;
		}
		// finish
	}
	static var efStep = 18;
	static var distMn = 300;
	static function forEachWaterInGroupSpawnEffect(effectName, array, center, effectStep){
		if (center == undefined) center = null;
		if (effectStep == undefined) effectStep = efStep;
		findHitBoxOfMovieClips(array);
		
		var i = 0;
		for (var k = zoneFromX; k < zoneToX; k += effectStep, ++i)
		for (var k2 = zoneFromY; k2 < zoneToY; k2 += effectStep / 2)
			for (var ii = 0; ii < array.length; ++ii)
				if (array[ii].hitTest(k, k2)){
					var ef = ground.spawnEffect(effectName, k, k2);
					if (center == null) break;
					var distK =  1 - Math.sqrt((k - center._x) * (k - center._x) + (k2 - center._y) * (k2 - center._y)) / distMn;
					ef._xscale *= Math.max(.3, distK);
					ef._yscale *= Math.max(.3, distK);
					ef.timerOffset = 30 * (1 - distK);
					break;
				}
		
	}
	
	
	static function addWaterReflection(newWater:MovieClip){
		utils.trace('Adding a water filter', utils.t_create);
		var newReflection:MovieClip = spawning.spawnReflect("effect_water_drop");
		utils.trace(newReflection+" " + newWater, utils.t_create);
		newReflection._x = newWater._x; newReflection._y = newWater._y;
		newReflection.water = newWater;
		newWater.reflection = newReflection;
		newReflection._yscale *= .5;
		newReflection.onEnterFrame = function(){
			this.gotoAndStop(this.water.drop._currentframe);
		}
		//
	}
	static function maybeAddReflections (){
		if (waters.length > 0 || _root.alwaysAddReflections == true)
			for (var i = 0; i < spawning.units.length; i++)
				if (not(spawning.units[i].hasReflection == true) && spawning.units[i].mustHaveReflection == true)
					makeReflection(spawning.units[i]);
	}
	
	static var walls:Array = new Array();
	static function makeWall(newGround:MovieClip){
		utils.trace('Make a ground :: ' + newGround, utils.t_create);
		walls.push(newGround);
		newGround._alpha = 0;//._visible = false;
	}
}