::EventManagerInfo <- {
	ID = "mod_event_manager_info",
	Name = "Event Manager Info",
	Version = "0.9.4"
}

local requiredMods = [
	"vanilla >= 1.5.1-6",
	"mod_msu >= 1.3.0",
	"mod_modern_hooks >= 0.4.10"
];

local modLoadOrder = [];
foreach (mod in requiredMods) {
	local idx = mod.find(" ");
	modLoadOrder.push(">" + (idx == null ? mod : mod.slice(0, idx)));
}

::EventManagerInfo.HooksMod <- ::Hooks.register(::EventManagerInfo.ID, ::EventManagerInfo.Version, ::EventManagerInfo.Name);
::EventManagerInfo.HooksMod.require(requiredMods);

//::mods_registerMod(::EventManagerInfo.ID, ::EventManagerInfo.Version, ::EventManagerInfo.Name);

::EventManagerInfo.HooksMod.queue(modLoadOrder, function() {
 	local mod = ::MSU.Class.Mod(::EventManagerInfo.ID, ::EventManagerInfo.Version, ::EventManagerInfo.Name);
	::EventManagerInfo.Mod <- mod;

	// mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, "https://github.com/metawrecker/equal_location_scouting");
	// mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);
	//mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.NexusMods, "https://www.nexusmods.com/battlebrothers/mods/937");







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

	::EventManagerInfo.PrintEventsToLog <- function(printAll, clearLastFiredEvent)
	{
		// began moving the following to event_utils...


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
				allEvents[i].clear();

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
					local cooldownUntil = (allEvents[i].m.CooldownUntil / this.World.getTime().SecondsPerDay);
					local firedOn = cooldownUntil - (allEvents[i].m.Cooldown / this.World.getTime().SecondsPerDay);

					if (cooldownUntil > 9999) {
						cooldownUntil = 9999;
					}

					eventsOnCooldown.append({
							id = allEvents[i].getID(),
							onCooldownUntilDay = ::MSU.Math.roundToDec( cooldownUntil, 4 )
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

			// if (printAll) {
			// 	::logWarning("Too close to enemy party? " + playerIsTooCloseToEnemyParty());
			// 	::logWarning("Long enough time after last battle? " + canFireEventAfterLastBattle);
			// 	::logWarning("Has minimum time since last event passed? " + canFireEventBasedOnGlobalMinDelay);
			// 	::logWarning("Time since last event: " + timeSinceLastEvent);
			// 	::logWarning("Chance to fire an event now: " + chanceToFireEvent);
			// }

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

	::EventManagerInfo.DisplayEventsInUI <- function()
	{
		::logInfo("Trying to show UI");
		::EventManagerInfo.EventScreen.show();
	}

	::include("event_manager/file_loading");

	::Hooks.registerJS("ui/mods/event_manager/event_manager_screen.js");
	::Hooks.registerCSS("ui/mods/event_manager/event_manager_screen.css");

	::EventManagerInfo.EventScreen <- ::new("scripts/ui/screens/event_manager_screen");
	::EventManagerInfo.JSConnection <- ::new("event_manager/event_manager_js_connection");

	::MSU.UI.registerConnection(::EventManagerInfo.JSConnection);
	::MSU.UI.registerConnection(::EventManagerInfo.EventScreen);
	::MSU.UI.addOnConnectCallback(::EventManagerInfo.JSConnection.finalize.bindenv(::EventManagerInfo.JSConnection));
});

// ::mods_queue(::EventManagerInfo.ID, "mod_msu(>=1.2.0)", function()
// {
// 	::EventManagerInfo.Mod <- ::MSU.Class.Mod(::EventManagerInfo.ID, ::EventManagerInfo.Version, ::EventManagerInfo.Name);

// 	// enable later when JS and or CSS files are needed
// 	// ::mods_registerJS("./mods/EventManagerInfo/index.js");
// 	// ::mods_registerCSS("./mods/EventManagerInfo/index.css");
// })