class fontengine{

	static var letter_wid = 4;
	static var letter_hei = 6;
	static var letter_x_offset = 0.2;
	static var letter_y_offset = 1;
	
	
	static var default_separators = " \n";
	
	static function printIn( what, where, style, xOffset, yOffset, maxX, isDescr, r, g, b):MovieClip{
	//trace(what+'/'+where+'/'+style)
		var isArray = (typeof(what) +'')== 'object'
		// if it is an array, then it should be any params like descriptions!
	
		if (style == undefined) style = 'test';
		if (xOffset == undefined) xOffset = 0;
		if (yOffset == undefined) yOffset = 0;
		if (maxX == undefined) maxX = -1;
		if (what == undefined){ trace('No string to write!!'); }
		if (where == undefined) where = _root;
		if (isDescr == undefined) isDescr = false;
		if (r == undefined) r = 0; if (g == undefined) g = 0; if (b == undefined) b = 0;
		
		//yOffset += letter_hei;
		
		var charNumber = 0; 
		var curX = 0;
		var curY = 0;
	
		if (where.textHandlerCount == undefined) 
			where.textHandlerCount = 0;
		where.lastWord = "";
		
		var th = where.attachMovie('letter_handler', 'text_handler_' + where.textHandlerCount, where.getNextHighestDepth());
		th.wordCount = 0;
		
		if (isDescr){
			maxX = 100;
			th.attachMovie('description_handler', 'bub', th.getNextHighestDepth());
			curX += 5; curY += 5;
		}
		
		var params;
		if (isArray){
			params = what;
			what = what[0];
		}
		
		var nowInWhat:Number = 0;
		var descrptionUsed = 0;
		while(nowInWhat < what.length){
			var newWord:String = "";
			var descriptionAble = 0;
			var oneWord = false;
			do{
				if (what.charAt(nowInWhat) == '@'){
					oneWord = !oneWord; 				// except @ 
					if (!descriptionAble) descriptionAble = ++descrptionUsed;
				}
				else
					newWord += what.charAt(nowInWhat); // add to word, or
				nowInWhat++;
			}while(default_separators.indexOf(what.charAt(nowInWhat)) < 0 || oneWord);
			
			var wd = th.attachMovie('word_handler', 'wrd'+(++th.wordCount), th.getNextHighestDepth());
			var wCurX = 0;
			for (var i = 1 - 1 * (th.wordCount == 1); i < newWord.length; ++i){
				var letter = wd.attachMovie('letter_' + style, 'l'+i, wd.getNextHighestDepth());
				var fr = newWord.charCodeAt(i); if (fr > 900) fr -= 900;
				letter.gotoAndStop(fr);
				letter._x = wCurX + letter_wid/2; 
				wCurX += letter_x_offset + ((letter._width > .2)? letter._width : letter_wid);
				letter._y = 4;
			}
			wd.b._width = wCurX;
			var addWid = wd._width;
			if (curX + addWid >= maxX){
				curX = 0; curY += letter_hei;
			}
			wd._x = curX;
			wd._y = curY;
			curX += addWid + letter_wid;
			spawning.colorSomething(wd, r, g, b);
			// if (isArray && descriptionAble > 0){
				////printIn(params[descriptionAble], where, style, curX, curY, 100);
				// wd.mouseOver = false;
				// wd.timer = 0;
				// wd.textStyle = style;
				// wd.descr = params[descriptionAble];
				// wd.printed = null;
				// wd.onMouseMove = function (){
					// this.mouseOver = (this.b.hitTest(_root._xmouse, _root._ymouse));
				// }
				// wd.onEnterFrame = function (){
					// if (!this.mouseOver) { this.timer = 0; if (this.printed != null){ this.printed.removeMovieClip(); this.printed = null; } return; }
					// this.timer ++;
					// if (this.timer != 41) return;
					// this.printed = printIn(this.descr, _root, this.textStyle, _root._xmouse, _root._ymouse, 100, true);
				// }
				// spawning.colorSomething(wd, 40, 100, 10);
			// }
		}
		where.textHandlerCount++;
		th._xscale = th._yscale = 100;
		if (th.bub != undefined){
			th.bub.d._y = curY + 10.7;
			th.bub.b._height = Math.max(0, curY - 9.9);
		}
		th.cacheAsBitmap = true;
		th._x = xOffset; th._y = yOffset - th._height;
		return th;
	}

	static function test(){
		printIn('Сделай что нибудь нормально!', undefined, undefined, 50, 50, 200, true, 255,255,255);
	}
}