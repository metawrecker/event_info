::EventInfo.Events <- {
	m = {
		BroHireEventsInPool = [],
		NonBroHireEventsInPool = [],
		EventsOnCooldown = [],
		AllScores = 0,
		NonEventBroHireScore = 0,
		EventBroHireScore = 0,
		BroHireEventIds = {
			Volunteers = "event.volunteers",
			AnatomistJoin = "event.anatomist_joins",
			AnatomistBlightedGuy = "event.anatomist_helps_blighted_guy_1",
			CultistJoins = "event.cultist_origin_flock",
			DeserterJoinsDeserterOrigin = "event.deserter_origin_volunteer",
			SquireJoinsLonewolfOrigin = "event.lone_wolf_origin_squire",
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
			TheHorseman = "event.the_horseman",
			DesertWell = "event.desert_well"
		},
		WorldSecondsPerDay = this.World.getTime().SecondsPerDay, //should be 105
		TimeToAddToMatchWorldClock = 0
	},

	/***************************************
	 * "public" functions
	***************************************/
	function getLastEventTime()
	{
		local lastEventTime = ::World.Events.m.LastEventTime;

		if (lastEventTime <= 0 || ::World.Events.m.LastEventID == 0) {
			::logInfo("Aborting out of getLastEventTime()");
			return "";
		}

		local days = lastEventTime / this.m.WorldSecondsPerDay;

		return createTimeOfDayDisplay(days);
	}

	function processEventsAndStoreValues()
	{
		if (::mods_getRegisteredMod("mod_hardened") != null) {
			::logInfo("Hardened mod detected - factoring timings and cooldowns using the alternative TimeOfDay schedule");
		}
		else {
			::logInfo("Vanilla detected - factoring timings and cooldowns using the original TimeOfDay schedule");
		}

		local virtualTime = this.Time.getVirtualTimeF();
		local eventManager = ::World.Events;

		setEventTimeWorldMapTimeOffset();

		this.m.BroHireEventsInPool = [],
		this.m.NonBroHireEventsInPool = [],
		this.m.EventsOnCooldown = [],
		this.m.AllScores = 0;
		this.m.NonEventBroHireScore = 0;
		this.m.EventBroHireScore = 0;

		local allEvents = eventManager.m.Events;
		local lastEventId = eventManager.m.LastEventID;

		for(local i = 0; i < allEvents.len(); i = ++i)
		{
			allEvents[i].clear();

			//should we not clear last event???
			if (lastEventId == allEvents[i].getID() && !allEvents[i].isSpecial())
			{
				allEvents[i].clear();
			}
			else
			{
				allEvents[i].update();
			}

			local currentEventId = allEvents[i].getID();

			// ::logWarning("Event Name: " + createHumanReadableEventName(currentEventId));
			// ::logInfo("Event cooldown setting: " + allEvents[i].m.Cooldown);
			// ::logInfo("Event Score: " + allEvents[i].getScore());

			if (allEvents[i].getScore() == 0 && allEvents[i].m.CooldownUntil > virtualTime && !allEvents[i].isSpecial()) {
				//::logInfo("OG cooldown: " + allEvents[i].m.CooldownUntil);
				local coolDownSeconds = getEventCooldownSecondsInWorldClockTime(allEvents[i]);
				local cooldownUntil = coolDownSeconds / this.m.WorldSecondsPerDay;
				local firedOn = cooldownUntil - (allEvents[i].m.Cooldown / this.m.WorldSecondsPerDay);
				local coolDownDisplay = this.Math.floor(cooldownUntil);
				local firedOnDisplay = createTimeOfDayDisplay(firedOn);

				if (coolDownDisplay > 9999) {
					coolDownDisplay = 9999;
				}

				this.m.EventsOnCooldown.append({
						id = currentEventId,
						name = createHumanReadableEventName(currentEventId),
						score = allEvents[i].getScore(),
						firedOnNumber = firedOn,
						firedOnDay = firedOnDisplay,
						mayGiveBrother = eventMayGiveBrother(allEvents[i]),
						onCooldownUntilDay = coolDownDisplay,
						onCooldownUntilDayNumber = cooldownUntil,
						icon = getEventIcon(currentEventId),
						background = getBackgroundName(currentEventId)
					});
			}

			if (allEvents[i].getScore() > 0)
			{
				local eventScore = allEvents[i].getScore();
				local eventCooldown = allEvents[i].m.Cooldown / this.World.getTime().SecondsPerDay;

				if (eventCooldown > 9999) {
					eventCooldown = 9999;
				}

				this.m.AllScores += eventScore;

				local eventToAdd = {
						id = currentEventId,
						name = createHumanReadableEventName(currentEventId),
						score = eventScore,
						cooldown = eventCooldown,
						mayGiveBrother = false,
						isBroEvent = eventIsBrotherEvent(currentEventId),
						chanceForBrother = getChanceForBrother(currentEventId),
						isCrisesEvent = isEventForACrises(currentEventId),
						icon = getEventIcon(currentEventId),
						background = getBackgroundName(currentEventId)
					};

				if (eventMayGiveBrother(allEvents[i])) {
					eventToAdd.mayGiveBrother = true;
					this.m.BroHireEventsInPool.append(eventToAdd);
					this.m.EventBroHireScore += eventScore;
				}
				else {
					this.m.NonBroHireEventsInPool.append(eventToAdd);
					this.m.NonEventBroHireScore += eventScore;
				}

				//::MSU.Log.printData(eventToAdd);
			}
		}
	}

	function getAllEventsInQueue()
	{
		local events = getBroHiringEventsInQueue();
		local nonBroEvents = getNonBroHiringEventsInQueue();

		events.extend(nonBroEvents);

		return events;
	}

	function getBroHiringEventsInQueue()
	{
		return this.m.BroHireEventsInPool;
	}

	function getNonBroHiringEventsInQueue()
	{
		return this.m.NonBroHireEventsInPool;
	}

	function getEventsOnCooldown()
	{
		return this.m.EventsOnCooldown;
	}

	function getAllEventScore()
	{
		return this.m.AllScores;
	}

	function getEventBroHiringScore()
	{
		return this.m.EventBroHireScore;
	}

	function getNonEventBroHiringScore()
	{
		return this.m.NonEventBroHireScore;
	}

	/***************************************
	 * "private" functions
	***************************************/
	function eventIsBrotherEvent(currentEventId)
	{
		foreach ( key, eventId in this.m.BroHireEventIds)
		{
			if (currentEventId == eventId) {
				return true;
			}
		}

		return false;
	}

	function eventMayGiveBrother(event)
	{
		local currentEventId = event.getID();

		foreach ( key, eventId in this.m.BroHireEventIds)
		{
			if (currentEventId == eventId) {
				local eventData = event.m;

				switch (eventId) {
					case "event.anatomist_helps_blighted_guy_1":
						return eventData.Anatomist != null;
					case "event.retired_gladiator":
						return eventData.Gladiator != null;
					case "event.fire_juggler":
						return eventData.Juggler != null;
					case "event.pimp_vs_harlot":
						return eventData.Monk != null;
					case "event.imprisoned_wildman":
						return eventData.Wildman != null || eventData.Monk != null;
					case "event.desert_well":
						return eventData.Monk != null;
				}

				return true;
			}
		}

		return false;
	}

	function createHumanReadableEventName(eventId)
	{
		local readableName = "";
		local tempName = "No name";
		local appendCrises = false;

		if (eventId == "")
			return tempName;

		if (eventId.find("event.crisis.") != null) {
			tempName = eventId.slice(13);
			appendCrises = true;
		}
		else if (eventId.find("event.") != null) {
			tempName = eventId.slice(6);
		}
		else {
			tempName = eventId;
		}

		local words = split(tempName, "_");

		if (appendCrises && !eventIsBrotherEvent(eventId)) {
			words.insert(0, "crisis");
		}

		foreach(index, word in words) {
			local firstCharacter = word.slice(0, 1);
			local otherCharacters = word.slice(1);

			readableName += firstCharacter.toupper() + otherCharacters + " ";
		}

		strip(readableName);

		return readableName;
	}

	function getChanceForBrother(currentEventId)
	{
		switch (currentEventId) {
			case "event.anatomist_helps_blighted_guy_1":
				return 50;
			case "event.runaway_laborers":
				return 70;
			case "event.thief_caught":
				return 56;
			case "event.the_horseman":
				return 75;
		}

		return 100;
	}

	function isEventForACrises(currentEventId)
	{
		return currentEventId.find("event.crisis.") != null;
	}

	function getEventIcon(currentEventId)
	{
		local multipleBrosPossibleIcon = "ui/icons/unknown_traits.png";
		local backgroundIconBasePath = "ui/backgrounds/";

		switch (currentEventId) {
			case "event.volunteers":
				return multipleBrosPossibleIcon;
			case "event.anatomist_joins":
			case "event.anatomist_helps_blighted_guy_1":
				return backgroundIconBasePath + "background_70.png";
			case "event.cultist_origin_flock":
				return backgroundIconBasePath + "background_34.png";
			case "event.deserter_origin_volunteer":
			case "event.deserter_in_forest":
			case "event.crisis.civilwar_deserter":
				return backgroundIconBasePath + "background_07.png";
			case "event.lone_wolf_origin_squire":
				return backgroundIconBasePath + "background_03.png";
			case "event.pirates":
				return backgroundIconBasePath + "background_41.png";
			case "event.oathtaker_joins":
				return backgroundIconBasePath + "background_69.png";
			case "event.bastard_assassin":
				return backgroundIconBasePath + "background_53.png";
			case "event.retired_gladiator":
				return backgroundIconBasePath + "background_61.png";
			case "event.fire_juggler":
				return backgroundIconBasePath + "background_14.png";
			case "event.pimp_vs_harlot":
				return backgroundIconBasePath + "background_56.png";
			case "event.imprisoned_wildman":
				return backgroundIconBasePath + "background_31.png";
			case "event.crisis.holywar_crucified_1":
				return backgroundIconBasePath + "background_65.png";
			case "event.master_no_use_apprentice":
				return backgroundIconBasePath + "background_40.png";
			case "event.barbarian_volunteer":
				return backgroundIconBasePath + "background_58.png";
			case "event.belly_dancer":
				return backgroundIconBasePath + "background_64.png";
			case "event.kings_guard_1":
				return backgroundIconBasePath + "background_59.png";
			case "event.thief_caught":
			case "event.runaway_laborers":
				return multipleBrosPossibleIcon;
			case "event.crisis.lindwurm_slayer":
				return backgroundIconBasePath + "background_71.png";
			case "event.cannon_execution":
			case "event.melon_thief":
				return backgroundIconBasePath + "background_11.png";
			case "event.the_horseman":
				return backgroundIconBasePath + "background_32.png";
			case "event.desert_well":
				return backgroundIconBasePath + "background_19.png";
			case "event.dog_in_swamp":
			case "event.adopt_wardog":
				return "ui/orientation/dog_01_orientation.png";
			case "event.adopt_warhound":
				return "ui/orientation/dog_02_orientation.png";
		}

		return "ui/icons/round_information/round_number_icon.png";
	}

	function getBackgroundName(currentEventId)
	{
		switch (currentEventId) {
			case "event.volunteers":
			case "event.thief_caught":
			case "event.runaway_laborers":
				return "generate-bro-list"; //this dynamically creates a list of all the backgrounds the event can reward
			case "event.anatomist_joins":
			case "event.anatomist_helps_blighted_guy_1":
				return "anatomist";
			case "event.cultist_origin_flock":
				return "cultist";
			case "event.deserter_origin_volunteer":
			case "event.crisis.civilwar_deserter":
			case "event.deserter_in_forest":
				return "deserter";
			case "event.lone_wolf_origin_squire":
				return "squire";
			case "event.pirates":
				return "fisherman";
			case "event.oathtaker_joins":
				return "paladin";
			case "event.bastard_assassin":
				return "assassin";
			case "event.retired_gladiator":
				return "gladiator";
			case "event.fire_juggler":
				return "juggler";
			case "event.pimp_vs_harlot":
				return "pimp";
			case "event.imprisoned_wildman":
				return "wildman";
			case "event.crisis.holywar_crucified_1":
				return "crucified";
			case "event.master_no_use_apprentice":
				return "apprentice";
			case "event.barbarian_volunteer":
				return "barbarian";
			case "event.belly_dancer":
				return "belly_dancer";
			case "event.kings_guard_1":
				return "kings_guard";
			case "event.crisis.lindwurm_slayer":
				return "lindwurm_slayer";
			case "event.cannon_execution":
			case "event.melon_thief":
				return "thief";
			case "event.the_horseman":
				return "vagabond";
			case "event.desert_well":
				return "peddler";
		}

		return "NA";
	}

	function setEventTimeWorldMapTimeOffset()
	{
		local mapTime = this.World.getTime();
		local currentTime = this.World.getTime().Time;
		local virtualTime = this.Time.getVirtualTimeF();

		this.m.TimeToAddToMatchWorldClock = currentTime - virtualTime;

		// ::logInfo("Map Time: " + currentTime);
		// ::logInfo("Map Day #: " + mapTime.Days);
		// ::logInfo("Map Hour #: " + mapTime.Hours);
		// ::logInfo("Map Minute #: " + mapTime.Minutes);
		// ::logInfo("Map Time of Day: " + this.Const.Strings.World.TimeOfDay[mapTime.TimeOfDay]);
		// ::logInfo("Event Time: " + virtualTime);
		// ::logInfo("Time Diff: " + this.m.TimeToAddToMatchWorldClock);
	}

	function getEventCooldownSecondsInWorldClockTime(event)
	{
		return event.m.CooldownUntil + this.m.TimeToAddToMatchWorldClock;
	}

	function createTimeOfDayDisplay(eventDays)
	{
		local currentTime = this.World.getTime();
		local secondsPerDay = currentTime.SecondsPerDay;
		local secondsPerHour = currentTime.SecondsPerHour;
		local secondsPerMinute = secondsPerHour / 60;
		local timeDisplay = "";
		local hours = 0;
		local minutes = 0;
		local seconds = 0;
		local formatString = "%.2f";
		local eventTimeSeconds = 0;

		// ::logInfo("************************************************************");
		// ::logInfo("Entry Fired On: " + eventDays);

		local days = this.Math.floor(eventDays);
		local partialDay = eventDays % 1;
		local secondsRemaining = partialDay * 105;

		// ::logInfo("# Days: " + days);
		// ::logInfo("Partial Day: " + format(formatString, partialDay));

		if (secondsRemaining >= secondsPerHour) {
			hours = this.Math.floor(secondsRemaining / secondsPerHour);
			secondsRemaining = secondsRemaining - (hours * secondsPerHour);
		}

		if (secondsRemaining >= secondsPerMinute) {
			minutes = this.Math.floor(secondsRemaining / secondsPerMinute)
			secondsRemaining = secondsRemaining - (minutes * secondsPerMinute);
		}

		if (secondsRemaining > 0) {
			seconds = secondsRemaining;
		}

		local timeDisplay = days + " - ";

		if (::mods_getRegisteredMod("mod_hardened") != null)
		{
			//Hardened:
			//https://github.com/Darxo/Hardened/blob/68e1eb6053b39931820d69d325cb00a4d57bf1e8/mod_hardened/hooks/config/root_table.nut

			// ::Const.Strings.World.TimeOfDay <- [
			// 	"Morning", 0, 1
			// 	"Morning", 2, 3
			// 	"Morning", 4, 5
			// 	"Midday", 6, 7
			// 	"Afternoon", 8, 9
			// 	"Afternoon", 10, 11
			// 	"Afternoon", 12, 13
			// 	"Sunset", 14, 15
			// 	"Dusk", 16, 17
			// 	"Midnight", 18, 19
			// 	"Dawn", 20, 21
			// 	"Sunrise", 22, 23 (This is a new numerical day..)
			// ];

			if (hours >= 0 && hours <= 5) {
				timeDisplay += this.Const.Strings.World.TimeOfDay[0]; //" Morning";
			}
			else if (hours == 6 || hours == 7) {
				timeDisplay += this.Const.Strings.World.TimeOfDay[3]; //" Midday";
			}
			else if (hours >= 8 && hours <= 13) {
				timeDisplay += this.Const.Strings.World.TimeOfDay[4]; //" Afternoon";
			}
			else if (hours == 14 || hours == 15) {
				timeDisplay += this.Const.Strings.World.TimeOfDay[7]; //" Sunset";
			}
			else if (hours == 16 || hours == 17) {
				timeDisplay += this.Const.Strings.World.TimeOfDay[8]; //" Dusk";
			}
			else if (hours == 18 || hours == 19) {
				timeDisplay += this.Const.Strings.World.TimeOfDay[9]; //" Midnight";
			}
			else if (hours == 20 || hours == 21) {
				timeDisplay += this.Const.Strings.World.TimeOfDay[10]; //" Dawn";
			}
			else if (hours == 22 || hours == 23) {
				timeDisplay = days + 1 + " - " + this.Const.Strings.World.TimeOfDay[11]; //" Sunrise";
			}
		}
		else
		{
			//Pulled from a comment from Darxo in the BB Modding Discord - thanks Darxo!
			// Vanilla
			// ::Const.Strings.World.TimeOfDay <- [
			// "Dawn" - 0,
			// "Morning"- 1, 2
			// "Midday" - 2, 3, 4, 5, 6, 7, 8, 9
			// "Afternoon" - 9, 10, 11, 12, 13
			// "Evening" - 14,
			// "Dusk" - 14, 15, 16, 17
			// "Night" - 17, 18, 19, 20, 21, 22
			// "Dawn" - 22, 23
			// ];

			if (hours == 0) {
				timeDisplay += this.Const.Strings.World.TimeOfDay[0]; //" Dawn";
			}
			else if (hours == 1 || (hours == 2 && minutes == 0)) {
				timeDisplay += this.Const.Strings.World.TimeOfDay[1]; //Morning;
			}
			else if ((hours == 2 && minutes > 1) || (hours > 2 && hours <= 8) || (hours == 9 && minutes == 0)) {
				timeDisplay += this.Const.Strings.World.TimeOfDay[2]; //Midday
			}
			else if ((hours == 9 && minutes > 1) || (hours > 9 && hours <= 12) || (hours == 13 && minutes == 0)) {
				timeDisplay += this.Const.Strings.World.TimeOfDay[3]; //Afternoon
			}
			else if ((hours == 13 && minutes > 1) || (hours == 14 && minutes == 0)) {
				timeDisplay += this.Const.Strings.World.TimeOfDay[4]; //Evening
			}
			else if (hours == 14 && minutes > 0 || (hours > 14 && hours <= 16) || (hours == 17 && minutes == 0)) {
				timeDisplay += this.Const.Strings.World.TimeOfDay[5]; //Dusk
			}
			else if (hours == 17 && minutes > 0 || (hours > 17 && hours <= 21) || (hours == 22 && minutes == 0)) {
				timeDisplay += this.Const.Strings.World.TimeOfDay[6]; //Night
			}
			else if (hours == 22 || hours == 23) {
				timeDisplay += this.Const.Strings.World.TimeOfDay[7]; //Dawn
			}
		}

		// ::logInfo("Hours: " + format(formatString, hours));
		// ::logInfo("Minutes: " + format(formatString, minutes));
		// ::logInfo("Seconds: " + format(formatString, seconds));
		// ::logInfo("Time Display: " + timeDisplay);
		// ::logInfo("************************************************************");

		return timeDisplay;
	}
};

