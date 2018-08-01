class levels{
	static var testLevels:Array = new Array(3,4,6,5,4);
	
	static function selectNextLevel():Number{
		return testLevels.pop()+0;
	}
	static function completeLevel(number:Number){
		utils.trace('Level :: ' + number + " :: COMPLETED!", utils.t_game);
		_root.gotoAndStop('level_selection');
	}
	
	
	static var camera:MovieClip= null;
	//	* cameraSlow == undefined | 1 -> follow usuall
	//	* cameraSlow == 2+			  -> follow very slow
	//	* cameraSlow <  0			  -> stepps
	//	* 
	static function spawnCamera(X, Y, 
								cameraScale,
								xlocked,
								ylocked, 
								cameraSlow):MovieClip{
		camera = _root.attachMovie('camera', 'camera', _root.getNextHighestDepth());
		camera._height = 400; camera._width = 600;
		camera._x = X; camera._y = Y;
		camera.xlocked = (xlocked == undefined)? false : xlocked;
		camera.ylocked = (ylocked == undefined)? false : ylocked;
		if (cameraScale != undefined){	
			camera._xscale = camera._yscale = 100 * cameraScale;
			_root.layer_GUI._xscale = _root.layer_GUI._yscale = 100 * cameraScale;
		}
		camera.cameraSlow = (cameraSlow == undefined)? 1 : cameraSlow;
		
		camera.follow = _root.hero;
		camera.followPlayer = function(){
			if (this.cameraSlow > 0){
				if (this.xlocked == false)
					this._x += (this.follow._x - this._x)/this.cameraSlow;
				if (this.ylocked == false)
					this._y += (this.follow._y - this._y)/this.cameraSlow;
			}else{
				this.toX = 0; this.toY = 0;
				if (this.follow._x < this._x - this._width / 2)this.toX = -1;
				if (this.follow._x > this._x + this._width / 2)this.toX = 1;
				if (this.follow._y < this._y - this._height / 2)this.toY = -1;
				if (this.follow._y > this._y + this._height / 2)this.toY = 1;
				this._x += this.toX * this._width;
				this._y += this.toY * this._height;
			}
		}
		utils.trace('Created camera :: ' + camera, utils.t_create);
		return camera;
	}
	
	static function makeLevelExit(door:MovieClip, xOffset, yOffset):MovieClip{
		if (xOffset == undefined) xOffset = 0;
		if (yOffset == undefined) yOffset = 0;
		var trigger:MovieClip = spawning.spawnGround('trigger');
		trigger._x = door._x + xOffset;
		trigger._y = door._y + yOffset;
		//trigger._visible = false;
		trigger.slotsForExecute.push(function(who:MovieClip){
			if (animating.each(who, 1 / 15) > 0)
				for (var i = 0; i < spawning.units.length; ++i)
					if (spawning.units[i].isControllable && who.hitTest(spawning.units[i]._x, spawning.units[i]._y, true)){
						// finish levels
						completeLevel(_root._currentframe);
					}
		});
		return door;
	}
	static function GUIplace(who, numX, numY){
		who._y = 400 - (numY + 1) * 14;
		who._x = 20 + numX * 14;
	}
	
	static var GUIlever:Boolean = false;
	static var GUIactions:Array = new Array();
	static var GUIkeys:Array = new Array();
	static var btnCount:Number = 0;
	static var guiCount:Number = 0;
	static function spawnKey(X,Y, KEY){
		var newButton:MovieClip = _root.layer_GUI.attachMovie('GUI_button', 'bttn'+(++btnCount), _root.layer_GUI.getNextHighestDepth());
		newButton.numX = X;
		newButton.numY = Y;
		newButton.keyP = heroAbilities.anyKey[KEY];
		GUIplace(newButton, newButton.numX, newButton.numY);
		newButton.gotoAndStop(newButton.keyP+"_");
		newButton.onEnterFrame = function(){
			//GUIplace(this, this.numX, this.numY);
			this.gotoAndStop(this.keyP+"_"+((Key.isDown(this.keyP))?"pressed" : ""));
		}
	}
	static var prevItem:MovieClip = null;
	static function makeGUI(){
		if (_root.layer_GUI == undefined)
			{spawning.createLayer("layer_GUI");}
		var thinker:MovieClip = _root.layer_GUI.attachMovie('GUI_thinker', 'thinker', _root.layer_GUI.getNextHighestDepth());
		prevItem = null;
		thinker.onEnterFrame = function (){
			if (heroAbilities.anyKeyPressed() == true)
				this.updateNeed = true;
			if (levels.hero.wantFirstItem != prevItem){
				prevItem = levels.hero.wantFirstItem;
				checkGUI();
			}
			if (this.updateNeed && animating.each(this, 1/60)){
				this.updateNeed = false;	
				checkGUI();	
			}
		}
		for (var i = 0; i < 8; i++){
			var newLine:MovieClip = _root.layer_GUI.attachMovie('GUI_line', 'gui'+i, _root.layer_GUI.getNextHighestDepth());
			newLine.numX = 1;
			newLine.numY = i;
			newLine.needUpdate = false;
			newLine.onEnterFrame = function(){
				if (!this.needUpdate)
					return;
				this.needUpdate = false;
				if (GUIactions.length > this.numY){
					this.descr.text = GUIactions[this.numY];
					this.numX = GUIkeys[this.numY].length - 1;
				}
				else
					this.descr.text = '	';
				GUIplace(this, this.numX, this.numY);
			}
		}
	}
	static function clearButtons(){
		for (var i = 0; i < btnCount + 1; ++i)
			_root.layer_GUI['bttn'+i].removeMovieClip();
	}
	static function updateGUI(){
		clearButtons();
		for (var i = 0; i < 8; i++){
			_root.layer_GUI['gui'+i].needUpdate = true;
			if (i < GUIkeys.length)
				for (var j = 0; j < GUIkeys[i].length; j++)
					spawnKey(j,i, GUIkeys[i][j]);
		}
		utils.trace('GUI updated;');
	}
	static var hero:MovieClip = null;
	static function A0(X):Array{
		var Arr:Array = new Array();
		Arr.push(X);
		return Arr;
	}
	static function checkGUI(){
		GUIactions = new Array();
		GUIkeys = new Array();
		if (hero.anyKeyPressTo != undefined && hero.anyKeyPressTo != null){
			if (hero.anyKeyPressTo.isLever)
				GUIactions.push('use a lever');
			else
			if (hero.anyKeyPressTo.canTalk)
				GUIactions.push('talk to ' + hero.anyKeyPressTo._name);
			else
				GUIactions.push('interract');
			GUIkeys.push(new Array(0,1,2,3));
			// . . . update 
			updateGUI();
			return;
		}
		if (prevItem == null){
				// . . . book
				if (hero.bookUse != undefined && hero.rightItem == null){
					if (hero.model.righthand._currentframe == 2
						|| hero.model.righthand._currentframe == 3){
							GUIactions.push('hide spellbook');
							GUIactions.push('HOLD : cast');
							GUIkeys.push(A0(3), A0(3));
						}else{
							GUIactions.push('take spellbook');
							GUIkeys.push(A0(3));
						}
				}
				// . . . water
				if (hero.bottleUse != undefined && hero.leftItem == null){
					GUIkeys.push(A0(0), A0(0));
					if (hero.model.lefthand._currentframe == 2
						|| hero.model.lefthand._currentframe == 3){
							GUIactions.push('hide bottle');
						} else {
							GUIactions.push('take bottle');
						}
					GUIactions.push('HOLD : spill water');
				}
				// . . . shield
				if (hero.shieldUse != undefined && hero.leftItem == null){
					GUIkeys.push(A0(2), A0(2));
					if (hero.model.lefthand._currentframe == 4
						|| hero.model.lefthand._currentframe == 5){
							GUIactions.push('hide shield');
						} else {
							GUIactions.push('take shield');
						}
					GUIactions.push('HOLD : block');
				}
				// . . . sword
				if (hero.swordUse != undefined && hero.rightItem == null){
					if (hero.model.righthand._currentframe == 2
						|| hero.model.righthand._currentframe == 3){
							GUIactions.push('hide sword');
							GUIactions.push('HOLD : attack');
							GUIkeys.push(A0(1), A0(1));
						}else{
							GUIactions.push('take sword');
							GUIkeys.push(A0(1));
						}
				}
		}
		// . . . ITEMS
		if (hero.leftItem != null){
			GUIactions.push('drop ' + hero.leftItem.itemName);
			GUIkeys.push(new Array(0,2));
		}
		if (hero.rightItem != null){
			GUIactions.push('drop ' + hero.rightItem.itemName);
			GUIkeys.push(new Array(1,3));
		}
		// .. combo
		if (prevItem != null){
			// show prev Items
			pushOrAdd('take ' + prevItem.itemName + ' in left hand', new Array(0,2));
			pushOrAdd('take ' + prevItem.itemName + ' in right hand',new Array(1,3));
		}
		// . . . update 
		updateGUI();
	}
	static function pushOrAdd(S:String, Keys:Array){
		var isAdd:Number = -1;
		if (Keys.length == 2 )
			for (var i = 0; i < GUIkeys.length; ++i)
				if (GUIkeys[i].length == 2
					&& Keys[0] == GUIkeys[i][0] && Keys[1] == GUIkeys[i][1])
					{ isAdd = i; break;}
		if (isAdd < 0){
			GUIactions.push(S);
			GUIkeys.push(Keys);
			return;
		}	
		GUIactions[isAdd] += " & " + S;	
	}
	
	static function keyPressedLong(X):Boolean{
		return (X == 1 || (X >= 30 && X % 15 == 0) || (X > 75 && X % 3 == 0))
	}
	static function makeColorSelector (){
		if (_root.layer_GUI == undefined)
			spawning.createLayer('layer_GUI');
		var counterNames:String = "RGB";
		for (var i = 0; i < 3; ++i){
			var newLine:MovieClip = _root.layer_GUI.attachMovie('GUI_counter', 'cntr'+(i), _root.layer_GUI.getNextHighestDepth());
			newLine._x = 100;
			newLine._x = 100;
			newLine._y = 210 + 30 * i;
			newLine.gotoAndStop(1 + 1*(i==0));
			newLine.description = counterNames.charAt(i);
			newLine.min_value = 0; newLine.max_value = 255; newLine.current_value = utils.hero_armor_color[i];
			newLine.i = i;
			newLine.onValueChanged = function(who, val:Number){ utils.hero_armor_color[who.i] = val; _root.hero.reColor();}
		}
		var thinker:MovieClip = _root.layer_GUI.attachMovie('GUI_thinker', 'thinker', _root.layer_GUI.getNextHighestDepth());
		thinker.watchKeys = new Array(37,38,39,40,16);
		thinker.pressKeys = new Array(0,0,0,0,0,0);
		thinker.selectedLine = 0;
		thinker.done = false;
		thinker.toggleHeroLock = false;
		_root.hero.locked = true;
		thinker.onEnterFrame = function (){
			if (!this.done){
				this.done = true;
				for (var i = 0; i < 3; ++i)
					_root.layer_GUI["cntr"+i].updateInfo();
			}
			for (var i = 0; i < this.watchKeys.length; ++i)
				if (Key.isDown(this.watchKeys[i]))
					this.pressKeys[i]++;
				else
					this.pressKeys[i] = 0;
			if (keyPressedLong(this.pressKeys[4])){
				this.toggleHeroLock = !this.toggleHeroLock;
				_root.hero.locked = !this.toggleHeroLock;
				_root.hero.model.gotoAndStop(1);
				_root.hero.reColor();
				_root.hero.sp_x = _root.hero.sp_y = 0;
				sounds.playSound(sounds.voiceName('GUI/move', 3));
				if (this.toggleHeroLock == true)
					_root.layer_GUI["cntr"+this.selectedLine].onUnSelect();
				else
					_root.layer_GUI["cntr"+this.selectedLine].onSelect();
			}
			if (this.toggleHeroLock == true)
				return;
			if (keyPressedLong(this.pressKeys[3])){
				sounds.playSound(sounds.voiceName('GUI/move', 2));
				_root.layer_GUI["cntr"+this.selectedLine].onUnSelect();
				this.selectedLine = (this.selectedLine + 1)%3;
				_root.layer_GUI["cntr"+this.selectedLine].onSelect();
			}
			if (keyPressedLong(this.pressKeys[1])){
				sounds.playSound(sounds.voiceName('GUI/move', 2));
				_root.layer_GUI["cntr"+this.selectedLine].onUnSelect();
				this.selectedLine = (this.selectedLine == 0)? 2 : (this.selectedLine-1);
				_root.layer_GUI["cntr"+this.selectedLine].onSelect();
			}
			if (keyPressedLong(this.pressKeys[0])){
				sounds.playSound(sounds.voiceName('GUI/move', 1));
				_root.layer_GUI["cntr"+this.selectedLine].minusValue(Math.round(this.pressKeys[0] / 60 + .6));
			}
			if (keyPressedLong(this.pressKeys[2])){
				sounds.playSound(sounds.voiceName('GUI/move', 1));
				_root.layer_GUI["cntr"+this.selectedLine].plusValue(Math.round(this.pressKeys[2] / 60 + .6));
			}
			
		}
	}
}