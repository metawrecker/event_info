::EventManagerInfo.TooltipIdentifiers <- {
	Form = {
		//EventBroChance = ::MSU.Class.BasicTooltip("Event Bro Chance", "This number is a sum of all the event bros you can actually unlock right now (highlighted in green) divided by the entire event pool."),
		EventBroChance = ::MSU.Class.BasicTooltip("Event Bro Chance", function () {
			local baseText = "This number is a sum of all the event bros you can actually unlock right now (highlighted in gold) divided by the entire event pool.";
			local eventBros = ::EventManagerInfo.Events.getBroHiringEventsInQueue();
			local actualScore = 0;

			if (eventBros.len() == 0) {
				return baseText;
			}

			baseText = baseText + "\n"

			foreach (i, event in eventBros) {
				if (event.mayGiveBrother == true) {
					local eventChance = event.score;

					if (event.chanceForBrother < 100) {
						eventChance = eventChance * event.chanceForBrother / 100;
					}

					actualScore += eventChance;

					baseText = baseText + "\n" + ::MSU.Text.colorPositive(strip(event.name)) + " " + ::MSU.Text.colorPositive(eventChance);
				}
			}

			local sumOfAllEvents = ::EventManagerInfo.Events.getAllEventScore();

			if (sumOfAllEvents <= 0) {
				sumOfAllEvents = 1;
			}

			local chanceForABro = actualScore / sumOfAllEvents * 100.0;

			if (chanceForABro != ::EventManagerInfo.Events.getEventBroHiringScore()) {
				baseText = baseText + "\n\n" + "Chance for a new bro is: " + ::MSU.Text.colorPositive(::MSU.Math.roundToDec(chanceForABro, 2)) + ::MSU.Text.colorPositive("%");
			}

			return baseText;
		}),
	},
	EventPool = {

	},
	EventCooldown = {

	}
}

::EventManagerInfo.Mod.Tooltips.setTooltips(::EventManagerInfo.TooltipIdentifiers);