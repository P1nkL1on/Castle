class items{
	static var allItems:Array = new Array();
	static function spawnItem(itemName:String, X, Y){
		var newItem:MovieClip = spawning.spawnUnit('item', X, Y);
		newItem.model.gotoAndStop(itemName);	
		newItem._z = 100;
		newItem.itemName = itemName;
		newItem.slotsForExecute.push(function(who:MovieClip){ 
			who.minZ = who.model._height / 2
			if (who._z > who.minZ){
				 if (-who.sp_z >= who._z - who.minZ){
					if (Math.abs(who.sp_z) > 2){
						who._z = who.minZ + 1;
						who.sp_z *= -.3;
					}else{
						trace(who.sp_z);
						who._z = who.minZ;
						who.sp_z = 0;
					}
				}else{
					who._z += who.sp_z;
					who.sp_z -= who.G;
				}
			}
		});
		allItems.push(newItem);
		return newItem;
	}
}