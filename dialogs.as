class dialogs{
	static function makeModelTalking(model:MovieClip, frames:Array, voicePath:String){
		trace("Made a teller :: "+model);
		model.talkingFrames = frames;
		model.voicePath = voicePath;
		model.currentTalk = -1;
		model.isTalking = false;
		model.swapCD = 0;
		model.lastSound;
		model.lastSubtitle = "";
		model.subtitleCurrentLetter = -1;
		model.lastFrameBeforeTalking = -1;
		model.shadow.slotsForExecute.push(function(who:MovieClip){ 
			// . . .
			if (who.model.isTalking == false && Key.isDown(1)) {
				who.model.isTalking = true;
				trace('Starts talking :: ' + who.model);
				who.model.swapCD = -1;
				who.model.lastFrameBeforeTalking = who.model._currentframe;
			}
			if (who.model.isTalking == true){
				if (who.model.swapCD < -1)
					who.model.swapCD ++;
				if (who.model.swapCD == -1 && who.model.talkingFrames.length - 1 <= who.model.currentTalk){
					trace('Talking stop :: ' + who.model.lastFrameBeforeTalking);
					who.model.isTalking = false;
					who.model.currentTalk = -1;
					who.model.lastSound = null;
					who.model.lastSubtitle = "";
					who.model.subtitleCurrentLetter = -1;
					who.model.gotoAndStop(who.model.lastFrameBeforeTalking);
					return;
				}	
					
				if (who.model.swapCD == -1 && who.model.talkingFrames.length - 1> who.model.currentTalk){
					who.model.swapCD = 0;
					who.model.currentTalk ++;
					who.model.subtitleCurrentLetter = -1;
					who.model.subtitleNeedLetter = 0;
					who.model.lastSound = sounds.playSound(sounds.voiceName(who.model.voicePath, who.model.currentTalk + 1));
					who.model.gotoAndStop(who.model.talkingFrames[who.model.currentTalk]);
					who.model.lastSubtitle = who.model.descr.text; who.model.descr.text = "";
					trace("Talking :: " +who.model.currentTalk);
				}
				
				if (who.model.swapCD >= 0){
					who.model.swapCD += animating.worldTimeSpeed;
					who.model.subtitleNeedLetter = (who.model.lastSound.position / who.model.lastSound.duration);
					if (who.model.subtitleNeedLetter >= .999 && who.model.swapCD > 30){
						who.model.lastSound.position = 0;
						who.model.swapCD = -30;
					}
					who.model.subtitleNeedLetter *= who.model.lastSubtitle.length;
					if (who.model.subtitleCurrentLetter < who.model.subtitleNeedLetter || who.model.lastSubtitle.charAt(who.model.subtitleCurrentLetter) != ' ')
						who.model.descr.text += who.model.lastSubtitle.charAt(++who.model.subtitleCurrentLetter);
					
				}
			}
		});
	}
}