// ::EventManagerInfo.Mod.Keybinds.addSQKeybind("PrintEvents", "ctrl+e", ::MSU.Key.State.World, function() {
// 	::EventManagerInfo.DisplayUI();
// }, "View Event Manager UI", ::MSU.Key.KeyState.Press).setBypassInputDenied(true);

::EventManagerInfo.Mod.Keybinds.addSQKeybind("CloseScreen", "escape", ::MSU.Key.State.World, function() {
	::EventManagerInfo.HideUI();
}, "Close Screen", ::MSU.Key.KeyState.Press).setBypassInputDenied(true);

::EventManagerInfo.Mod.Keybinds.addSQKeybind("toggleDisplayUIScreen", "ctrl+e", ::MSU.Key.State.World, ::EventManagerInfo.EventScreen.toggle.bindenv(::EventManagerInfo.EventScreen), "Open/Close Event Manager UI");