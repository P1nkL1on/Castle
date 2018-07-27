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
		model.lastFrame = -1;
		model.wantTalk = false;
		model.animatingSpeed = 20;
		
		
		// . . . functions
		model.shadow.onTalkFinish; // who only
		model.shadow.onStringStart;	// (who, int i)
		
		
		// . . . CONTORLS
		model.shadow.canBeActivatedBy = new Array();
		for (var i = 0; i < spawning.units.length; ++i)
			if (spawning.units[i].isControllable){
				model.shadow.canBeActivatedBy.push(spawning.units[i]);
				spawning.units[i].anyKeyPressTo = null;
			}
		model.shadow.canTalk = true;
		model.shadow.slotsForExecute.push(function(who:MovieClip){
			if (who.model.isTalking == false){
				for (var i = 0; i < who.canBeActivatedBy.length; ++i){
					who.h = who.canBeActivatedBy[i];
					if (who.hitTest(who.h)/*  && who.h.locked == false */){
						if (who.h.anyKeyPressTo == null){
							who.h.anyKeyPressTo = who;
							levels.checkGUI();
						}
						if (heroAbilities.anyKeyPressed() == true){
							who.model.wantTalk = true;
							who.talkingTo = who.h;
						}
					}else{
						if (who.h.anyKeyPressTo == who){
							who.h.anyKeyPressTo = null;
							levels.checkGUI();
						}
					}
				}
			}else{
				if ((who.model.currentTalk+'').indexOf('_out') >= 0)
					return;
				if (who.model.saidOut != true && (
					Math.abs(who.talkingTo._x - who._x) > 100
					|| Math.abs(who.talkingTo._y - who._y) > 50)){
					trace('Stop talking');
					who.model.lastSound.stop();
					who.model.saidOut = true;
					who.model.swapCD = -30;
					who.model.lastSubtitle = "";
					who.model.subtitleCurrentLetter = -1;
				}
			}
		});
		// . . . ACTION
		model.shadow.slotsForExecute.push(function(who:MovieClip){ 
			// . . .
			if (who.model.isTalking == false && who.model.wantTalk == true) {
				who.model.isTalking = true;
				who.model.wantTalk = false;
 				trace('Starts talking :: ' + who.model);
				who.model.swapCD = -1;
				who.model.lastFrameBeforeTalking = who.model._currentframe;
			}
			// . . . FUNUSH
			if (who.model.isTalking == true){
				if (who.model.swapCD != -1)
					who.model.swapCD ++;
				if (who.model.swapCD == -1 && (who.model.talkingFrames.length - 1 <= who.model.currentTalk
					|| (who.model.saidOut == true && who.model.finishAfterOut == true))){
					trace('Talking stop :: ' + who.model.lastFrameBeforeTalking);
					who.model.isTalking = false;
					who.model.currentTalk = -1;
					who.model.lastSound = null;
					who.model.lastSubtitle = "";
					who.model.subtitleCurrentLetter = -1;
					who.model.gotoAndStop(who.model.lastFrameBeforeTalking);
					who.talkingTo = null;
					who.model.finishAfterOut = false;
					who.model.saidOut = false;
					who.onTalkFinish(who);
					return;
				}	
					
				if (who.model.swapCD == -1 
					&& who.model.talkingFrames.length - 1> who.model.currentTalk ){
					who.model.swapCD = 0;
					if (who.model.saidOut != true){
						who.model.currentTalk ++;
						who.model.gotoAndStop(who.model.talkingFrames[who.model.currentTalk]);
						who.model.lastSound = 
							sounds.playSound(sounds.voiceName(who.model.voicePath, who.model.currentTalk + 1));
						who.onStringStart(who, who.model.currentTalk + 1);
					}else{
						who.model.gotoAndStop('out');
						who.model.lastSound = 
							sounds.playSound(sounds.voiceName(who.model.voicePath, '_out'));
						who.model.finishAfterOut == true;
						who.model.currentTalk = 100;
					}
					who.model.lastFrame = who.model._currentframe;
					who.model.subtitleCurrentLetter = -1;
					who.model.subtitleNeedLetter = 0;
					who.model.lastSubtitle = who.model.descr.text; who.model.descr.text = "";
					trace("Talking :: " +who.model.currentTalk);
				}
				
				if (who.model.swapCD >= 0){
					who.model.subtitleNeedLetter = (who.model.lastSound.position / who.model.lastSound.duration);
					if (who.model.subtitleNeedLetter >= .999 && who.model.swapCD > 30){
						who.model.lastSound.position = 0;
						who.model.swapCD = -30;
					}
					who.model.subtitleNeedLetter *= who.model.lastSubtitle.length;
					if (who.model.swapCD % who.model.animatingSpeed == 0)
						who.model.talkFast = false;
					if (who.model.subtitleCurrentLetter < who.model.subtitleNeedLetter || who.model.lastSubtitle.charAt(who.model.subtitleCurrentLetter) != ' '){
						who.model.descr.text += who.model.lastSubtitle.charAt(++who.model.subtitleCurrentLetter);
						if (who.model.lastSound.position < who.model.lastSound.duration)
							who.model.talkFast = true;
					}
					who.model.gotoAndStop(who.model.lastFrame + 1 * who.model.talkFast);
					
				}
			}
		});
	}
}