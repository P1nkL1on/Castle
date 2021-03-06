﻿class animating{
	static var worldTimeSpeed:Number = 1;
	static var worldYKoeff:Number = .5;
	static function changeStat(who, stat):Number{
		if (stat != who.stat){
			who.gotoAndStop(stat);
			who.stat = stat;
			return 1;
		}
		return 0;
	}
	static var lastFrame:Number = -1;
	static function animate(who, stat, speed):Number{
		changeStat(who, stat);			
		return animateOnly(who, speed);
	}
	static function animateOnly (who, speed):Number{
		who.stop();
		if (!(who.isAnimating == true)){
			who.isAnimating = true; who.animatingTimer = 0;
			who.stat = 'none';
			return 0;
		}
		// adding a frames
		who.animatingTimer += worldTimeSpeed * speed;
			
		var times:Number = 0;
		while (who.animatingTimer >= 1){
			who.nextFrame();
			times++;
			who.animatingTimer --;
		}
		return times;
	}
	static function each (who, speed):Number{
		if (who.triggerTimer == undefined) who.triggerTimer = 1;
		who.triggerTimer += worldTimeSpeed * speed;
		var times:Number = 0;
		while (who.triggerTimer >= 1){
			times++;
			who.triggerTimer --;
		}
		return times;
	}
}