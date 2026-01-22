::EventManagerInfo <- {
	ID = "mod_event_manager_info",
	Name = "Event Manager Info",
	Version = "0.9.4"
}

/*
	To do
	1. Top buttons need to stay selected
	2. Make filter work
	3. Mark events as bro events in some way
	4. Adjust section borders maybe
	5. Add logic to filter out non-valid bro events
	6. Investigate more readable day numbers (especially with rounding!)
	7. Add checkbox to highlight or show only bro events in both queue and cooldown
	8. Add logic to process events in the cooldown list

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

	::EventManagerInfo.DisplayEventsInUI <- function()
	{
		::EventManagerInfo.EventScreen.show();
	}

	::include("event_manager/file_loading");

	::Hooks.registerJS("ui/mods/event_manager/event_manager_screen.js");
	::Hooks.registerCSS("ui/mods/event_manager/event_manager_screen.css");

	::EventManagerInfo.EventScreen <- ::new("scripts/ui/screens/event_manager_screen");
	//::EventManagerInfo.JSConnection <- ::new("event_manager/event_manager_js_connection");

	//::MSU.UI.registerConnection(::EventManagerInfo.JSConnection);
	::MSU.UI.registerConnection(::EventManagerInfo.EventScreen);
	//::MSU.UI.addOnConnectCallback(::EventManagerInfo.JSConnection.finalize.bindenv(::EventManagerInfo.JSConnection));
});