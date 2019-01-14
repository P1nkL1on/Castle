class fps
{
	static var fpsStandart:Number = 60;
	static var lasttime:Number = 0;
	static function coutnFps(textBox, textBoxAverage):Number{
		var time:Date = new Date;
		var time_since = ((time.getMilliseconds()-lasttime)>=0)?(time.getMilliseconds()-lasttime):(1000+(time.getMilliseconds()-lasttime));
		var frames_now:Number = 1000 / time_since;
		lasttime = time.getMilliseconds();
		textBox.text = fpsWorst;//Math.round(frames_now) +' / ' + fpsStandart;
		textBoxAverage.text = fpsAverage;
		calculateFpsBenchmark(frames_now, time_since);
		return frames_now;
	}
	static function spawnCounter():MovieClip{
		if (_root.layer_GUI == undefined)
			spawning.createLayer('layer_GUI');
		_root.layer_GUI.attachMovie('fpsCounter', 'fpsCounter', _root.layer_GUI.getNextHighestDepth());
		return _root.layer_GUI.fpsCounter;
	}
	
	static var fpsEach = new Array();
	static var timePassed = 0;
	static var fpsAverage = 0;
	static var fpsWorst = 0;
	static var worstFps = fpsStandart + 10;
	static function calculateFpsBenchmark (newfps, timeEscalated){
		if (newfps < worstFps) worstFps = newfps;
		fpsEach.push(newfps);
		timePassed += timeEscalated;
		if (timePassed < 1000) return;
		var fpSred = 0;
		for (var i = 0; i < fpsEach.length; ++i) fpSred += fpsEach[i];
		fpSred /= fpsEach.length;
		fpsAverage = (Math.round(fpSred * 10) / 10)
		//utils.trace("Average fps: " + fpsAverage, utils.t_benchmark);
		fpsEach = new Array();
		timePassed = 0;
		fpsWorst = (Math.round(worstFps * 10) / 10);
		worstFps = fpsStandart + 10;
	}
}