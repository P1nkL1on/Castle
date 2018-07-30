class saving{
	static var savefile;
	static function loadGame(){
		savefile = SharedObject.getLocal("Castle_game_save");
		if (savefile.data.saved == undefined){
			// create clear save file
			trace('There was no correcr save file; Created new game save;');
		}else{
			// load info
			trace('Found a load file! Loading...');
		}
	}
	static function saveGame(){
		trace('Saving game...');
		savefile.data.info = 1337;
		savefile.data.saved = true;
		savefile.flush(); 
		trace('Game saved.');
	}
}
// var savefile = SharedObject.getLocal("TTsave");
	// var info:Array = new Array(1,2,3);
	
	// function LoadGame (){
		// var savefile = SharedObject.getLocal("TTsave");
	
		// if (savefile.data.saved == undefined) {
			// //то, что происходит, если загрузочный файл - не найден. Дефолтное состояние
				// /*убито различных врагов*/
				// _root.info = new Array(); for (var i = 0; i < 100; i++) _root.info.push(-1);
				// trace('> Game did not found. Creating a new save file');
		// } else {
			// //если файл таки нашли, то загруаем все из него
				// /*загрузка массивов*/
				// _root.info = savefile.data.info;
				// trace('> Game loaded');
		// }
		// Trac ();
	// }
	// function SaveGame (reset){
		// /*сохранение данных в массивы*/
		// if (reset == undefined){
			// savefile.data.info = _root.info;
			// savefile.data.saved = true;
			// savefile.flush(); 
			// trace('> Game progress saved');
		// }else{
			// savefile.data.info = undefined;
			// savefile.data.saved = undefined;
			// savefile.flush();
			// trace ('> Game progress reset');
		// }
	// }
	// function Trac (){
		// trace ("Info: \n" + _root.info);
	// }