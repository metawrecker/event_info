local generalPage = ::EventManagerInfo.Mod.ModSettings.addPage("Page", "General");
local defaultToOnlyShowBroEvents = generalPage.addBooleanSetting("DefaultOnlyShowBroEvents", true, "Default to only show bro events");
local defaultToHide9999CooldownEvents = generalPage.addBooleanSetting("DefaultHide9999Events", true, "Default to hide 9999+ day cooldown events");
