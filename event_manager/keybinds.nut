::EventManagerInfo.Mod.Keybinds.addSQKeybind("PrintEvents", "ctrl+e", ::MSU.Key.State.World, function() {
	//::EventManagerInfo.PrintEventsToLog(true, true);
	::EventManagerInfo.DisplayEventsInUI();
}, "View Events", ::MSU.Key.KeyState.Press);