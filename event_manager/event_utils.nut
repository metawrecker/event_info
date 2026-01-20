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
		}
	},

	function eventMayGiveBrother(currentEventId)
	{
		foreach ( key, eventId in this.m.BroHireEventIds)
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

	function createHumanReadableEventName(eventId)
	{
		local readableName = "";
		local tempName = "No name";

		if (eventId == "")
			return tempName;

		if (eventId.find("event.") != null) {
			tempName = eventId.slice(6);
		}

		local words = split(tempName, "_");

		foreach(index, word in words) {
			local firstCharacter = word.slice(0, 1);
			local otherCharacters = word.slice(1);

			readableName += firstCharacter.toupper() + otherCharacters + " ";
		}

		strip(readableName);

		return readableName;
	}

	function processEventsAndStoreValues()
	{
		//::logWarning("Now preparing events values");

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
						mayGiveBrother = eventMayGiveBrother(allEvents[i].getID()),
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
						mayGiveBrother = false
					};

				if (eventMayGiveBrother(allEvents[i].getID())) {
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

		// ::logWarning("Completed processing events");
		// ::MSU.Log.printData(this.m);
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

