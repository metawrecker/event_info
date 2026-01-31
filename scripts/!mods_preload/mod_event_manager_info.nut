::EventManagerInfo <- {
	ID = "mod_event_manager_info",
	Name = "Event Manager Info",
	Version = "0.9.6",
	GitHubUrl = "https://github.com/metawrecker/event_manager_info"
}

/*
	(0.9.6)
	. Reset form on hide()
	. Fix defaulting to hiding 9999 cooldown events not working
	. Fix show() and hide() not resetting the UI back to first state
	. Add MSU settings to connect to checkboxes
	. Fix Checkboxes not resetting correctly on form hide(). They stay check/non-check but the grid does not update respective to them.
	. Add icon to events on the Event Pool page
	. Implement vanilla 'dialog screen' UI
	. Fix issue where only bro events that qualify appear in the filtered bro event list
	. Fix grid header and content alignment (somewhat.. it's still not perfect)
	. Fix Crises events appearing. Instead, obfuscate the crises event text and call it something generic "crises event". Add checkbox and MSU setting to default behavior of displaying or hiding by default
	. Make world map auto pause when showing UI
	. Disable any world map interactions when showing UI
	. Enabled ability to close the UI using same keybind used to open it
	.	This only works when NOT focusing on the filter box

	todo
	. Investigate more readable day numbers (especially with rounding!)
	. Add logic to process events in the cooldown list
	. Make event_utils more efficient by not calling getID() over and over..
	. Create tooltips
	. Icon on cooldown page??
	. Fix cooldown page grid UI
	. Add dog icon to dog events
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