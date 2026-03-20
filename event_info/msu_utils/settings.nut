local generalPage = ::EventInfo.Mod.ModSettings.addPage("Page", "General");

generalPage.addTitle("eventPoolTitle", "Event Pool Settings");
generalPage.addDivider("eventPoolDivider");

local defaultToOnlyShowBroEvents = generalPage.addBooleanSetting("DefaultOnlyShowBroEvents", false, "Default to only show bro events");
local obscureCrisesEvents = generalPage.addBooleanSetting("ObscureCrisesEvents", true, "Obscure Crises event text");

generalPage.addTitle("eventCooldownTitle", "Events on Cooldown Settings");
generalPage.addDivider("eventCooldownDivider");
local defaultToHide9999CooldownEvents = generalPage.addBooleanSetting("DefaultHide9999Events", true, "Default to hide 9999+ day cooldown events");

