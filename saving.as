class saving{
	static var savefile;
	static var saveFileName = "Castle_game_save";
	
	static function loadGame(){
		savefile = SharedObject.getLocal(saveFileName);
		if (savefile.data.saved == undefined){
			// create clear save file
			utils.trace('There was no correcr save file; Created new game save;', utils.t_saveinfo);
		}else{
			// load info
			utils.trace('Found a load file! Loading...', utils.t_saveinfo);
			utils.hero_armor_color = savefile.data.heroRGB;
			utils.trace('Loaded RGB of hero armor : ' + savefile.data.heroRGB, utils.t_saveinfo);
			utils.hero_has_items = savefile.data.artifacts;
			utils.trace('Loaded artifacts : ' + savefile.data.artifacts, utils.t_saveinfo);
		}
	}
	static function saveGame(restart){
		if (restart == true){
			savefile = SharedObject.getLocal(saveFileName);
			savefile.data.saved = undefined;
			savefile.flush(); 
			utils.trace('** Game progress reset **',utils.t_saveinfo);
			return;
		}
		utils.trace('Saving game...', utils.t_saveinfo);
		
		savefile.data.heroRGB = utils.hero_armor_color;
		savefile.data.artifacts = utils.hero_has_items;
		
		savefile.data.diff = utils.game_difficulty;
		savefile.data.timer_max = utils.game_timer_max;
		savefile.data.timer_now = utils.game_timer_lasts;
		savefile.data.saving_princess = utils.game_save_princess;
		
		savefile.data.level_sequence = levels.testLevels;
		savefile.data.levelIndex = levels.levelIndex;
		savefile.data.graphics_quality = utils.graphics_quality;
		
		savefile.data.saved = true;
		savefile.flush(); 
		utils.trace('Game saved.',utils.t_saveinfo);
		utils.trace('	Hero RGB			: ' + savefile.data.heroRGB, utils.t_saveinfo);
		utils.trace('	Hero artifacts		: ' + savefile.data.artifacts, utils.t_saveinfo);
		utils.trace('	Game difficulty		: ' + savefile.data.diff, utils.t_saveinfo);
		utils.trace('	Timer				: ' + savefile.data.timer_now +'/' +savefile.data.timer_max + ' min.', utils.t_saveinfo);
		utils.trace('	Saving princess		: ' + savefile.data.saving_princess, utils.t_saveinfo);
		utils.trace('	Game levels			: ' + savefile.data.level_sequence, utils.t_saveinfo);
		utils.trace('	Now at level index	: ' + savefile.data.levelIndex, utils.t_saveinfo);
		utils.trace('	Graphics quality	: ' + savefile.data.graphics_quality, utils.t_saveinfo);
		
		
		utils.trace();
	}
}
