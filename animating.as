class animating{
	static var worldTimeSpeed:Number = 1;
	static var worldYKoeff:Number = .5;
	static function animate (who, stat, speed){
	trace (who + '/' + stat + '/' + speed);
		who.stop();
		if (!(who.isAnimating == true)){
			who.isAnimating = true; who.animatingTimer = 0;
			who.stat = 'none';
			return;
		}
		// switching a state
		if (stat != who.stat){
			who.gotoAndStop(stat);
			who.stat = stat;
		}
		// adding a frames
		who.animatingTimer += worldTimeSpeed * speed;
			
		while (who.animatingTimer >= 1){
			who.nextFrame();
			who.animatingTimer --;
		}
		return;
	}
}