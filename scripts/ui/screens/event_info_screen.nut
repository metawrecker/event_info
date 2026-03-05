this.event_info_screen <- ::inherit("scripts/mods/msu/ui_screen", {
	m = {
		ID = "EventInfoScreen"
	},

	function create()
	{
		this.ui_screen.create();
	}

	function getUIData()
	{
		::EventInfo.Events.processEventsAndStoreValues();

		local ret = {
			BroHireEventsInPool = [],
			NonBroHireEventsInPool = [],
			EventsOnCooldown = [],
			AllScores = 0,
			NonEventBroHireScore = 0,
			EventBroHireScore = 0
		};

		ret.BroHireEventsInPool = ::EventInfo.Events.getBroHiringEventsInQueue();
		ret.NonBroHireEventsInPool = ::EventInfo.Events.getNonBroHiringEventsInQueue();
		ret.EventsOnCooldown = ::EventInfo.Events.getEventsOnCooldown();
		ret.AllScores = ::EventInfo.Events.getAllEventScore();
		ret.NonEventBroHireScore = ::EventInfo.Events.getNonEventBroHiringScore();
		ret.EventBroHireScore = ::EventInfo.Events.getEventBroHiringScore();

		return ret;
	}

	function getEventInfo()
	{
		::EventInfo.News.init();

		local anyNews = ::EventInfo.News.anyNews();

		local ret = {
			AnyNews = "",
			//News = [],
			LastEventDayAndHour = "",
			CurrentTile = "",
			CurrentTerrain = "",
			EnemyWithin4Tiles = ""
		};

		ret.AnyNews = ::EventInfo.News.anyNews();
		//ret.News = ::EventInfo.News.getNews();
		ret.LastEventDayAndHour = ::EventInfo.Events.getLastEventTime();
		ret.CurrentTile = ::EventInfo.TileUtil.getTileType();
		ret.CurrentTerrain = ::EventInfo.TileUtil.getTerrainType();
		ret.EnemyWithin4Tiles = ::EventInfo.TileUtil.hostilesAreWithin4Tiles();

		return ret;
	}

	function show()
	{
		::World.State.setAutoPause(true);

		this.Cursor.setCursor(this.Const.UI.Cursor.Hand);

		::World.State.m.MenuStack.push(function(){
			::EventInfo.EventScreen.hide();
			this.setAutoPause(false);
		});

		local data = this.getUIData();
		local info = this.getEventInfo();

		this.Tooltip.hide();

		this.m.JSHandle.asyncCall("setData", data);
		this.m.JSHandle.asyncCall("setInfo", info);

		this.m.JSHandle.asyncCall("show", null);

		return false;
	}

	function hide()
	{
		if (this.isVisible())
		{
			this.m.JSHandle.asyncCall("hide", null);
			::World.State.m.MenuStack.pop();
			return false;
		}
	}

	function toggle()
	{
		if(this.m.Animating)
		{
			return false
		}

		this.isVisible() ? this.hide() : this.show();

		return true;
	}

	function onCloseButtonPressed()
	{
		this.hide();
	}
});
