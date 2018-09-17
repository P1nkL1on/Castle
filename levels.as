class levels{
	static var testLevels:Array;
	
	static var levelIndex = 0;
	
	static function selectNextLevel():Number{
		return testLevels[levelIndex++];
	}
	static function tryAgainLevel():Number{
		return testLevels[levelIndex];
	}
	static function resetGame(){
		utils.hero_armor_color = new Array(235, 70, 70);
		utils.hero_has_items = new Array(false, false, false, false);
		testLevels = new Array(8,9,8,5,6,7);
		levelIndex = 0;
		// generate new level sequence
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
					this._y += (this.follow._y - 90 - this._y)/this.cameraSlow;
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
		trigger._visible = false;
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
				_root.whiteSpace.circle.b.spd = (!this.toggleHeroLock)? .2 : 5;
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
	static var xDef = 300-77;
	static var yDef = 320;
	static var yOffDef = 15;
	
	static function spawnDraws(){
		if (_root.layer_GUI == undefined)
			spawning.createLayer('layer_GUI');
		var drs:MovieClip = _root.layer_GUI.attachMovie('menu_draw', 'drs', _root.layer_GUI.getNextHighestDepth());
		drs.stop();
		drs.fr2 = '';
		drs._x = 122; drs._y = yDef - 122;
		drs.onEnterFrame = function(){	
			this.fr = levels.oldesetThinker.level+'_'+levels.thinker.selectedLine;
			if (this.fr != this.fr2)
				this.fr2 = this.fr;
			this.gotoAndStop(this.fr);
		}
	}
	
	static function makeMenuSelector(){
		makeMenuStrings(xDef, yDef, yOffDef, new Array('Start new game','Continue game','Settings'), new Array(
			startGame, continueGame, gotoOptions
		));
	}
	static function setLevel(lll){
		oldesetThinker.level = oldesetThinker.level.substr(0, 2 + lll * 2);
	}
	static function pushChoice(lll){
		if (!lll){
			var needLevel:Number = oldesetThinker.level.length / 2 - 2;
			setLevel(needLevel);
			return;
		}
		oldesetThinker.level += '_'+lll;
	}
	static var oldesetThinker:MovieClip = null;
	static var thinker:MovieClip;
	static function makeMenuStrings(x, y, yoffset, lineNames:Array, functions:Array, allNotOneAreFake){
		if (_root.layer_GUI == undefined)
			spawning.createLayer('layer_GUI');
		if (allNotOneAreFake == undefined)
			allNotOneAreFake = false;
			
		for (var i = 0; i < lineNames.length; ++i){
			var newLine:MovieClip = _root.layer_GUI.attachMovie('GUI_line_button', 
					'line'+x+'_'+(i), _root.layer_GUI.getNextHighestDepth());
			newLine._x = x;
			newLine._y = y + yoffset * i;
			newLine.gotoAndStop(1);
			newLine.t.text = lineNames[i];
			newLine.i = i;
			newLine.line_name = lineNames[i];
			if (allNotOneAreFake == true && i > 0)
				newLine.noShadow = true;
		}
		
		thinker = _root.layer_GUI.attachMovie('GUI_thinker', 'thinker', _root.layer_GUI.getNextHighestDepth());
		thinker.watchKeys = new Array(37,38,39,40,65,81,83,87);
		thinker.pressKeys = new Array(0,0,0,0,0,0,0,0,0);
		thinker.selectedLine = (lineNames.length == 1)? 0 : 1;
		thinker.toggleHeroLock = false;
		thinker.X = x;
		thinker.count = lineNames.length;
		thinker.funcs = functions;
		thinker.transitionTimer = 0;
		thinker.level = 'FR';
		thinker.levelNow = 'FR';
		
		if (oldesetThinker == null)
			oldesetThinker = thinker;
		
		_root.layer_GUI['line'+thinker.X+'_'+thinker.selectedLine].gotoAndStop(2);
		_root.layer_GUI['line'+thinker.X+'_'+thinker.selectedLine].t.text = lineNames[thinker.selectedLine];
		
		thinker.onEnterFrame = function (){
			if (this.transitionTimer > 0){
				this.transitionTimer ++;
				//this.sButton = _root.layer_GUI['line'+x+'_'+i];
				
				// case of non new menu option
				if (_root.layer_GUI['line'+x+'_'+this.selectedLine].noShadow == true){
					if (this.transitionTimer == 5){
						this.funcs[this.selectedLine](this.selectedLine - 1);
						this.transitionTimer = 0;
					}
					return;
				}
				
				if (this.transitionTimer <= 20)
					for (var i = 0; i < this.count; ++i)
						_root.layer_GUI['line'+x+'_'+i].d._alpha += 4.95;
				
				if (this.transitionTimer == 21){
					for (var i = 0; i < this.count; ++i)
						_root.layer_GUI['line'+x+'_'+i].removeMovieClip();
					this.funcs[this.selectedLine](this.selectedLine - 1);
					pushChoice(this.selectedLine);
				}
				return;
			}
			for (var i = 0; i < this.watchKeys.length; ++i)
				if (Key.isDown(this.watchKeys[i]))
					this.pressKeys[i]++;
				else
					this.pressKeys[i] = 0;
					
			if (this.toggleHeroLock == true)
				return;
			if (keyPressedLong(this.pressKeys[3])){
				sounds.playSound(sounds.voiceName('GUI/move', 1));
				_root.layer_GUI['line'+x+'_'+this.selectedLine].onUnSelect();
				this.selectedLine = (this.selectedLine + 1)%this.count;
				_root.layer_GUI['line'+x+'_'+this.selectedLine].onSelect();
			}
			if (keyPressedLong(this.pressKeys[1])){
				sounds.playSound(sounds.voiceName('GUI/move', 1));
				_root.layer_GUI['line'+x+'_'+this.selectedLine].onUnSelect();
				this.selectedLine = (this.selectedLine == 0)? (this.count - 1) : (this.selectedLine-1);
				_root.layer_GUI['line'+x+'_'+this.selectedLine].onSelect();
			}
			for (var pi = 0; pi < 4; pi++)
				if (keyPressedLong(this.pressKeys[4 + pi])){
					sounds.playSound(sounds.voiceName('GUI/move', 3));
					this.transitionTimer++;
				}
		}
	}
	
	static function startGame(){
		saving.saveGame(true);
		_root.gotoAndStop('custom_charater');
	}
	static function continueGame(){
		spawning.clearLayers();
		saving.saveGame();
		_root.gotoAndStop('level_selection');
	}
	static function gotoOptions(){
		makeMenuStrings(xDef, yDef, yOffDef, new Array('..','Game options','Graphic options', 'Sound options'), new Array(
				makeMenuSelector, gotoGameOptions, gotoGraphicOptions, gotoSoundOptions));
	}
			static function gotoGameOptions(){
				makeMenuStrings(xDef, yDef, yOffDef, new Array('..','Difficulty','Timer', 'Story settings'), new Array(
						gotoOptions, gotoDifficultyOptions, gotoTimerOptions, gotoStoryOptions));	
			}
					static function gotoDifficultyOptions(){
						makeMenuStrings(xDef, yDef, yOffDef, new Array('..','Waffle','Novice', 'Experienced', 'Master'), new Array(
								gotoGameOptions, doNothing, doNothing, doNothing, doNothing), true);
					}
					static function gotoTimerOptions(){
						makeMenuStrings(xDef, yDef, yOffDef, new Array('Leave with no changes','No timer','120 minutes', '60 minutes', '30 minutes'), new Array(
								gotoGameOptions, setTimerMax, setTimerMax, setTimerMax, setTimerMax), true);
					}
					static function gotoStoryOptions(){
						makeMenuStrings(xDef, yDef, yOffDef, new Array('Leave with no changes','Saving princess', 'Saving prince'), new Array(
								gotoGameOptions, setPrincessGender, setPrincessGender), true);
					}
					
			static function gotoGraphicOptions(){
				makeMenuStrings(xDef, yDef, yOffDef, new Array('..','High quality','Medium quality', 'Low quality'), new Array(
						gotoOptions, setQualityFunction, setQualityFunction, setQualityFunction), true);	
			}
			
			static function gotoSoundOptions(){
				makeMenuStrings(xDef, yDef, yOffDef, new Array('..'), new Array(
						gotoOptions));	
			}
	
	static function setPrincessGender(gend){ 
		if (gend == 0)utils.game_save_princess = true; 
		if (gend == 1)utils.game_save_princess = false; 
	}
	static function setQualityFunction (qual){ 
		if (qual == 0) _quality = 'high'; 
		if (qual == 1) _quality = 'medium'; 
		if (qual == 2) _quality = 'low';
		utils.graphics_quality = _quality+"";
	}
	static function setTimerMax(tim){ 
		if (tim == 0)utils.game_timer_max = utils.game_timer_lasts = -1; 
		if (tim == 1)utils.game_timer_max = utils.game_timer_lasts = 60*(120); 
		if (tim == 2)utils.game_timer_max = utils.game_timer_lasts = 60*(60); 
		if (tim == 3)utils.game_timer_max = utils.game_timer_lasts = 60*(30); 
	}
	static function setDifficulty(dif){
		utils.game_difficulty = dif;
	}
	
	static function gotoCredits(){
	
	}
	static function doNothing(){
	
	}
}