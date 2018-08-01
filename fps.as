class fps
{
	static var fpsStandart:Number = 60;
	static var lasttime:Number = 0;
	static function coutnFps(textBox):Number{
		var time:Date = new Date;
		var frames_now:Number = 1000 / (((time.getMilliseconds()-lasttime)>=0)?(time.getMilliseconds()-lasttime):(1000+(time.getMilliseconds()-lasttime)));
		lasttime = time.getMilliseconds();
		textBox.text = Math.round(frames_now) +' / ' + fpsStandart;
		return frames_now;
	}
	static function spawnCounter():MovieClip{
		if (_root.layer_GUI == undefined)
			spawning.createLayer('layer_GUI');
		_root.layer_GUI.attachMovie('fpsCounter', 'fpsCounter', _root.layer_GUI.getNextHighestDepth());
		return _root.layer_GUI.fpsCounter;
	}
}