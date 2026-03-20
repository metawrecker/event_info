::EventInfo <- {
	ID = "mod_event_info",
	Name = "Event Info",
	Version = "0.9.10",
	GitHubUrl = "https://github.com/metawrecker/event_info",
	NexusUrl = "https://www.nexusmods.com/battlebrothers/mods/963"
}

/*
	(0.9.10)
	#Major Changes / New Features
	*

	#UI Changes
	*

	#Bug Fixes
	* Fixed issue where closing the UI by pressing the Escape key would auto open the game menu

	#Vanilla Fixes

	todo
	* Add logic to process events in the cooldown list
	* Create tooltips
	* Fix issue where the filter box arrests attention away from the keybinds
	* Create event library
	* Fix issue where the "Last Event on Day" is not including the world time offset
	* Refactor HTML/JS
	* Update % chance display in this mod based on mod_guaranteed_event_bros??

	* Implement the version number into mod settings or something so I'm not updating two places each new version

	not doing
	* Fix issue where news appears in the event pool and adds to the event score and bro event %. I think I like displaying the news still but it needs to not factor into the score
	* Add Score to On Cooldown page (Score is set to 0 on all events when they go to Cooldown)
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

	::EventInfo.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.NexusMods, ::EventInfo.NexusUrl);
	::EventInfo.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, ::EventInfo.GitHubUrl);
	::EventInfo.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);

	::Hooks.registerJS("ui/mods/event_info/event_info_screen.js");
	::Hooks.registerCSS("ui/mods/event_info/event_info_screen.css");

	::EventInfo.EventScreen <- ::new("scripts/ui/screens/event_info_screen");
	::MSU.UI.registerConnection(::EventInfo.EventScreen);

	::include("event_info/file_loading");
});