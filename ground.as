class ground{
	static function makeGround (who:MovieClip, typ:String):MovieClip{
		who.groundType = typ;
		who.groundSoundVariant = 1;
		for (var i = 0; i < sounds.footStepsTypes.length; i++)
			if (sounds.footStepsTypes[i] == typ)
			{ who.groundSoundVariant = sounds.footStepsCount[i]; return;}
		trace("Type pf ground '" + typ + "' is strange; No matchs with existed: " + sounds.footStepsTypes);
	}
	static function makeReflection (shad:MovieClip, mask:MovieClip):MovieClip{
		trace('called');
		trace(shad +'/' + shad.model + '/' + mask);
		var newReflection:MovieClip = shad.model.duplicateMovieClip(shad.model._name + '_reflection', shad.model.getDepth() - 1);
		newReflection._yscale *= -1;
		newReflection._alpha = 30;
		newReflection.shad = shad;
		newReflection.setMask(mask);
		newReflection.onEnterFrame = function (){
			this._x = this.shad._x;
			this._y = this.shad._y;
			this.gotoAndStop(this.shad.model._currentframe);
			this._xscale = this.shad.model._xscale;
			if (this.shad.isControllable){
				this.lefthand.gotoAndStop(this.shad.model.lefthand._currentframe);
				this.righthand.gotoAndStop(this.shad.model.righthand._currentframe);
			}
		}
		return newReflection;
	}
}