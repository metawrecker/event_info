::EventManagerInfo <- {
	ID = "mod_event_manager_info",
	Name = "EventManagerInfo",
	Version = "1.0.0"
}

::mods_registerMod(::EventManagerInfo.ID, ::EventManagerInfo.Version, ::EventManagerInfo.Name);

::mods_queue(::EventManagerInfo.ID, null, function()
{
	::EventManagerInfo.Mod <- ::MSU.Class.Mod(::EventManagerInfo.ID, ::EventManagerInfo.Version, ::EventManagerInfo.Name);

	local printEventsToLog = function()
	{
		local eventManager = new("scripts/events/event_manager");
		local score = 0;
		local eventsInPool = {};

		for( local i = 0; i < eventManager.m.Events.len(); i = ++i )
		{
			if (eventManager.m.LastEventID == eventManager.m.Events[i].getID() && !eventManager.m.Events[i].isSpecial())
			{
				eventManager.m.Events[i].clear();
			}
			else
			{
				eventManager.m.Events[i].update();
			}

			if (eventManager.m.Events[i].getScore() > 0)
			{
				eventsInPool[eventManager.m.Events[i].getID()] <- eventManager.m.Events[i].getScore();
				score = score + eventManager.m.Events[i].getScore();
			}
		}

		::logWarning("Total number of 'score points': " + score);
		::logWarning("********** ALL EVENTS THAT YOU CURRENTLY QUALIFY FOR **********");
		::MSU.Log.printData(eventsInPool);
		::logWarning("************************************************************************************");

		// //focus on Thief in the night..
		// local thiefEvent = new("scripts/events/events/thief_caught_event");
		// thiefEvent.onUpdateScore();

		// //local test = thiefEvent.isSomethingToSee() && this.World.getTime().Days >= 7 ? 50 : 10;

		// //::logWarning("WHat does isSomethingToSee do? ", test);

		// ::logWarning("Chance for Caught Thief: " + thiefEvent.m.Score);
		// ::MSU.Log.printData(thiefEvent.m);
	}

	::EventManagerInfo.Mod.Keybinds.addSQKeybind("PrintEvents", "ctrl+e", ::MSU.Key.State.World, function() {
		printEventsToLog();
	}, "Print events", ::MSU.Key.KeyState.Press);

	// enable later when JS and or CSS files are needed
	// ::mods_registerJS("./mods/EventManagerInfo/index.js");
	// ::mods_registerCSS("./mods/EventManagerInfo/index.css");
})