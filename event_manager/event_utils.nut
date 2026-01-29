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
		}
	},

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
		local chance = 100;
		local currentEventId = event.getID();

		switch (currentEventId) {
			case "event.runaway_laborers":
				return 70;
			case "event.thief_caught":
				return 75;
		}

		return chance;
	}

	function isEventForACrises(event)
	{
		local eventId = event.getID();
		return eventId.find("event.crisis.") != null;
	}

	function getEventIcon(event)
	{
		//local iconPath = 'gfx/ui/icons/unknown_traits.png';

		local currentEventId = event.getID();
		local multipleBrosPossibleIcon = "ui/icons/round_information/brothers_icon_old.png";
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
			case "event.runaway_laborers":
				return backgroundIconBasePath + multipleBrosPossibleIcon;
			case "event.crisis.lindwurm_slayer":
				return backgroundIconBasePath + "background_71.png";
			case "event.thief_caught":
				return backgroundIconBasePath + multipleBrosPossibleIcon;
			case "event.cannon_execution":
				return backgroundIconBasePath + "background_11.png";
			case "event.melon_thief":
				return backgroundIconBasePath + "background_11.png";
			case "event.the_horseman":
				return backgroundIconBasePath + "background_32.png";
			case "event.desert_well":
				return backgroundIconBasePath + "background_19.png";
		}

		return "ui/icons/unknown_traits.png";
		// if one of the brother events.. get that class background photo..
		// otherwise, use the unknown person icon as a default
	}

	function processEventsAndStoreValues()
	{
		local eventManager = ::World.Events;

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

				this.m.EventsOnCooldown.append({
						id = allEvents[i].getID(),
						name = createHumanReadableEventName(allEvents[i].getID()),
						firedOnDay = firedOn,
						mayGiveBrother = eventMayGiveBrother(allEvents[i]),
						onCooldownUntilDay = ::MSU.Math.roundToDec( cooldownUntil, 4 )
					});
			}

			if (allEvents[i].getScore() > 0)
			{
				this.m.AllScores += eventScore;

				local eventToAdd = {
						id = allEvents[i].getID(),
						name = createHumanReadableEventName(allEvents[i].getID()),
						score = eventScore,
						cooldown = eventCooldown,
						mayGiveBrother = false,
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

