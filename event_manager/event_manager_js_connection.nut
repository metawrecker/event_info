this.event_manager_js_connection <- ::inherit("scripts/mods/msu/js_connection", {
	m = {
		ID = "EventManagerJSConnection"
	}

	function connect()
	{
		this.m.JSHandle = this.UI.connect(this.m.ID, this);
	}

	function finalize()
	{
		this.m.JSHandle.asyncCall("finalize", null);
		return true;
	}
});