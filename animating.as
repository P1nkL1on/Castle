class animating{
	static var worldTimeSpeed:Number = 1;
	static var worldYKoeff:Number = .5;
	static function animate (who, stat, speed):Number{
		who.stop();
		if (!(who.isAnimating == true)){
			who.isAnimating = true; who.animatingTimer = 0;
			who.stat = 'none';
			return 0;
		}
		// switching a state
		if (stat != who.stat){
			who.gotoAndStop(stat);
			who.stat = stat;
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
}