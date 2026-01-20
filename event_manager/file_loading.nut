foreach (file in ::IO.enumerateFiles("event_manager/hooks"))
{
	::include(file);
}

::include("event_manager/event_manager_js_connection");
::include("event_manager/event_utils");
::include("event_manager/keybinds");