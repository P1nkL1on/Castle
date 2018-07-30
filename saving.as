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
			utils.trace('Loaded RGB of hero armor : ' + savefile.data.heroRGB, utils.t_saveinfo);
			utils.hero_armor_color = savefile.data.heroRGB;
		}
	}
	static function saveGame(){
		utils.trace('Saving game...', utils.t_saveinfo);
		savefile.data.heroRGB = utils.hero_armor_color;
		savefile.data.saved = true;
		savefile.flush(); 
		utils.trace('Game saved.',utils.t_saveinfo);
	}
}
