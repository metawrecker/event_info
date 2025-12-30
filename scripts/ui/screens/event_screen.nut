this.event_screen <- ::inherit("scripts/mods/msu/ui_screen", {
	m = {
		ID = "EventScreen",
		IsFirstLoad = true,
	},

	function create()
	{
	}

	function getUIData()
	{
		local ret = [];

		ret.append({
			id = "test.event1",
			score = 10,
			cooldown = 60
		});

		return ret;
	}

	function show()
	{
		if (this.m.IsFirstLoad) {
			this.ui_screen.show(this.getUIData());
			this.m.IsFirstLoad = false;
		}
		else {
			this.ui_screen.show(null);
		}
	}
})
