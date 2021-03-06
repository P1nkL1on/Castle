﻿class dialogs{
	static function makeModelTalking(model:MovieClip, frames:Array, voicePath:String){
		utils.trace("Made a teller :: "+model, utils.t_dialoginfo);
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
					utils.trace('Stop talking', utils.t_dialoginfo);
					who.model.lastSound.stop();
					who.model.saidOut = true;
					who.model.swapCD = -30;
					who.model.lastSubtitle = "";
					who.model.subtitleCurrentLetter = -1;
				}
			}
		});
		// . . . ACTION
		model.lastTextBoxes = new Array();
		model.shadow.slotsForExecute.push(function(who:MovieClip){ 
			// . . .
			if (who.model.isTalking == false && who.model.wantTalk == true) {
				who.model.isTalking = true;
				who.model.wantTalk = false;
 				utils.trace('Starts talking :: ' + who.model, utils.t_dialoginfo);
				who.model.swapCD = -1;
				who.model.lastFrameBeforeTalking = who.model._currentframe;
			}
			// . . . FUNUSH
			if (who.model.isTalking == true){
				if (who.model.swapCD != -1)
					who.model.swapCD ++;
				if (who.model.swapCD == -1 && (who.model.talkingFrames.length - 1 <= who.model.currentTalk
					|| (who.model.saidOut == true && who.model.finishAfterOut == true))){
					utils.trace('Talking stop :: ' + who.model.lastFrameBeforeTalking, utils.t_dialoginfo);
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
					who.model.lastTextBoxes = new Array();
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
					who.model.lastTextBoxes.push(fontengine.printIn(who.model.lastSubtitle, who.model.t_align, undefined, 0, 0, 200, true, 255,255,255));
					for (var i = 0; i < who.model.lastTextBoxes.length - 1; ++i)who.model.lastTextBoxes[i]._y -= who.model.lastTextBoxes[who.model.lastTextBoxes.length - 1]._height;
					utils.trace("Talking :: " +who.model.currentTalk, utils.t_dialoginfo);
				}
				
				if (who.model.swapCD >= 0){
					who.model.subtitleNeedLetter = (who.model.lastSound.position / who.model.lastSound.duration);
					if (who.model.subtitleNeedLetter >= .999 && who.model.swapCD > 30){
						who.model.lastSound.position = 0;
						who.model.swapCD = -30;
					}
					who.model.subtitleNeedLetter *= who.model.lastSubtitle.length;
					if (who.model.swapCD % who.model.animatingSpeed == 0)
						who.model.talkFast = !who.model.talkFast;
						
					++who.model.subtitleCurrentLetter
					who.model.gotoAndStop(who.model.lastFrame + 1 * who.model.talkFast);
				}
			}
		});
	}
}