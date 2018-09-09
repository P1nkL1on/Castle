class enemies_dark{
	static function makeShadowCorridorUnit (who:MovieClip, side:Number){
		who._xscale *= side;
		
		who.idleVariant = 'idle' + (1+random(2));
		who.animSpd = 10 - random(5);
		var scal:Number = .6+random(60) / 100.0;
		
		who._xscale *= scal; who._yscale *= scal;
		
		animating.animate(who, who.idleVariant, 1/20);
		
		who.t = _root.hero; who.xx = who._x; who.sc = side;
		who.scr = false; who.rand_spd = 5; who.x_offset = 0;
		
		who.onEnterFrame = function (){
			this.dx = this._x - this.t._x;
			this.dy = (this._y - this.t._y);
			this.dist = Math.max(0, Math.min(100, 
				100- .5 * (.5 * Math.abs(this.dx) + Math.abs(this.dy))));
			
			this._x += (this.xx + this.x_offset + 
				(100 - this.dist) * this.sc - this._x) / this.rand_spd;
			
			if (this.dist > 7){
				animating.animate(this, 'rush', 1/this.animSpd);
				this._rotation = this.dy * ( -.3)
			}
			else{
				if (this.scr){
				animating.animate(this, 'scream', 1/this.animSpd);
					return;
				}
				animating.animate(this, this.idleVariant, 1/this.animSpd);
				this._rotation /= 1.1;
				if (!this.scr && this._currentframe % 3 == 0 && random(55) == 0)
					this.scr = true;
			}
			
			if (animating.each(this, 1/(6 + .1 * Math.abs(this.dy)))){
				this.x_offset = random(24) - 13;
			}
		}
	}
	
	static function makeShadowCorridor(){
		// spawn effect boys
		for (var i = 0; i < 740; i += 30)
		for (var d = -1; d <= 1; d += 2)
		{
			var cor_unit = _root.layer_effects.attachMovie('unit_shadow_monster', 'scd_'+i+'_'+d, 
						   _root.layer_effects.getNextHighestDepth());
			cor_unit._x = 300 + 60 * d;
			cor_unit._y = -520 + i;
			makeShadowCorridorUnit(cor_unit, d);
		}
		// a mister, who checking a speed and other
		_root.layer_effects.scd_0_1._visible = false;
		_root.layer_effects.scd_0_1.background_sound = null;
		
		_root.layer_effects.scd_0_1.onEnterFrame = function (){
			if (_root.hero._y < 180 && _root.hero._y > -500){
				this.hero_spd = -(300 - _root.hero._x);
				spawning.tryMoveX(_root.hero, Math.max(-3, Math.min(3, this.hero_spd * .05)));
			}
			if (this.background_sound == null && _root.hero._y < 360){
				this.background_sound = sounds.playSound('background/shadow_corridor', 10);
				this.background_sound.setVolume(5);
			}
			if (this.background_sound != null)
				this.background_sound.setVolume(Math.min(120, 10 + 2 * Math.abs(_root.hero._x - 300)));
		}
	}
}