::EventManagerInfo <- {
	ID = "mod_event_manager_info",
	Name = "Event Manager Info",
	Version = "0.9.2"
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
		FillyFiddler = "event.the_horseman"
	};

	local eventMayGiveBrother = function(currentEventId)
	{
		foreach ( _, eventId in brotherEventIds)
		{
			if (currentEventId == eventId) {
				return true;
			}
		}

		return false;
	}

	local printEventsToLog = function()
	{
		try {
			local eventManager = new("scripts/events/event_manager");
			local allScores = 0;
			local nonEventBroScore = 0;
			local eventBroScore = 0;
			local broEventsInPool = {};
			local nonBroEventsInPool = {};

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
					local eventScore = eventManager.m.Events[i].getScore();
					local eventCooldown = eventManager.m.Events[i].m.Cooldown / this.World.getTime().SecondsPerDay;

					if (eventCooldown > 99999) {
						eventCooldown = 99999;
					}

					local logDetail = "Score: " + eventScore + ". Cooldown: " + eventCooldown;

					allScores += eventScore;

					if (eventMayGiveBrother(eventManager.m.Events[i].getID())) {
						broEventsInPool[eventManager.m.Events[i].getID()] <- logDetail;
						eventBroScore += eventScore;
					}
					else {
						nonBroEventsInPool[eventManager.m.Events[i].getID()] <- logDetail;
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

	// enable later when JS and or CSS files are needed
	// ::mods_registerJS("./mods/EventManagerInfo/index.js");
	// ::mods_registerCSS("./mods/EventManagerInfo/index.css");
})