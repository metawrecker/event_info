::EventInfo.TileUtil <- {
	m = {

	},

	function getTileType()
	{
		local currentTile = this.World.State.getPlayer().getTile();

		foreach (key, value in this.Const.World.TerrainType) {
			if (value == currentTile.Type) {
				return key;
			}
		}

		return "NA";
	}

	function getTerrainType()
	{
		local currentTile = this.World.State.getPlayer().getTile();

		foreach (key, value in this.Const.World.TerrainTacticalType) {
			if (value == currentTile.TacticalType) {
				return key;
			}
		}

		return "NA";
	}

	function hostilesAreWithin4Tiles()
	{
		local parties = this.World.getAllEntitiesAtPos(this.World.State.getPlayer().getPos(), 400.0);

		foreach( party in parties )
		{
			if (!party.isAlliedWithPlayer())
			{
				return "Yes";
			}
		}

		return "No";
	}
}