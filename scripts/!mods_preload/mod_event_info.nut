::EventInfo <- {
	ID = "mod_event_info",
	Name = "Event Info",
	Version = "0.9.8",
	GitHubUrl = "https://github.com/metawrecker/event_info"
}

/*
	(0.9.8)
	##Major Changes / New Features
	* Changed name of the mod and git repo to event_info, away from event_manager_info.
	* Change decimal display values of On Cooldown events to "Day - TimeOfDay" format in a way that matches the world clock.

	##UI Changes
	* Changed font color in most of the UI to not be the bright yellow title font.
	* Events that may reward a bro are now assigned the shiny bright yellow font. Gone is the green font.
	* Adjusted summary text from "Chance for a brother" to "Chance for a brother event to fire".
	* Expanded the tooltip that appears when hovering over the "Chance for a brother event to fire" text showing the actual chance for an event plus the real chance to score a new brother.
	* Removed all decimal places from the UI except for the chance for an event bro event.

	##Bug Fixes
	* Fixed issue where some events would display many decimal places.
	* Fixed issue where the "On Cooldown" events had incorrect values for Fired On Day and Available On Day.
	* Added Blighted Guy 1 event to the list of bro events that have a partial success chance to reward a bro when the event fires.
	* Fixed issue where crises events were always obscured, regardless of MSU Setting.
	* Fixed issue where some bro events that include the word 'crises' were being obfuscated.



	Something interesting that I've discovered while working on the event manager mod days / time of day. There are two clocks running behind the scenes. A virtual clock that is tied to things like events. A world map clock that is visual to the player. These two clocks grow further apart over time.

	todo
	. Add logic to process events in the cooldown list
	. Create tooltips
	. Fix issue where the filter box arrests attention away from the keybinds

*/

local requiredMods = [
	"vanilla >= 1.5.1-6",
	"mod_msu >= 1.3.0",
	"mod_modern_hooks >= 0.4.10"
];

local modLoadOrder = [];
foreach (mod in requiredMods) {
	local idx = mod.find(" ");
	modLoadOrder.push(">" + (idx == null ? mod : mod.slice(0, idx)));
}

::EventInfo.HooksMod <- ::Hooks.register(::EventInfo.ID, ::EventInfo.Version, ::EventInfo.Name);
::EventInfo.HooksMod.require(requiredMods);

::EventInfo.HooksMod.queue(modLoadOrder, function() {
 	local mod = ::MSU.Class.Mod(::EventInfo.ID, ::EventInfo.Version, ::EventInfo.Name);
	::EventInfo.Mod <- mod;

	::EventInfo.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, ::EventInfo.GitHubUrl);
	::EventInfo.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);

	::Hooks.registerJS("ui/mods/event_info/event_info_screen.js");
	::Hooks.registerCSS("ui/mods/event_info/event_info_screen.css");

	::EventInfo.EventScreen <- ::new("scripts/ui/screens/event_info_screen");
	::MSU.UI.registerConnection(::EventInfo.EventScreen);

	::include("event_info/file_loading");

	::EventInfo.HideUI <- function()
	{
		::EventInfo.EventScreen.hide();
	}
});