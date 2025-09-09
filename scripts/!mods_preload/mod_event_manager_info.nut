::EventManagerInfo <- {
	ID = "mod_event_manager_info",
	Name = "Event Manager Info",
	Version = "0.9.3",
	PrintEventsToLog = null
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
		foreach ( key, eventId in brotherEventIds)
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

	// local sortEventsByScore = function (eventList)
	// {
	// 	local orderedList = {};

	// 	foreach (key, value in eventList)
	// 	{
	// 		//need to put values in ascending order?

	// 		if (key in orderedList) {

	// 		}
	// 	}
	// }

	::EventManagerInfo.PrintEventsToLog = function(printAll, clearLastFiredEvent)
	{
		try {
			//local eventManager = new("scripts/events/event_manager");
			local allScores = 0;
			local nonEventBroScore = 0;
			local eventBroScore = 0;
			local broEventsInPool = [];
			local nonBroEventsInPool = [];
			local eventsOnCooldown = [];

			if (::World.Events == null) {
				::logError("Event Manager is not ready yet");
			}

			local eventManager = ::World.Events;
			local allEvents = eventManager.m.Events;
			local lastEventId = eventManager.m.LastEventID;
			//local lastEventTime = eventManager.m.LastEventTime;
			local canFireEventAfterLastBattle = this.Time.getVirtualTimeF() - eventManager.m.LastBattleTime >= 2.0;
			local canFireEventBasedOnGlobalMinDelay = eventManager.m.LastEventTime + this.Const.Events.GlobalMinDelay > this.Time.getVirtualTimeF();
			local checkedTooSoon = this.Time.getVirtualTimeF() - eventManager.m.LastCheckTime <= this.World.getTime().SecondsPerHour * 2;
			local timeSinceLastEvent = this.Time.getVirtualTimeF() - eventManager.m.LastEventTime - this.Const.Events.GlobalMinDelay;
			local chanceToFireEvent = this.Const.Events.GlobalBaseChance + timeSinceLastEvent * this.Const.Events.GlobalChancePerSecond;

			if (allEvents.len() == 0) {
				::logError("No events are in memory yet!");
				return;
			}

			for( local i = 0; i < allEvents.len(); i = ++i )
			{
				if (clearLastFiredEvent && lastEventId == allEvents[i].getID() && !allEvents[i].isSpecial())
				{
					allEvents[i].clear();
				}
				else
				{
					allEvents[i].update();
				}

				local eventScore = allEvents[i].getScore();
				local eventCooldown = allEvents[i].m.Cooldown / this.World.getTime().SecondsPerDay;

				if (eventCooldown > 99999) {
					eventCooldown = 9999;
				}

				if (allEvents[i].getScore() == 0 && allEvents[i].m.CooldownUntil > 0 && !allEvents[i].isSpecial()) {
					local cooldownUntil = this.Math.floor(allEvents[i].m.CooldownUntil / this.World.getTime().SecondsPerDay);
					local firedOn = cooldownUntil - (allEvents[i].m.Cooldown / this.World.getTime().SecondsPerDay);

					if (cooldownUntil > 9999) {
						cooldownUntil = 9999;
					}

					eventsOnCooldown.append({
							id = allEvents[i].getID(),
							onCooldownUntilDay = cooldownUntil
							firedOnDay = firedOn
						});
				}

				if (allEvents[i].getScore() > 0)
				{
					local logDetail = "Score: " + eventScore + ". Cooldown: " + eventCooldown;

					allScores += eventScore;

					if (eventMayGiveBrother(allEvents[i].getID())) {
						broEventsInPool.append({
							id = allEvents[i].getID(),
							score = eventScore,
							cooldown = eventCooldown
						});
						eventBroScore += eventScore;
					}
					else {
						nonBroEventsInPool.append({
							id = allEvents[i].getID(),
							score = eventScore,
							cooldown = eventCooldown
						});
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

			if (eventManager.m.LastEventID != "")
			{
				local lastEvent = eventManager.getEvent(eventManager.m.LastEventID);

				::logWarning("Last Event: " + lastEvent.getTitle());
			}

			if (printAll) {
				::logWarning("Too close to enemy party? " + playerIsTooCloseToEnemyParty());
				::logWarning("Long enough time after last battle? " + canFireEventAfterLastBattle);
				::logWarning("Has minimum time since last event passed? " + canFireEventBasedOnGlobalMinDelay);
				::logWarning("Time since last event: " + timeSinceLastEvent);
				::logWarning("Chance to fire an event now: " + chanceToFireEvent);
			}

			::logWarning("Sum of all event scores: " + allScores);
			::logWarning("Sum of non-brother event scores: " + nonEventBroScore);
			::logWarning("Sum of only event brother scores: " + eventBroScore + ". Chance for any event bro: " + ::MSU.Math.roundToDec( chanceForEventBrother, 4 ) + "%");

			::logWarning("********** Event Brothers that you currently qualify for **********");
			::MSU.Array.sortAscending(broEventsInPool, "score");
			::MSU.Log.printData(broEventsInPool, 3, false, 3);

			::logWarning("********** Other (non bro!) events that you currently qualify for **********");
			::MSU.Array.sortAscending(nonBroEventsInPool, "score");
			::MSU.Log.printData(nonBroEventsInPool, 3, false, 3);

			::logWarning("********** Fired events that are now on cooldown **********");
			::MSU.Array.sortAscending(eventsOnCooldown, "firedOnDay");
			::MSU.Log.printData(eventsOnCooldown, 3, false, 3);

			//::EventManagerInfo.Mod.Debug.addPopupMessage( "Test text", ::MSU.Popup.State.Small );

			::logWarning("************************************************************************************");
		} catch(exception) {
			::logError("The following exception occurred while trying to print events to the log.");
			::MSU.Log.printData(exception);
		}
	}

	::EventManagerInfo.Mod.Keybinds.addSQKeybind("PrintEvents", "ctrl+e", ::MSU.Key.State.All, function() {
		::EventManagerInfo.PrintEventsToLog(true, true);
	}, "Print events", ::MSU.Key.KeyState.Press);

	::include("mod_event_manager/event_manager");

	// enable later when JS and or CSS files are needed
	// ::mods_registerJS("./mods/EventManagerInfo/index.js");
	// ::mods_registerCSS("./mods/EventManagerInfo/index.css");
})