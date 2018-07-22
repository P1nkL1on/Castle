class items{
	static var allItems:Array = new Array();
	static function removeItem(item:MovieClip){
		trace('Deleteing item :: '+item);
		for (var i = 0; i < allItems.length; ++i)
			if (allItems[i] == item){
				var tmp:MovieClip = allItems[i];
				allItems[i] = allItems[allItems.length - 1];
				allItems[allItems.length - 1] = tmp;
				allItems.pop();
				//item._x = item._y = item.model._x = item.model._y = -1000;
				item.model.removeMovieClip();
				if (item.model != undefined)
					{trace('Error in deleting model'); item.model._visible = false;	}
				item.removeMovieClip();
				if (item.model != undefined)
					trace('Error in deleting shadow');
				return;
			}
	}
	static function spawnItem(itemName:String, X, Y){
		var newItem:MovieClip = spawning.spawnUnit('item', X, Y);
		newItem.model.gotoAndStop(itemName);	
		newItem._z = 100;
		newItem.itemName = itemName;
		newItem.CD = 0;
		newItem.mustHaveReflection = true;
		newItem.slotsForExecute.push(function(who:MovieClip){ 
			who.minZ = who.model._height / 2;
			if (who.CD > -1)
				who.CD -= animating.worldTimeSpeed;
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