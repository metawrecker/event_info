::EventManagerInfo.Events <- {
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
		GameSaveIsFirstGameAfterGameLaunch = false,
		TimeToAddToMatchWorldClock = 0
	},

	function eventIsBrotherEvent(event)
	{
		local currentEventId = event.getID();

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

		local words = split(tempName, "_");

		if (appendCrises) {
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

	function getChanceForBrother(event)
	{
		switch (event.getID()) {
			case "event.anatomist_helps_blighted_guy_1":
				return 50;
			case "event.runaway_laborers":
				return 70;
			case "event.thief_caught":
			case "event.the_horseman":
				return 75;
		}

		return 100;
	}

	function isEventForACrises(event)
	{
		local eventId = event.getID();
		return eventId.find("event.crisis.") != null;
	}

	function getEventIcon(event)
	{
		local currentEventId = event.getID();
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
			case "event.crisis.civilwar_deserter":
				return backgroundIconBasePath + "background_07.png";
			case "event.master_no_use_apprentice":
				return backgroundIconBasePath + "background_40.png";
			case "event.barbarian_volunteer":
				return backgroundIconBasePath + "background_58.png";
			case "event.belly_dancer":
				return backgroundIconBasePath + "background_64.png";
			case "event.deserter_in_forest":
				return backgroundIconBasePath + "background_07.png";
			case "event.kings_guard_1":
				return backgroundIconBasePath + "background_59.png";
			case "event.thief_caught":
			case "event.runaway_laborers":
				return multipleBrosPossibleIcon;
			case "event.crisis.lindwurm_slayer":
				return backgroundIconBasePath + "background_71.png";
			case "event.cannon_execution":
				return backgroundIconBasePath + "background_11.png";
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
		// if one of the brother events.. get that class background photo..
		// otherwise, use the unknown person icon as a default
	}

	function investigateDateTime()
	{
		local currentTime = this.World.getTime();

		::logInfo("VirtualTimeF: " + this.Time.getVirtualTimeF());
		::logInfo("Seconds Per Day: " + currentTime.SecondsPerDay);
		::logInfo("Seconds Per Hour: " + currentTime.SecondsPerHour);
		::logInfo("Seconds Of Day: " + currentTime.SecondsOfDay);
		::logInfo("Days: " + currentTime.Days);
		::logInfo("Hours: " + currentTime.Hours);
		::logInfo("Minutes: " + currentTime.Minutes);
		::logInfo("Time Of Day: " + currentTime.TimeOfDay);
		::logInfo("Time String: " + this.Const.Strings.World.TimeOfDay[currentTime.TimeOfDay]);

		// local daysCalc = currentTime.Days * 105;
		// local hoursCalc = currentTime.Hours * 4.375;
		// local minutesCalc = currentTime.Minutes * 0.0729166666666667;

		// local mapClock = daysCalc + hoursCalc + minutesCalc;
		// local timeOffset = mapClock - this.Time.getVirtualTimeF();


	}

	function setEventTimeWorldMapTimeOffset()
	{
		local currentTime = this.World.getTime().Time;
		local virtualTime = this.Time.getVirtualTimeF();

		this.m.TimeToAddToMatchWorldClock = currentTime - virtualTime;

		::logInfo("Event Time: " + currentTime);
		::logInfo("Map Time: " + virtualTime);
		::logInfo("Time Diff: " + this.m.TimeToAddToMatchWorldClock);

		// local currentTime = this.World.getTime();
		// local virtualTime = this.Time.getVirtualTimeF();

		// local daysCalc = currentTime.Days * currentTime.SecondsPerDay;
		// local hoursCalc = currentTime.Hours * currentTime.SecondsPerHour;
		// local minutesCalc = currentTime.Minutes * (currentTime.SecondsPerHour / 60);
		// local mapClock = daysCalc + hoursCalc + minutesCalc;
		// local timeOffset = mapClock - virtualTime;

		// ::logInfo("Time " + currentTime.Time); // Float = age (days, hours, minutes) of this world in "BB Seconds"

		// ::logInfo("DaysCalc: " + daysCalc);
		// ::logInfo("HoursCalc: " + hoursCalc);
		// ::logInfo("MinutesCalc: " + minutesCalc);
		// ::logInfo("MapClock: " + mapClock);
		// ::logInfo("Time Diff: " + timeOffset);

		// this.m.GameSaveIsFirstGameAfterGameLaunch = timeOffset >= 105 && timeOffset <= 106;


		// ::logInfo("Game save is first one after game launch: " + this.m.GameSaveIsFirstGameAfterGameLaunch);
		// ::logInfo("Seconds to add to virtual clock to match world clock: " + this.m.TimeToAddToMatchWorldClock)

		// if (timeOffset >= 105 && timeOffset <= 106)
		// {
		// 	::logInfo("This game is the first campaign after loading the game");
		// 	return true;
		// }

		// ::logInfo("This game is the second+ campaign after loading the game");
		// return false;
	}

	function getEventCooldownSecondsInWorldClockTime(event)
	{
		return event.m.CooldownUntil + this.m.TimeToAddToMatchWorldClock;
		//return ((event.m.CooldownUntil + this.m.TimeToAddToMatchWorldClock) / this.m.WorldSecondsPerDay);
		//local firedOn = newCoolDownUntil - (event.m.Cooldown / this.m.WorldSecondsPerDay);

		// pretty sure world starts at 1 day 2 hours while getVirtualTimeF starts at 0. Both progress at 105 seconds per day from what I see..

		// manual calculation of adding getVirtualTimeF + 105 (1 day) + 8.75 (2 hours) wasn't right..
		// BUT it could be a first game of the game launch for 1 day + 10 minutes)
		///		the difference here is about 8 game seconds.

		// will need to calculate once per save load to determine if the save was created first after game launch

		/* CooldownUntil
			93: event.nut > fire() > this.m.CooldownUntil = this.Time.getVirtualTimeF() + this.m.Cooldown;
		*/

		/* this.m.Cooldown
			Every event.nut file > X (whatever number) * this.World.getTime().SecondsPerDay
		*/
		// local coolDownVirtualTimeF = event.m.CooldownUntil - (event.m.Cooldown / this.m.WorldSecondsPerDay);
		// local coolDownVirtualTimeFCorrected = coolDownVirtualTimeF + this.m.TimeToAddToMatchWorldClock;

		// local oldCooldownUntil = (event.m.CooldownUntil / this.m.WorldSecondsPerDay);
		// local oldFiredOn = oldCooldownUntil - (event.m.Cooldown / this.m.WorldSecondsPerDay);



		// local logObj = {
		// 	Name = createHumanReadableEventName(event.getID())
		// 	OldCooldownUntil = oldCooldownUntil,
		// 	OldFiredOn = oldFiredOn,

		// 	//CooldownUntilVirtualTime = coolDownVirtualTimeF,
		// 	//CorrectedCooldownUntilVirtualTime = coolDownVirtualTimeFCorrected,

		// 	NewCooldownUntil = newCoolDownUntil,
		// 	NewFiredOn = newFiredOn
		// }

		/*
		************************************************************
		Event Name: Cow Tipping
		Event Cooldown: 10504082.00
		Event Cooldown Divided: 99999.00

		coolDownVirtualTimeF: 10404083.0
		coolDownVirtualTimeFCorrected: 10404311.00

		Old Cooldown Until: 100038.88
		Old Fired On: 39.88

		New Cooldown Until: 99088.68
		New Fired On: -910.32
		************************************************************

		*/

		// local formatString = "%.2f";

		// ::logInfo("************************************************************");
		// ::logInfo("Event Name: " + createHumanReadableEventName(event.getID()));
		// ::logInfo("Event Cooldown: " + format(formatString, event.m.CooldownUntil));
		// ::logInfo("Event Cooldown Divided: " + format(formatString, event.m.Cooldown / this.m.WorldSecondsPerDay));
		// //::logInfo("coolDownVirtualTimeF: " + format(formatString, coolDownVirtualTimeF));
		// //::logInfo("coolDownVirtualTimeFCorrected: " + format(formatString, coolDownVirtualTimeFCorrected));
		// ::logInfo("Old Cooldown Until: " + format(formatString, oldCooldownUntil));
		// ::logInfo("Old Fired On: " + format(formatString, oldFiredOn));
		// ::logInfo("New Cooldown Until: " + format(formatString, newCoolDownUntil));
		// ::logInfo("New Fired On: " + format(formatString, newFiredOn));
		// ::logInfo("************************************************************");
		// ::logInfo(" " );

		//::MSU.Log.printData(logObj);

		//return newCoolDownUntil;
	}

	function createTimeOfDayDisplay(eventDays)
	{
		if (eventDays >= 9999) {
			return "Day 9999+";
		}

		local formatString = "%.2f";

		local days = this.Math.floor(eventDays);
		local partialDay = eventDays % 1;
		local seconds = partialDay * 105;
		local hours = this.Math.floor(seconds / 4.375);
		local minutes = this.Math.floor(hours / 60);

		local timeDisplay = "Day " + days + " ";

		/// I think I'm close on the days/hours/minutes/seconds part. Then need to sync into TimeOfDay for Vanilla and then for Hardened..

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
		else if (hours == 13 && minutes > 1) {
			timeDisplay += this.Const.Strings.World.TimeOfDay[4]; //Evening
		}
		else {
			timeDisplay += hours.tostring();
		}

		::logInfo("************************************************************");
		::logInfo("Entry days: " + format(formatString, eventDays));
		::logInfo("Partial Day: " + format(formatString, partialDay));
		::logInfo("Days: " + format(formatString, days));
		::logInfo("Seconds: " + format(formatString, seconds));
		::logInfo("Hours: " + format(formatString, hours));
		::logInfo("Minutes: " + format(formatString, minutes));
		::logInfo("Time Display: " + timeDisplay);
		::logInfo("************************************************************");

		return timeDisplay;




		// I'm thinking once I figure out a way to get the world date from the getVirtualTimeF, I can then draw out the numbers into day, hours, minutes to generate a display value

		local currentTime = this.World.getTime();
		local secondsPerDay = currentTime.SecondsPerDay;
		local secondsPerHour = currentTime.SecondsPerHour;
		local secondsPerMinute = secondsPerHour / 60;
		//local secondsRemaining = 0;
		local timeDisplay = "";
		local days = 0;
		local hours = 0;
		local minutes = 0;
		local seconds = 0;
		local formatString = "%.2f";

		::logInfo("************************************************************");
		::logInfo("Entry Seconds: " + eventTimeSeconds);
		//::logInfo("Event Name: " + createHumanReadableEventName(event.getID()));

		if (eventTimeSeconds >= secondsPerDay) {
			days = this.Math.floor(eventTimeSeconds / secondsPerDay);
			eventTimeSeconds = eventTimeSeconds - (days * secondsPerDay);

			::logInfo("# Days: " + days);
			::logInfo("Remaining Seconds: " + eventTimeSeconds);
		}

		if (eventTimeSeconds >= secondsPerHour) {
			hours = this.Math.floor(eventTimeSeconds / secondsPerHour);
			eventTimeSeconds = eventTimeSeconds - (hours * secondsPerHour);

			::logInfo("# Hours: " + hours);
			::logInfo("Remaining Seconds: " + eventTimeSeconds);
		}

		if (eventTimeSeconds >= secondsPerMinute) {
			minutes = this.Math.floor(eventTimeSeconds / secondsPerMinute)
			eventTimeSeconds = eventTimeSeconds - (minutes * secondsPerMinute);

			::logInfo("# Minutes: " + minutes);
			::logInfo("Remaining Seconds: " + eventTimeSeconds);
		}

		if (eventTimeSeconds > 0) {
			::logInfo("# Seconds: " + eventTimeSeconds);
		}

		// is there an opportunity to hook the getDate() class in such a way that I can use it to my benefit here???
		//	I'm thinking using setTime() (if it works) and then calling TimeOfTime for each event.

		timeDisplay = "Day " + days + " ";

		if (hours == 0) {
			timeDisplay += this.Const.Strings.World.TimeOfDay[0]; //" Dawn";
		}
		else if (hours == 1 || (hours == 2 && minutes == 0)) {
			timeDisplay += this.Const.Strings.World.TimeOfDay[1]; //Morning;
		}
		else if ((hours == 2 && minutes > 1) || (hours > 2 && hours <= 8) || (hours == 9 && minutes == 0)) {
			timeDisplay += this.Const.Strings.World.TimeOfDay[2]; //Midday
		}
		else if ((hours == 9 && minutes > 1) || (hours > 9 && hours <= 12 || (hours == 13 && minutes == 0))) {
			timeDisplay += this.Const.Strings.World.TimeOfDay[3]; //Afternoon
		}
		else if (hours == 13 && minutes > 1) {
			timeDisplay += this.Const.Strings.World.TimeOfDay[4]; //Evening
		}

		//Vanilla

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

		//Hardened:

		// ::Const.Strings.World.TimeOfDay <- [
		// 	"Morning",
		// 	"Morning",
		// 	"Morning",
		// 	"Midday",
		// 	"Afternoon",
		// 	"Afternoon",
		// 	"Afternoon",
		// 	"Sunset",
		// 	"Dusk",
		// 	"Midnight",
		// 	"Dawn",
		// 	"Sunrise",
		// ];

		::logInfo("Time Display: " + timeDisplay);

		::logInfo("************************************************************");

		return timeDisplay;
	}

	function processEventsAndStoreValues()
	{
		local eventManager = ::World.Events;

		investigateDateTime();

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

			if (allEvents[i].getScore() == 0 && allEvents[i].m.CooldownUntil > 0 && !allEvents[i].isSpecial()) {
				local coolDownSeconds = getEventCooldownSecondsInWorldClockTime(allEvents[i]);
				local cooldownUntil = coolDownSeconds / this.m.WorldSecondsPerDay;
				local firedOn = cooldownUntil - (allEvents[i].m.Cooldown / this.m.WorldSecondsPerDay);
				// cooldownUntil - (allEvents[i].m.Cooldown / this.World.getTime().SecondsPerDay);

				::logWarning("Event Name: " + createHumanReadableEventName(allEvents[i].getID()));
				::logInfo("Cooldown Seconds: " + coolDownSeconds);
				::logInfo("Event Cooldown Setting: " + allEvents[i].m.Cooldown);
				::logInfo("Cooldown: " + cooldownUntil);
				::logInfo("Fired On: " + firedOn);

				//9999+ cooldown events don't need a clean cooldown day/time. They should just be set to inifinity symbol or something.


				local coolDownDisplay = createTimeOfDayDisplay(cooldownUntil);

				// if (cooldownUntil < 9999) {
				// 	cooldownUntil =
				// }

				local firedOnDisplay = createTimeOfDayDisplay(firedOn);

				// if (cooldownUntil > 9999) {
				// 	cooldownUntil = 9999;
				// }

				this.m.EventsOnCooldown.append({
						id = allEvents[i].getID(),
						name = createHumanReadableEventName(allEvents[i].getID()),
						firedOnNumber = firedOn,
						firedOnDay = firedOnDisplay,
						mayGiveBrother = eventMayGiveBrother(allEvents[i]),
						onCooldownUntilDay = coolDownDisplay,
						onCooldownUntilDayNumber = cooldownUntil,
						icon = getEventIcon(allEvents[i])
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
						id = allEvents[i].getID(),
						name = createHumanReadableEventName(allEvents[i].getID()),
						score = eventScore,
						cooldown = eventCooldown,
						mayGiveBrother = false,
						isBroEvent = eventIsBrotherEvent(allEvents[i]),
						chanceForBrother = getChanceForBrother(allEvents[i]),
						isCrisesEvent = isEventForACrises(allEvents[i]),
						icon = getEventIcon(allEvents[i])
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
};

