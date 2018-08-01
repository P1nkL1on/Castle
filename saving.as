class saving{
	static var savefile;
	static function loadGame(){
		savefile = SharedObject.getLocal("Castle_game_save");
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
			savefile.data.saved = undefined;
			savefile.flush(); 
			utils.trace('** Game progress reset **',utils.t_saveinfo);
			return;
		}
		utils.trace('Saving game...', utils.t_saveinfo);
		savefile.data.heroRGB = utils.hero_armor_color;
		savefile.data.artifacts = utils.hero_has_items;
		savefile.data.saved = true;
		savefile.flush(); 
		utils.trace('Game saved.',utils.t_saveinfo);
		
	}
}