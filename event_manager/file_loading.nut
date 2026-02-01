foreach (file in ::IO.enumerateFiles("event_manager/hooks"))
{
	::include(file);
}

::include("event_manager/event_utils");
::include("event_manager/keybinds");
::include("event_manager/settings");
::include("event_manager/toolips");