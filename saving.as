class saving{
	static var savefile;
	static var saveFileName = "Castle_game_save";
	static var newGameOnly = false;
	
	static function loadGame(){
		savefile = SharedObject.getLocal(saveFileName);
		if (savefile.data.saved == undefined){
			// create clear save file
			utils.trace('There was no correct save file; Created new game save;', utils.t_saveinfo);
			newGameOnly = true;
		}else{
			// load info
			utils.trace('Found a load file! Loading...', utils.t_saveinfo);
			utils.hero_armor_color = savefile.data.heroRGB;
			utils.hero_has_items = savefile.data.artifacts;
			
			utils.game_difficulty = savefile.data.diff;
			//utils.game_timer_max = savefile.data.timer_max;
			utils.game_timer_lasts = savefile.data.timer_now ;
			utils.game_save_princess = savefile.data.saving_princess;
			lev
			levels.testLevels = savefile.data.level_sequence;
			levels.levelIndex = savefile.data.levelIndex;
			utils.graphics_quality = savefile.data.graphics_quality;
			_quality = utils.graphics_quality;
			
				
			utils.lives = savefile.data.lives;
			utils.lives_max = savefile.data.lives_max;
			utils.lives_per_level_finish = savefile.data.lives_per_level_finish;
			
			utils.trace('Loaded artifacts file loaded!', utils.t_saveinfo);
			traceFile(savefile);
		}
		//spawnEffect(true);
	}
	
	static function traceFile(savefile0){
		utils.trace('	Hero RGB			: ' + savefile0.data.heroRGB, utils.t_saveinfo);
		utils.trace('	Hero artifacts		: ' + savefile0.data.artifacts, utils.t_saveinfo);
		utils.trace('	Hero lifes			: ' + savefile0.data.lives + '/' + savefile0.data.lives_max + ' ( +'+savefile0.data.lives_per_level_finish+' )', utils.t_saveinfo);
		utils.trace('	Game difficulty		: ' + savefile0.data.diff, utils.t_saveinfo);
		utils.trace('	Timer				: ' + savefile0.data.timer_now +'/' +savefile0.data.timer_max + ' sec.', utils.t_saveinfo);
		utils.trace('	Saving princess		: ' + savefile0.data.saving_princess, utils.t_saveinfo);
		utils.trace('	Game levels			: ' + savefile0.data.level_sequence, utils.t_saveinfo);
		utils.trace('	Now at level index	: ' + savefile0.data.levelIndex, utils.t_saveinfo);
		utils.trace('	Graphics quality	: ' + savefile0.data.graphics_quality, utils.t_saveinfo);
	}
	
	static function saveGame(restart){
		if (restart == true){
			savefile = SharedObject.getLocal(saveFileName);
			savefile.data.saved = undefined;
			savefile.flush(); 
			utils.trace('** Game progress reset **',utils.t_saveinfo);
			levels.resetGame();
			return;
		}
		utils.trace('Saving game...', utils.t_saveinfo);
		
		savefile.data.heroRGB = utils.hero_armor_color;
		savefile.data.artifacts = utils.hero_has_items;
		
		savefile.data.diff = utils.game_difficulty;
		//savefile.data.timer_max = utils.game_timer_max;
		savefile.data.timer_now = utils.game_timer_lasts;
		savefile.data.saving_princess = utils.game_save_princess;
		
		savefile.data.level_sequence = levels.testLevels;
		savefile.data.levelIndex = levels.levelIndex;
		savefile.data.graphics_quality = utils.graphics_quality;
		
		savefile.data.lives = utils.lives;
		savefile.data.lives_max = utils.lives_max;
		savefile.data.lives_per_level_finish = utils.lives_per_level_finish;
		
		savefile.data.saved = true;
		savefile.flush(); 
		utils.trace('Game saved.',utils.t_saveinfo);
		traceFile(savefile);
		
		//spawnEffect();
	}
}
