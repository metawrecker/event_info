::EventManagerInfo <- {
	ID = "mod_event_manager_info",
	Name = "Event Info",
	Version = "0.9.8",
	GitHubUrl = "https://github.com/metawrecker/event_manager_info"
}

/*
	(0.9.8)
	* Changed font color in most of the UI to not be the bright yellow title font.
	* Events that may reward a bro are assigned the shiny bright yellow font. Gone is the green font.
	* Fixed issue where some events would display many decimal places.
	* Adjusted summary text from "Chance for a brother" to "Chance for a brother event to fire".
	* Expanded the tooltip that appears when hovering over the "Chance for a brother event to fire" text showing the actual chance for an event plus the real chance to score a new brother.


	todo
	. Investigate more readable day numbers (especially with rounding!)
	. Add logic to process events in the cooldown list
	. Create tooltips
	. Fix issue where the filter box arrests attention away from the keybinds
	. Come up with a new way to highlight that a bro event can give a bro.
	. Fix events that have wildly long score -- cap visual to 2 decimals (occurred on Beast Slayers 1 save)

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

::EventManagerInfo.HooksMod <- ::Hooks.register(::EventManagerInfo.ID, ::EventManagerInfo.Version, ::EventManagerInfo.Name);
::EventManagerInfo.HooksMod.require(requiredMods);

::EventManagerInfo.HooksMod.queue(modLoadOrder, function() {
 	local mod = ::MSU.Class.Mod(::EventManagerInfo.ID, ::EventManagerInfo.Version, ::EventManagerInfo.Name);
	::EventManagerInfo.Mod <- mod;

	::EventManagerInfo.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, ::EventManagerInfo.GitHubUrl);
	::EventManagerInfo.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);

	::Hooks.registerJS("ui/mods/event_manager/event_manager_screen.js");
	::Hooks.registerCSS("ui/mods/event_manager/event_manager_screen.css");

	::EventManagerInfo.EventScreen <- ::new("scripts/ui/screens/event_manager_screen");
	::MSU.UI.registerConnection(::EventManagerInfo.EventScreen);

	::include("event_manager/file_loading");

	::EventManagerInfo.HideUI <- function()
	{
		::EventManagerInfo.EventScreen.hide();
	}
});