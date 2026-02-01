::EventManagerInfo.TooltipIdentifiers <- {
	Form = {
		EventBroChance = ::MSU.Class.BasicTooltip("Event Bro Chance", "This number is a sum of all the event bros you can actually unlock right now (highlighted in green) divided by the entire event pool."),
	},
	EventPool = {

	},
	EventCooldown = {

	}
}

::EventManagerInfo.Mod.Tooltips.setTooltips(::EventManagerInfo.TooltipIdentifiers);