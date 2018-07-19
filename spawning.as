class spawning{
	static var layers:Array = new Array();
	static var units:Array = new Array();
	static var grounds:Array = new Array();
	static var shadowLayer:String = "layer_background_shadow";
	static var unitLayer:String = "layer_unit";
	static var unitCountScene:Number = 0;
	static var newLayer:MovieClip = null;
	
	
	static function createLayer (layerName){
		newLayer  = _root.attachMovie("layer", layerName, _root.getNextHighestDepth());
		newLayer.layerName = layerName;
		trace(newLayer);
		layers.push(newLayer);
		return;
	}
	static function findLayer(layerName){
		for (var i = 0; i < layers.length; ++i)
			if (layers[i].layerName == layerName)
				return layers[i];
		return null;
	}
	static function spawnGround(groundName){
		if (_root.layer_background == undefined)
			{createLayer("layer_background");}		// make a background if need
		var newGround = _root.layer_background.attachMovie("ground_" + groundName, "ground_"+groundName+"_"+grounds.length, _root.layer_background.getNextHighestDepth());
		if (newGround == null)
			{trace("Can not create ground " + groundName); return;}
		ground.makeGround(newGround, groundName);
		newGround.onEnterFrame = function (){
			if (animating.animate(this, 'none', 1 / 30) > 0)
				// 4 times in frame
				for (var i = 0; i < units.length; i++)
					if (this.hitTest(units[i]._x, units[i]._y, false))
						units[i].standingOn = this;
		}
		grounds.push(newGround);
		newGround = null;
		return newGround[newGround.length - 1];
	}
	static function spawnUnit(unitName, X, Y){
		if (X == undefined){X = 0; trace("Spawning a " + unitName + " do not declare its X coordinate;");}
		if (Y == undefined){Y = 0; trace("Spawning a " + unitName + " do not declare its Y coordinate;");}
		++unitCountScene;
		var newShadow = _root[shadowLayer+""].attachMovie("model_shadow", "shadow_"+unitCountScene, _root[shadowLayer+""].getNextHighestDepth());
		if (newShadow == null)
			{ trace("Error in spawning shadow of " + unitName); return null; }
		else
			trace("Created a shadow for " + unitName + " :: " + newShadow);
		newShadow._x = X; newShadow._y = Y;
		var newModel = _root[unitLayer+""].attachMovie("model_" + unitName, "model_"+unitName+"_"+unitCountScene, _root[unitLayer+""].getNextHighestDepth());
		if (newModel == null)
			{trace("Error in spawning model of " + unitName); newShadow.removeMovieClip(); return null;}
		else
			trace("Created a model for " + unitName + " :: " + newModel);
		newModel._x = X; newModel._y = Y;
		newModel.xs = newModel._xscale;
		// linking
		newModel.shadow = newShadow;
		newShadow.model = newModel;
		newShadow.slotsForExecute = new Array();
		newShadow.slotsForExecute.push(function(who:MovieClip){ who.model._x = who._x; who.model._y = who._y; });
		// set executing order
		newShadow.onEnterFrame = function(){
			for (var i = 0; i < this.slotsForExecute.length; ++i){
				this.slotsForExecute[i](this);
			}
		}
		// adding
		units.push(newShadow);
		// .. clear for nonbuggy other
		newModel = newShadow = null;
		return units[units.length - 1];
	}
	static var movementKeys:Array = new Array(37,38,39,40,18);
	
	static function keyLeft(){return movementKeys[0];}
	static function keyUp(){return movementKeys[1];}
	static function keyRight(){return movementKeys[2];}
	static function keyDown(){return movementKeys[3];}
	static function isSloving(){return Key.isDown(movementKeys[4]);}
	
	static function deltaTime(){return animating.worldTimeSpeed;}
	static function deltaTimeSquared(){return animating.worldTimeSpeed * animating.worldTimeSpeed;}
	static var dir_x:Number = 0;
	static var dir_y:Number = 0;
	static var distanceForStep:Number=  80;
	static function makeShadowControllable(shad:MovieClip):MovieClip
	{
		if (shad.sp_x == undefined)	shad.sp_x = 0; 
		if (shad.sp_y == undefined)	shad.sp_y = 0; 
		if (shad.acs == undefined)	shad.acs = 0.75; 
		if (shad.spd_mult == undefined) shad.spd_mult = 1;
		if (shad.lastDirection == undefined) shad.lastDirection = "face";
		if (shad.stepTimer == undefined) shad.stepTimer = 0;
		shad.slotsForExecute.push(function(who:MovieClip){
			dir_x = dir_y = 0;
			if (Key.isDown(keyLeft())) dir_x -= 1;	
			if (Key.isDown(keyRight())) dir_x += 1;
			if (Key.isDown(keyDown())) dir_y += 1;
			if (Key.isDown(keyUp())) dir_y -= 1; 
			who.spd_mult = (isSloving())? .4 : 1;
			who.sp_x += dir_x * who.acs * deltaTimeSquared();			
			who.sp_y += dir_y * who.acs * deltaTimeSquared();
			who.isMoving = (dir_x != 0 || dir_y != 0);
			// . . . animation
			if (dir_x != 0){ shad.lastDirection = "side"; shad.model._xscale = shad.model.xs * dir_x * (-1); }
			if (dir_y == 1 && dir_x == 0) shad.lastDirection = "face";
			if (dir_y == -1) shad.lastDirection = "back";
			// . . . sounding
			who.stepTimer += Math.abs(who.sp_x) + Math.abs(who.sp_y);
			var playStep:Boolean = (who.stepTimer > distanceForStep );
			while (who.stepTimer > distanceForStep )who.stepTimer -= distanceForStep;
			if (playStep)
				sounds.playHeroFootStepSound(who);
		});
		
		return makeShadowMovable(shad);
	}
	static function makeShadowMovable(shad:MovieClip):MovieClip
	{
		if (shad.sp_x == undefined)	shad.sp_x = 0; 
		if (shad.sp_y == undefined)	shad.sp_y = 0; 
		if (shad.spd_mult == undefined) shad.spd_mult = 1;
		if (shad.max_spd == undefined)			{shad.max_spd = 4; shad.max_spd_squared = shad.max_spd * shad.max_spd;}
		if (shad.spd_resid == undefined)		shad.spd_resid = 1;
		shad.slotsForExecute.push(function(who:MovieClip){
			who.sp_x -= deltaTime() * who.sp_x * who.spd_resid;
			who.sp_y -= deltaTime() * who.sp_y * who.spd_resid;
			who.spd_squared = who.sp_x * who.sp_x + who.sp_y * who.sp_y;
			who.spd_resid = (who.isMoving == false && who.spd_squared < .2)? 1 : .1;
			while (who.spd_squared > who.max_spd_squared * who.spd_mult * who.spd_mult){
				who.sp_x /= 1.2; who.sp_y /= 1.2;
				who.spd_squared /= 1.44;
			}
			who._x += who.sp_x;
			who._y += who.sp_y * animating.worldYKoeff;
		});
		return shad;
	}
	static var statCalculated:String = "none";
	static var spdCalculated:Number = .2;
	static function makeHeroAnimation(shad:MovieClip):MovieClip{
		if (shad.lastDirection == undefined) shad.lastDirection = "face";
		
		shad.slotsForExecute.push(function(who:MovieClip){
			statCalculated = "idle";
			spdCalculated = 1 / 30;
			if (who.spd_squared > .5){ statCalculated = "walk"; spdCalculated = 1/ 15;}
			if (who.spd_squared > who.max_spd_squared / 4){ statCalculated = "run"; spdCalculated = 1/ 7;}			
			animating.animate(who.model, statCalculated + "_" + who.lastDirection, spdCalculated);
		});
		return shad;
	}
}