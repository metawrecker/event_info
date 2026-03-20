::EventInfo.TooltipIdentifiers <- {
	Form = {
		EventBroChance = ::MSU.Class.BasicTooltip("Chance For An Event Brother Event", function () {
			local tooltipText = "This number is a sum of all the event brother events that you can unlock right now (highlighted in yellow/gold) divided by the entire event pool."
			local eventBros = ::EventInfo.Events.getBroHiringEventsInQueue();
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

			local sumOfAllEvents = ::EventInfo.Events.getAllEventScore();

			if (sumOfAllEvents <= 0) {
				sumOfAllEvents = 1;
			}

			local chanceForABro = actualScore / (sumOfAllEvents * 1.0) * 100.0;

			if (chanceForABro != ::EventInfo.Events.getEventBroHiringScore()) {
				tooltipText = tooltipText + "\n\n" + "Chance for a new brother is: " + ::MSU.Math.roundToDec(chanceForABro, 2) + "%"
					+ " (" + actualScore + " / " + sumOfAllEvents + ")";
			}

			return tooltipText;
		}),
	},
	EventPool = {
		IconTooltip = ::MSU.Class.CustomTooltip(function(_data) {
			if (_data == null || _data == "" || _data.background == "") {
				::logError("EventInfo.IconTooltip expected a character background name but received nothing");
				return;
			}

			if (_data.background == "NA") {
				local ret = [];

				ret.append({
					id = 1,
					type = "title",
					text = "Non-bro Event"
				});
				ret.append({
					id = 2,
					type = "description",
					text = "One of the many events that doesn't reward a brother."
				});

				return ret;
			}

			local tooltip = ::EventInfo.TooltipUtil.getTooltipForCharacterBackground(_data.eventId, _data.background);

			// ::logInfo("Data received from getTooltipForCharacterBackground");

			// foreach (value in tooltip) {
			// 	::MSU.Log.printData(value);
			// }

			return tooltip;
		}),
	},
	EventCooldown = {

	},
	EventInfo = {
		NewsList = ::MSU.Class.BasicTooltip("News Currently Queued", function() {
			local tooltipText = ""
			local newsList = ::EventInfo.News.getNews();

			if (newsList.len() == 0) {
				tooltipText = "No news";
			}
			else {
				tooltipText = "News queued up:";
				tooltipText += "\n";

				foreach (i, news in newsList) {
					tooltipText += "\n";
					tooltipText += news.name
				};
			}

			return tooltipText;
		}),
	}
}

::EventInfo.Mod.Tooltips.setTooltips(::EventInfo.TooltipIdentifiers);