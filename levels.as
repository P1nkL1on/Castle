class levels{
	static var testLevels:Array = new Array(2,3);
	
	static function selectNextLevel():Number{
		return 2;
	}
	static function completeLevel(number:Number){
		trace('Level :: ' + number + " :: COMPLETED!");
	}
	
	static function makeLevelExit(door:MovieClip, xOffset, yOffset):MovieClip{
		if (xOffset == undefined) xOffset = 0;
		if (yOffset == undefined) yOffset = 0;
		var trigger:MovieClip = spawning.spawnGround('trigger');
		trigger._x = door._x + xOffset;
		trigger._y = door._y + yOffset;
		trigger.slotsForExecute.push(function(who:MovieClip){
			if (animating.each(who, 1 / 15) > 0)
				for (var i = 0; i < spawning.units.length; ++i)
					if (spawning.units[i].isControllable && who.hitTest(spawning.units[i]._x, spawning.units[i]._y, true)){
						// finish levels
						completeLevel(_root._currentframe);
						_root.gotoAndStop(1);
					}
		});
		return door;
	}
	static function GUIplace(who, numX, numY){
		who._y = 400 - (numY + 1) * 14;
		who._x = 20 + numX * 14;
	}
	static function makeGUI(){
		if (_root.layer_GUI == undefined)
			{spawning.createLayer("layer_GUI");}	
		for (var i = 0; i < 8; i++){
			var newButton:MovieClip = _root.layer_GUI.attachMovie('GUI_button', 'bttn'+i, _root.layer_GUI.getNextHighestDepth());
			var newLine:MovieClip = _root.layer_GUI.attachMovie('GUI_line', 'gui'+i, _root.layer_GUI.getNextHighestDepth());
			newButton.numX = 0;
			newButton.numY = i;
			newButton.number = i;
			
			newLine.numX = 1;
			newLine.numY = i;
			newButton.onEnterFrame = function(){
				GUIplace(this, this.numX, this.numY);
				
				if (this.number == 0)
					return;
			}
			newLine.onEnterFrame = function(){
				GUIplace(this, this.numX, this.numY);
			}
		}
	}
}