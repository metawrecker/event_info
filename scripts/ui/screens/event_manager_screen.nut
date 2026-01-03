this.event_manager_screen <- ::inherit("scripts/mods/msu/ui_screen", {
	m = {
		ID = "EventManagerScreen",
		UIVisible = false
	},

	function create()
	{
	}

	function getUIData()
	{
		local ret = [];

		::EventManagerInfo.Events.processEventsAndStoreValues();
		local allEvents = ::EventManagerInfo.Events.getAllEventsInQueue();

		ret.extend(allEvents);

		::logWarning("GetUIData got the following: ");
		::MSU.Log.printData(ret);

		return ret;
	}

	function show()
	{
		if (this.m.UIVisible)
			return;

		try {
			this.ui_screen.show(this.getUIData());
			this.m.UIVisible = true;
		} catch (exception){
			::logError("Error while showing Events UI window. " + exception);
			this.m.UIVisible = false;
		}
	}
});
