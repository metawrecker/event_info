::EventManagerInfo <- {
	ID = "mod_event_manager_logging",
	Name = "EventManagerInfo",
	Version = "1.0.0"
}
::mods_registerMod(::EventManagerInfo.ID, ::EventManagerInfo.Version, ::EventManagerInfo.Name);

//::EventManagerInfo.HookMod <- ::Hooks.register(::EventManagerInfo.ID, ::EventManagerInfo.Version, ::EventManagerInfo.Name);

::mods_queue(::EventManagerInfo.ID, null, function()
{
	::EventManagerInfo.Mod <- ::MSU.Class.Mod(::EventManagerInfo.ID, ::EventManagerInfo.Version, ::EventManagerInfo.Name);

	local printEventsToLog = function()
	{
		::logWarning("Hello world!");

		local test = new("scripts/events/event_manager");

		::MSU.Log.printData(test.m.Events);
	}

	::EventManagerInfo.Mod.Keybinds.addSQKeybind("PrintEvents", "ctrl+e", ::MSU.Key.State.World, function() {
		printEventsToLog();
	}, "Print events", ::MSU.Key.KeyState.Press);
	// enable later when JS and or CSS files are needed
	// ::mods_registerJS("./mods/EventManagerInfo/index.js");
	// ::mods_registerCSS("./mods/EventManagerInfo/index.css");
})