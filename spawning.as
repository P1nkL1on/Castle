class spawning{
	static var layers:Array = new Array();
	static var units:Array = new Array();
	static var grounds:Array = new Array();
	static var shadowLayer:String = "layer_background_shadow";
	static var unitLayer:String = "layer_unit";
	static var unitCountScene:Number = 0;
	static var newLayer:MovieClip = null;
	
	static function colorLayer(layerName, r, g, b, rOther, gOther, bOther){
		for (var i = 0; i < layers.length; ++i){
			if (layers[i].layerName == layerName)
				colorSomething(layers[i], r, g, b);
			else
				colorSomething(layers[i], rOther, gOther, bOther);
		}
	}
	static function colorSomething(who, r, g, b){
		//trace(who + " :: Color to RGB(" + r + ", " + g + ", " + b + ")");
		var clr:Color = new Color(who); 
		clr.setTransform({rb:r, gb:g, bb:b});
	}
	static function clearLayers(){
		var layerCount:Number = layers.length;
		for (var i = 0; i < layers.length; ++i){
			utils.trace('Deleting layer :: ' + layers[i], utils.t_delete);
			layers[i].removeMovieClip();
		}
		_root.camera.removeMovieClip();
		layers = new Array();
		utils.trace(layerCount + " layers cleared;", utils.t_delete);
	}
	static function createLayer (layerName){
		newLayer  = _root.attachMovie("layer", layerName, _root.getNextHighestDepth());
		newLayer.layerName = layerName;
		utils.trace('Created layer :: ' + newLayer, utils.t_create);
		layers.push(newLayer);
		return;
	}
	static function findLayer(layerName){
		for (var i = 0; i < layers.length; ++i)
			if (layers[i].layerName == layerName)
				return layers[i];
		return null;
	}
	static function spawnReflect(reflectionName):MovieClip{
		if (_root.layer_reflection == undefined)
			{createLayer("layer_reflection");}		// make a reflection if need
		var dep = _root.layer_reflection.getNextHighestDepth();	
		var newReflect = _root.layer_reflection.attachMovie(reflectionName, reflectionName + dep, dep);
		return newReflect;	
	}
	static var lastGroundSpawnedName:String = "none";
	static function spawnGround(groundName):MovieClip{
		if (_root.layer_background == undefined)
			{createLayer("layer_background");}		// make a background if need
		var newGround = _root.layer_background.attachMovie("ground_" + groundName, "ground_"+groundName+"_"+grounds.length, _root.layer_background.getNextHighestDepth());
		if (newGround == null)
			{utils.trace("Can not create ground " + groundName, utils.t_error); return;}
		if (groundName != "trigger")
			lastGroundSpawnedName = "ground_" + groundName;
		ground.makeGround(newGround, groundName);
		newGround.slotsForExecute = new Array();
		newGround.onEnterFrame = function (){
			for (var i = 0; i < this.slotsForExecute.length; ++i)
				this.slotsForExecute[i](this);
		}
		grounds.push(newGround);
		newGround = null;
		return grounds[grounds.length - 1];
	}
	static function spawnUnit(unitName, X, Y){
		if (X == undefined){X = 0; utils.trace("Spawning a " + unitName + " do not declare its X coordinate;",1);}
		if (Y == undefined){Y = 0; utils.trace("Spawning a " + unitName + " do not declare its Y coordinate;",1);}
		++unitCountScene;
		var newShadow = _root[shadowLayer+""].attachMovie("model_shadow", "shadow_"+unitCountScene, _root[shadowLayer+""].getNextHighestDepth());
		if (newShadow == null)
			{ utils.trace("Error in spawning shadow of " + unitName, utils.t_error); return null; }
		else
			utils.trace("Created a shadow for " + unitName + " :: " + newShadow, utils.t_create);
		newShadow._x = X; newShadow._y = Y;
		var newModel = _root[unitLayer+""].attachMovie("model_" + unitName, "model_"+unitName+"_"+unitCountScene, _root[unitLayer+""].getNextHighestDepth());
		if (newModel == null)
			{utils.trace("Error in spawning model of " + unitName, utils.t_delete); newShadow.removeMovieClip(); return null;}
		else
			utils.trace("Created a model for " + unitName + " :: " + newModel, utils.t_create);
		newModel._x = X; newModel._y = Y; 
		newShadow._z = 0;
		newShadow.sp_z = 0; newShadow.G = .2;
		newModel.xs = newModel._xscale;
		newModel.modelName = "model_" + unitName;
		// linking
		newModel.shadow = newShadow;
		newShadow.model = newModel;
		newShadow.slotsForExecute = new Array();
		newShadow.slotsForExecute.push(function(who:MovieClip){ who.model._x = who._x; who.model._y = who._y - who._z;});
		//this.model.swapDepths(-16000+Math.round(this._y)*30+Math.round(_x/20));
		newShadow.slotsForExecute.push(function(who:MovieClip){ 
			who.model.swapDepths(-16000+Math.round(who._y)*30+Math.round(who._x/20));
		});
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
		/// strange point
		newShadow._visible = false;
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
	
	static var distanceForStep:Number=  100;
	static function makeShadowWantMove(shad:MovieClip):MovieClip{
		shad.wantLeft = shad.wantRight = shad.wantUp = shad.wantDown = false;
		if (shad.sp_x == undefined)	shad.sp_x = 0; 
		if (shad.sp_y == undefined)	shad.sp_y = 0; 
		if (shad.acs == undefined){	shad.acs = 0.75; shad.acs0 = shad.acs;}
		if (shad.spd_mult == undefined) shad.spd_mult = 1;
		if (shad.lastDirection == undefined) shad.lastDirection = "face";
		if (shad.stepTimer == undefined) shad.stepTimer = 0;
		shad.distanceForStep = distanceForStep;
		shad.slotsForExecute.push(function(who:MovieClip){
			if (who.locked == true)
				return;
			if (who.acs0 < who.acs) 
				who.acs0 += .5;
			who.dir_x = who.dir_y = 0;
			if (who.wantLeft == true) who.dir_x -= 1;	
			if (who.wantRight == true) who.dir_x += 1;
			if (who.wantDown == true) who.dir_y += 1;
			if (who.wantUp == true) who.dir_y -= 1; 
			who.spd_mult = (isSloving())? .4 : 1;
			who.sp_x += who.dir_x * who.acs0 * deltaTimeSquared();			
			who.sp_y += who.dir_y * who.acs0 * deltaTimeSquared();
			who.isMoving = (who.dir_x != 0 || who.dir_y != 0);
			// . . . animation
			if (who.dir_x != 0){ shad.lastDirection = "side"; if (shad.model.ignoreTurning != true)shad.model._xscale = shad.model.xs * who.dir_x * (-1); }
			if (who.dir_y == 1 && who.dir_x == 0) shad.lastDirection = "face";
			if (who.dir_y == -1) shad.lastDirection = "back";
			// . . . sounding
			if (who.distanceForStep < 0)
				return;
			if (who.lsp > 0)
				who.stepTimer += who.lsp * 2 * (1 - who.slowing);
			var playStep:Boolean = (who.stepTimer > who.distanceForStep );
			while (who.stepTimer > who.distanceForStep )who.stepTimer -= who.distanceForStep;
			if (playStep){
				who.onStepFunction(who);
				sounds.playHeroFootStepSound(who);
			}
		});
		return shad;
	}
	static function makeShadowControllable(shad:MovieClip):MovieClip
	{
		shad.isControllable = true;
		
		shad = makeShadowWantMove(shad);
		shad.slotsForExecute.push(function(who:MovieClip){
			who.wantDown = Key.isDown(keyDown());
			who.wantUp = Key.isDown(keyUp());
			who.wantLeft = Key.isDown(keyLeft());
			who.wantRight = Key.isDown(keyRight());
		});
		shad.mustHaveReflection = true;
		return makeShadowMovable(shad);
	}
	static function tryMoveX(who, dX):Number{
		//trace(who+"-----"+who.ignoreWalls+"----"+dX+" . . . " + ground.walls.length);
		if (who.ignoreWalls == false)
			for (var i = 0; i < ground.walls.length; ++i)
				if (ground.walls[i].hitTest(who._x + dX, who._y, true))
					return 0;
		who._x += dX;	
		return dX;
	}
	static function tryMoveY(who, dY):Number{

		if (who.ignoreWalls == false)
			for (var i = 0; i < ground.walls.length; ++i)
				if (ground.walls[i].hitTest(who._x, who._y + dY, true))
					return 0;
		who._y += dY;	
		return dY;
	}
	static var lsp_x:Number = 0;
	static var lsp_y:Number = 0;
	static function lsp() : Number{
		return Math.sqrt(lsp_x * lsp_x + lsp_y * lsp_y);
	}
	static function makeShadowMovable(shad:MovieClip):MovieClip
	{
		shad.slowing = 0;
		shad.locked = false;
		shad.ignoreWalls = false;
		if (shad.sp_x == undefined)	shad.sp_x = 0; 
		if (shad.sp_y == undefined)	shad.sp_y = 0; 
		if (shad.spd_mult == undefined) shad.spd_mult = 1;
		if (shad.max_spd == undefined)			{shad.max_spd = 4; shad.max_spd_squared = shad.max_spd * shad.max_spd;}
		if (shad.spd_resid == undefined)		shad.spd_resid = 1;
		shad.slotsForExecute.push(function(who:MovieClip){
			who.sp_x -= deltaTime() * who.sp_x * who.spd_resid;
			who.sp_y -= deltaTime() * who.sp_y * who.spd_resid;
			who.spd_squared = (who.sp_x * who.sp_x + who.sp_y * who.sp_y);
			who.spd_resid = (who.isMoving == false && who.spd_squared < .2)? 1 : .1;
			while (who.spd_squared > who.max_spd_squared * who.spd_mult * who.spd_mult){
				who.sp_x /= 1.2; who.sp_y /= 1.2;
				who.spd_squared /= 1.44;
			}
			lsp_x = tryMoveX( who , who.sp_x * deltaTime() * (1 - who.slowing));
			lsp_y = tryMoveY( who, who.sp_y * animating.worldYKoeff * deltaTime() * (1 - who.slowing));
			if (who.distanceForStep > 0)
				shad.lsp = lsp();
			// . . . a place of standing
			if (who.spd_squared > 0 && animating.each(who, 1 / 15) > 0)
				// 4 times in second
				for (var i = grounds.length - 1; i >= 0 ; i--)
					if (grounds[i].hitTest(who._x, who._y, true))
						{ who.standingOn = grounds[i]; break;} 
		});
		return shad;
	}
	static var statCalculated:String = "none";
	static var spdCalculated:Number = .2;
	static var checkSpdSquare:Number = 1;
	static function makeHeroAnimation(shad:MovieClip):MovieClip{
		if (shad.lastDirection == undefined) shad.lastDirection = "face";
		shad.lastModelFrame=  -1;
		shad.reColor = function (){
			spawning.colorSomething(shad.model.tint, utils.hero_armor_color[0], utils.hero_armor_color[1], utils.hero_armor_color[2]);
		}
		shad.checkRecolor = function (shad:MovieClip){
			if (shad.model._currentframe != shad.lastModelFrame){
				shad.lastModelFrame = shad.model._currentframe;
				shad.reColor();
			}
		}
		shad.slotsForExecute.push(function(who:MovieClip){
			if (who.locked){
				animating.animateOnly(who.model, 1/6);
				who.checkRecolor(who);
				return;
			}
			statCalculated = "idle";
			spdCalculated = 1 / 30;
			checkSpdSquare = who.spd_squared * (1 - who.slowing) * (1 - who.slowing);
			if (checkSpdSquare > .1){ statCalculated = "walk"; spdCalculated = 1/ 15;}
			if (checkSpdSquare > who.max_spd_squared / 4){ statCalculated = "run"; spdCalculated = 1/ 7;}			
			animating.animate(who.model, statCalculated + "_" + who.lastDirection, spdCalculated);
			who.checkRecolor(who);
			
		});
		return shad;
	}
}