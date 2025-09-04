::EventManagerInfo <- {
	ID = "mod_event_manager_info",
	Name = "Event Manager Info",
	Version = "0.9.3",
	Events = []
}

::mods_registerMod(::EventManagerInfo.ID, ::EventManagerInfo.Version, ::EventManagerInfo.Name);

::mods_queue(::EventManagerInfo.ID, "mod_msu(>=1.2.0)", function()
{
	::EventManagerInfo.Mod <- ::MSU.Class.Mod(::EventManagerInfo.ID, ::EventManagerInfo.Version, ::EventManagerInfo.Name);

	local brotherEventIds = {
		Volunteers = "event.volunteers",
		AnatomistJoin = "event.anatomist_joins",
		AnatomistBlightedGuy = "event.anatomist_helps_blighted_guy_1",
		CultistJoins = "event.cultist_origin_flock",
		DeserterJoinsDeserterOrigin = "event.deserter_origin_volunteer",
		SquireJoinsLonewolfOrigin = "event.lone_wolf_origin_squire",
		IndebtedJoinsManhunterOrigin = "event.manhunters_origin_capture_prisoner",
		Pirates = "event.pirates",
		OathtakerJoins = "event.oathtaker_joins",
		BastardAssassin = "event.bastard_assassin",
		RetiredGladiator = "event.retired_gladiator",
		Juggler = "event.fire_juggler",
		PimpVsHarlot = "event.pimp_vs_harlot",
		ImprisonedWildman = "event.imprisoned_wildman",
		ConvertedCrusader = "event.crisis.holywar_crucified_1",
		CivilwarDeserter = "event.crisis.civilwar_deserter",
		MasterNoUseApprentice = "event.master_no_use_apprentice",
		BarbarianVolunteer = "event.barbarian_volunteer",
		BellyDancer = "event.belly_dancer",
		Deserter = "event.deserter_in_forest",
		Kingsguard = "event.kings_guard_1",
		RunawayLabourers = "event.runaway_laborers",
		LindwormSlayer = "event.crisis.lindwurm_slayer",
		ThiefCaught = "event.thief_caught",
		CannonExecution = "event.cannon_execution",
		MelonThief = "event.melon_thief",
		TheHorseman = "event.the_horseman"
	};

	local eventMayGiveBrother = function(currentEventId)
	{
		foreach ( _, eventId in brotherEventIds)
		{
			if (currentEventId == eventId) {
				if (eventId == "event.fire_juggler") {
					//need to check for a juggler in the company for if the bro can even be 'hired'
				}


				return true;
			}
		}

		return false;
	}

	local playerIsTooCloseToEnemyParty = function()
	{
		local parties = this.World.getAllEntitiesAtPos(this.World.State.getPlayer().getPos(), 400.0);

		foreach( party in parties )
		{
			if (!party.isAlliedWithPlayer())
			{
				return true;
			}
		}

		return false;
	}

	local printEventsToLog = function()
	{
		try {
			//local eventManager = new("scripts/events/event_manager");
			local allScores = 0;
			local nonEventBroScore = 0;
			local eventBroScore = 0;
			local broEventsInPool = {};
			local nonBroEventsInPool = {};

			try {
				// local test = ::MSU.asWeakTableRef("events/event_manager");

				// ::MSU.Log.printData(test);

				local test = ::World.Events;

				local test2 = ::Events;

				//::MSU.Log.printData(test);

				::logWarning(test);
				::MSU.Log.printData(test2);


				// local allEvents = ::MSU.getField("events/event_manager", "Events"); //::mods_getField("events/event_manager", "Events"); //::EventManagerInfo.Events;
				// local lastEventId = ::MSU.getField("events/event_manager", "LastEventID");

				// ::MSU.Log.printData(allEvents);
				// ::MSU.Log.printData(lastEventId);
			} catch (exception){
				::logError("Error while trying to get fields" + exception);
			}

			local allEvents = [];

			if (allEvents.len() == 0) {
				::logError("No events are in memory yet!");
				return;
			}

			for( local i = 0; i < allEvents.len(); i = ++i )
			{
				if (lastEventId == allEvents[i].getID() && !allEvents[i].isSpecial())
				{
					allEvents[i].clear();
				}
				else
				{
					allEvents[i].update();
				}

				if (allEvents[i].getScore() > 0)
				{
					local eventScore = allEvents[i].getScore();
					local eventCooldown = allEvents[i].m.Cooldown / this.World.getTime().SecondsPerDay;

					if (eventCooldown > 99999) {
						eventCooldown = 99999;
					}

					local logDetail = "Score: " + eventScore + ". Cooldown: " + eventCooldown;

					allScores += eventScore;

					if (eventMayGiveBrother(allEvents[i].getID())) {
						broEventsInPool[allEvents[i].getID()] <- logDetail;
						eventBroScore += eventScore;
					}
					else {
						nonBroEventsInPool[allEvents[i].getID()] <- logDetail;
						nonEventBroScore += eventScore;
					}
				}
			}

			local chanceForEventBrother = 0;

			if (eventBroScore > 0) {
				chanceForEventBrother = ((eventBroScore * 1.0) / (allScores * 1.0)) * 100.0;
			}

			local currentTile = this.World.State.getPlayer().getTile();

			local tileDetails = {};

			tileDetails["OnRoad"] <- currentTile.HasRoad;

			foreach (key, value in this.Const.World.TerrainType) {
				if (value == currentTile.Type) {
					tileDetails["Type"] <- key;
				}
			}

			foreach (key, value in this.Const.World.TerrainTacticalType) {
				if (value == currentTile.TacticalType) {
					tileDetails["TacticalType"] <- key;
				}
			}

			::logWarning("********** Current Tile Details **********");
			::MSU.Log.printData(tileDetails);

			::logWarning("Too close to enemy party? " + playerIsTooCloseToEnemyParty());

			::logWarning("Sum of all event scores: " + allScores);
			::logWarning("Sum of non-brother event scores: " + nonEventBroScore);
			::logWarning("Sum of only event brother scores: " + eventBroScore + ". Chance for any event bro: " + ::MSU.Math.roundToDec( chanceForEventBrother, 4 ) + "%");

			::logWarning("********** Event Brothers that you currently qualify for **********");
			::MSU.Log.printData(broEventsInPool);

			::logWarning("********** Other (non bro!) events that you currently qualify for **********");
			::MSU.Log.printData(nonBroEventsInPool);

			::logWarning("************************************************************************************");
		} catch(exception) {
			::logError("The following exception occurred while trying to print events to the log.");
			::MSU.Log.printData(exception);
		}
	}

	::EventManagerInfo.Mod.Keybinds.addSQKeybind("PrintEvents", "ctrl+e", ::MSU.Key.State.All, function() {
		printEventsToLog();
	}, "Print events", ::MSU.Key.KeyState.Press);

	// ::mods_hookExactClass("events/event_manager", function (o)
	// {
	// 	// ::logWarning("Hooked event manager!");

	// 	// try {
	// 	// 	::MSU.Log.printData(o.m.Events);
	// 	// } catch (exception){
	// 	// 	::logError(exception);
	// 	// }

	// 	try {

	// 		local onUpdate = o.update;
	// 		o.update = function()
	// 		{
	// 			onUpdate();

	// 			::logWarning("Update() hook run!");

	// 			::MSU.Log.printData(o.m.Events);

	// 			///this doesn't appear to work --- why..


	// 			::EventManagerInfo.Events = o.m.Events;
	// 		}
	// 	} catch (exception){
	// 		::logError("Error while hooking update()" + exception);
	// 	}


	// });



	// enable later when JS and or CSS files are needed
	// ::mods_registerJS("./mods/EventManagerInfo/index.js");
	// ::mods_registerCSS("./mods/EventManagerInfo/index.css");
})