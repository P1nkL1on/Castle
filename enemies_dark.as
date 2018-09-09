class enemies_dark{
	static function makeShadowCorridorUnit (who:MovieClip, side:Number){
		who._xscale *= side;
		
		who.idleVariant = 'idle' + (1+random(2));
		who.animSpd = 10 - random(5);
		var scal:Number = .6+random(60) / 100.0;
		
		who._xscale *= scal; who._yscale *= scal;
		
		animating.animate(who, who.idleVariant, 1/20);
		
		who.t = _root.hero; who.xx = who._x; who.sc = side;
		who.scr = false;
		
		who.onEnterFrame = function (){
			this.dx = this._x - this.t._x;
			this.dy = (this._y - this.t._y);
			this.dist = Math.max(0, Math.min(100, 
			100- .5 * (.5 * Math.abs(this.dx) + Math.abs(this.dy))));
			
			this._x = this.xx + (100 - this.dist) * this.sc;
			
			if (this.dist > 7){
				animating.animate(this, 'rush', 1/this.animSpd);
				this._rotation = this.dy * ( -.3)
			}
			else{
				if (this.scr){
					this.gotoAndStop('scream');
					return;
				}
				animating.animate(this, this.idleVariant, 1/this.animSpd);
				this._rotation /= 1.1;
				if (!this.scr && random(5) == 0 )
					this.scr = true;
			}
		}
	}
}