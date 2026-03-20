::EventInfo.TooltipUtil <- {
	function getTooltipForCharacterBackground(eventId, backgroundName)
	{
		if (backgroundName == "generate-bro-list") {
			local ret = [];
			local backgrounds = [];

			ret.append({
				id = 1,
				type = "title",
				text = "One of the below backgrounds"
			});

			switch (eventId)
			{
				case "event.runaway_laborers":
					backgrounds.extend(this.Const.CharacterLaborerBackgrounds);
					break;
				case "event.thief_caught":
					backgrounds.extend(this.Const.CharacterThiefBackgrounds);
					break;
				case "event.volunteers":
					backgrounds.extend(["bastard_background",
									"caravan_hand_background",
									"deserter_background",
									"houndmaster_background",
									"killer_on_the_run_background",
									"gambler_background",
									"graverobber_background",
									"poacher_background",
									"thief_background",
									"butcher_background",
									"gravedigger_background",
									"mason_background",
									"miller_background",
									"miner_background",
									"peddler_background",
									"ratcatcher_background",
									"shepherd_background",
									"tailor_background"
								]);
					break;
			}

			backgrounds.sort();

			foreach (i, bkgrndName in backgrounds) {
				local path = "scripts/skills/backgrounds/" + bkgrndName;
				local characterBackground = ::new(path);

				if (characterBackground == null) {
					continue;
				}

				//local iconPath = "gfx/" + characterBackground.getIcon();
				local name = characterBackground.getName();

				if (name.find("Background:") != null) {
					name = name.slice(12);
				}

				ret.append({
					id = 2 + i,
					type = "text",
					icon = characterBackground.getIcon(),
					text = name //"[img width='30' height='30']" + iconPath + "[/img] " + name
				});
			}

			return ret;
		}
		else
		{
			local filePath = "scripts/skills/backgrounds/" + backgroundName + "_background";
			local background = ::new(filePath);

			if (background == null) {
				return "";
			}

			return background.getTooltip();
		}
	}
};