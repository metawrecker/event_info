::EventManagerInfo.TooltipIdentifiers <- {
	Form = {
		EventBroChance = ::MSU.Class.BasicTooltip("Chance For An Event Brother Event", function () {
			local tooltipText = "This number is a sum of all the event brother events that you can unlock right now (highlighted in yellow/gold) divided by the entire event pool."
			local eventBros = ::EventManagerInfo.Events.getBroHiringEventsInQueue();
			local actualScore = 0;

			if (eventBros.len() == 0) {
				return tooltipText;
			}

			tooltipText = tooltipText + "\n\n"
				+ "Below you will find the chance to get a brother from an event right now.";

			tooltipText = tooltipText + "\n"

			foreach (i, event in eventBros) {
				if (event.mayGiveBrother == true) {
					local eventChance = event.score;

					if (event.chanceForBrother < 100) {
						eventChance = eventChance * event.chanceForBrother / 100.0;
					}

					actualScore += eventChance;

					local eventChanceText = "";

					if (event.score > eventChance) {
						eventChanceText = " (" + ::MSU.Text.colorNegative(event.chanceForBrother + "% - " + ::MSU.Math.roundToDec(eventChance, 2)) + ")";
					}

					tooltipText = tooltipText + "\n" + strip(event.name) + ": " + event.score + eventChanceText;
				}
			}

			local sumOfAllEvents = ::EventManagerInfo.Events.getAllEventScore();

			if (sumOfAllEvents <= 0) {
				sumOfAllEvents = 1;
			}

			local chanceForABro = actualScore / (sumOfAllEvents * 1.0) * 100.0;

			if (chanceForABro != ::EventManagerInfo.Events.getEventBroHiringScore()) {
				tooltipText = tooltipText + "\n\n" + "Chance for a new brother is: " + ::MSU.Math.roundToDec(chanceForABro, 2) + "%"
					+ " (" + actualScore + " / " + sumOfAllEvents + ")";
			}

			return tooltipText;
		}),
	},
	EventPool = {

	},
	EventCooldown = {

	}
}

::EventManagerInfo.Mod.Tooltips.setTooltips(::EventManagerInfo.TooltipIdentifiers);