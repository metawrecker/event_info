this.event_manager_screen <- ::inherit("scripts/mods/msu/ui_screen", {
	m = {
		ID = "EventManagerScreen"
	},

	function create()
	{
	}

	function getUIData()
	{
		::EventManagerInfo.Events.processEventsAndStoreValues();

		local ret = {
			BroHireEventsInPool = [],
			NonBroHireEventsInPool = [],
			EventsOnCooldown = [],
			AllScores = 0,
			NonEventBroHireScore = 0,
			EventBroHireScore = 0
		};

		//local tempData = [];

		ret.BroHireEventsInPool = ::EventManagerInfo.Events.getBroHiringEventsInQueue();
		ret.NonBroHireEventsInPool = ::EventManagerInfo.Events.getNonBroHiringEventsInQueue();
		ret.EventsOnCooldown = ::EventManagerInfo.Events.getEventsOnCooldown();
		ret.AllScores = ::EventManagerInfo.Events.getAllEventScore();
		ret.NonEventBroHireScore = ::EventManagerInfo.Events.getNonEventBroHiringScore();
		ret.EventBroHireScore = ::EventManagerInfo.Events.getEventBroHiringScore();

		// local allEvents = ::EventManagerInfo.Events.getAllEventsInQueue();

		// ret.extend(allEvents);

		//tempData.extend(::EventManagerInfo.Events.getNonBroHiringEventsInQueue())

		//::logWarning("GetUIData got the following data: ");
		//::MSU.Log.printData(ret);

		return ret;
	}

	function show()
	{
		try {
			if (this.isVisible()) {
				return;
			}

			local data = this.getUIData();

			this.ui_screen.show(data);
			//this.m.UIVisible = true;
		} catch (exception){
			::logError("Error while showing Events UI window. " + exception);
			//this.m.UIVisible = false;
		}
	}
});
