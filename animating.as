class animating{
	static var worldTimeSpeed:Number = 1;
	static var worldYKoeff:Number = .5;
	static function animate (who, stat, speed){
		who.stop();
		if (!(who.isAnimating == true)){
			who.isAnimating = true; who.animatingTimer = 0;
			who.stat = stat;
			return;
		}
		// switching a state
		if (stat != who.stat)
			who.gotoAndStop(stat);
		// adding a frames
		who.animatingTimer += worldTimeSpeed * speed;
		while (who.animationTimer >= 1){
			who.nextFrame();
			--who.animationTimer;
		}
		return;
	}
}