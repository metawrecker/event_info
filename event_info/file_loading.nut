foreach (file in ::IO.enumerateFiles("event_info/msu_utils"))
{
	::include(file);
}

foreach (file in ::IO.enumerateFiles("event_info/utils"))
{
	::include(file);
}

// ::include("event_info/event_utils");
// ::include("event_info/keybinds");
// ::include("event_info/news_utils");
// ::include("event_info/settings");
// ::include("event_info/tile_utils");
// ::include("event_info/tooltips");
// ::include("event_info/tooltip_utils");