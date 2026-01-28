"use strict";
var EventManagerScreen = function (_parent)
{
	MSUUIScreen.call(this);
	this.mContainer = null;
	this.mEventPoolHeaderContent = null;
	this.mEventPoolContainer = null;
	this.mEventPoolScrollContainer = null;
	this.mEventPoolMessage = null;
	this.mEventCooldownHeaderContent = null;
	this.mEventCooldownContainer = null;
	this.mEventCooldownScrollContainer = null;
	this.mEventCooldownMessage = null;
	this.mEventData = null;
	this.mNameFilterInput = null;
	this.mHideNonBroEventsCheckbox = null;
	this.mHide9999CooldownEventsCheckbox = null;

	//
	this.mVisibleContainer = null;
	this.mEventFilter = "";
	//
	this.mID = "EventManagerScreen";
};

/*
	{
		BroHireEventsInPool = [{
			id = "",
			name = "",
			score = 0,
			cooldown = 0,
			mayGiveBrother = true,
			chanceForBrother = 0,
			isCrisesEvent = false
		}],
		NonBroHireEventsInPool = [{
			id = "",
			name = "",
			score = 0,
			cooldown = 0,
			mayGiveBrother = false,
			chanceForBrother = 0,
			isCrisesEvent = false
		}],
		EventsOnCooldown = [{
			id = "",
			name = "",
			onCooldownUntilDay = 0,
			firedOnDay = 0
			mayGiveBrother = false
		}],
		AllScores = 0,
		NonEventBroHireScore = 0,
		EventBroHireScore = 0
	};
*/

EventManagerScreen.prototype = Object.create(MSUUIScreen.prototype);
Object.defineProperty(EventManagerScreen.prototype, 'constructor', {
	value: EventManagerScreen,
	enumerable: false,
	writable: true
});

///
/// Begin form functions
///
EventManagerScreen.prototype.create = function(_parentDiv)
{
	this.createDIV(_parentDiv);
	//this.bindTooltips();
};

EventManagerScreen.prototype.show = function (_data)
{
	if (_data != null) {
		this.mEventData = _data;

		this.populateSummary(_data);
		this.populateEventsContainer(_data);
		this.populateEventCooldownContainer(_data);
	}

	var self = this;
	var moveTo = { opacity: 1 };
	
	this.mContainer.velocity("finish", true).velocity(moveTo,
	{
		duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
		easing: 'swing',
		begin: function ()
		{
			$(this).show();
			$(this).css("opacity", 0);
			self.notifyBackendOnAnimating();
		},
		complete: function ()
		{
			self.mIsVisible = true;
			//self.mNameFilterInput.focus();
			self.notifyBackendOnShown();
		}
	});
	this.onShow();
};

EventManagerScreen.prototype.hide = function ()
{
	var self = this;
	var moveTo = { opacity: 0 };

	this.mContainer.velocity("finish", true).velocity(moveTo,
	{
		duration: Constants.SCREEN_FADE_IN_OUT_DELAY,
		easing: 'swing',
		begin: function()
		{
			self.switchToEventsInPoolPanel();
			self.notifyBackendOnAnimating();
		},
		complete: function()
		{
			$(this).hide();
			self.notifyBackendOnHidden();
		}
	});
	this.onHide();
};

EventManagerScreen.prototype.onConnection = function (_handle, _parentDiv)
{
	_parentDiv = _parentDiv || $('.root-screen');
    this.mSQHandle = _handle;
    this.register(_parentDiv);
};

EventManagerScreen.prototype.onDisconnection = function ()
{
    this.mSQHandle = null;
    this.unregister();
};

EventManagerScreen.prototype.destroyDIV = function ()
{
	this.mHideNonBroEventsCheckbox = null;
	this.mHide9999CooldownEventsCheckbox = null;
	this.mNameFilterInput = null;
	this.mEventData = null;
	this.mEventPoolMessage = null;
	this.mEventCooldownMessage = null;

	this.mEventPoolHeaderContent.empty();
	this.mEventPoolHeaderContent.remove();
	this.mEventPoolHeaderContent = null;

	this.mEventPoolContainer.empty();
	this.mEventPoolContainer.remove();
	this.mEventPoolContainer = null;

	this.mEventPoolScrollContainer.empty(); 
	this.mEventPoolScrollContainer.remove(); 
	this.mEventPoolScrollContainer = null;

	this.mEventCooldownHeaderContent.empty();
	this.mEventCooldownHeaderContent.remove();
	this.mEventCooldownHeaderContent = null;

	this.mEventCooldownContainer.empty();
	this.mEventCooldownContainer.remove();
	this.mEventCooldownContainer = null;

	this.mEventCooldownScrollContainer.empty();
	this.mEventCooldownScrollContainer.remove();
	this.mEventCooldownScrollContainer = null;

	this.mContainer.empty();
	this.mContainer.remove();
	this.mContainer = null;
};

EventManagerScreen.prototype.onShow = function()
{
};

EventManagerScreen.prototype.onHide = function()
{
};

EventManagerScreen.prototype.destroy = function()
{
	//this.unbindTooltips();
	this.destroyDIV();
};
///
/// End form functions
///

///
/// Begin creation of HTML elements
///
EventManagerScreen.prototype.createDIV = function (_parentDiv)
{
	this.mContainer = $("<div class='emi-screen'/>")
		.appendTo(_parentDiv)
		.hide();
	
	this.createHeader();
	this.createButtonBar();
	this.createTableHeaderSpaceForEventPoolContainer();
	this.createTableHeaderSpaceForEventCooldownContainer();
	this.createEventPoolContainer();
	this.createEventCooldownContainer();
	this.createFilterBar();
	this.createFooter();
};

EventManagerScreen.prototype.createHeader = function ()
{
	$('<div id="emi-header" class="emi-title title-font-big font-bold font-color-title">Event Manager Info Beta (v0.9.5)</div>')
		.appendTo(this.mContainer);
}

EventManagerScreen.prototype.createButtonBar = function () 
{
	var self = this
	this.mPageTabContainer = $('<div class="emi-header-button-bar"/>');
	this.mContainer.append(this.mPageTabContainer);

	var eventPoolButton = this.createCustomEmiHeaderButton("Available Events", function(_button) {
		self.switchToEventsInPoolPanel();
	}, 'emi-header-button');

	var eventCooldownButton = this.createCustomEmiHeaderButton("Events on Cooldown", function(_button) {
		self.switchToEventsOnCooldownPanel();
	}, 'emi-header-button');

	eventPoolButton.addClass('is-active');

	eventPoolButton.attr("id", "emi-event-pool-button");
	eventCooldownButton.attr("id", "emi-event-cooldown-button");

	this.mPageTabContainer.append(eventPoolButton);
	this.mPageTabContainer.append(eventCooldownButton);
}

EventManagerScreen.prototype.createTableHeaderSpaceForEventPoolContainer = function ()
{
	var self = this;
	this.mEventPoolHeaderContent = $('<div id="emi-event-pool-header-content" class="emi-content-header"/>')
		.appendTo(this.mContainer);

	var summaryContent = $('<div class="emi-event-summary"/>');
	this.mEventPoolHeaderContent.append(summaryContent);

	var chanceForABro = $('<span id="emi-chance-for-a-brother" class="emi-event-summary-content title-font-normal font-color-brother-name">Chance for a brother event ' + 0 + '</span>');
	summaryContent.append(chanceForABro);
	
	this.mHideNonBroEventsCheckbox = $('<input type="checkbox" class="emi-checkbox" id="emi-hide-non-bro-events"/>');
	summaryContent.append(this.mHideNonBroEventsCheckbox);

    var checkboxLabel = $('<label class="emi-checkbox-label title-font-small font-bold font-color-brother-name" for="emi-hide-non-bro-events">Hide non-bro events</label>');

	summaryContent.append(checkboxLabel);

	this.mHideNonBroEventsCheckbox.iCheck({
		checkboxClass: 'icheckbox_flat-orange',
		radioClass: 'iradio_flat-orange',
		increaseArea: '30%'
	});

	this.mHideNonBroEventsCheckbox.on('ifChecked ifUnchecked', null, this, function (_event) {
		self.toggleShowingNormalEventsInPool(self.mHideNonBroEventsCheckbox.prop('checked') === true);
	});

	var tableHeader = $('<div class="emi-table-header"/>');
	this.mEventPoolHeaderContent.append(tableHeader);

	tableHeader
		.append($("<div class='emi-event-item-name title-font-big font-bold font-color-brother-name'>Event Name</div>"))
		.append($("<div class='emi-event-item-score title-font-big font-bold font-color-brother-name'>Score</div>"));
}

EventManagerScreen.prototype.createTableHeaderSpaceForEventCooldownContainer = function ()
{
	var self = this;
	this.mEventCooldownHeaderContent = $('<div id="emi-event-cooldown-header-content" class="emi-content-header"/>')
		.appendTo(this.mContainer)
		.hide();

	var summaryContent = $('<div class="emi-event-summary"/>');
	this.mEventCooldownHeaderContent.append(summaryContent);

	this.mHide9999CooldownEventsCheckbox = $('<input type="checkbox" class="emi-checkbox" id="emi-hide-9999-events"/>');
	summaryContent.append(this.mHide9999CooldownEventsCheckbox);

    var checkboxLabel = $('<label class="emi-checkbox-label title-font-small font-bold font-color-brother-name" for="emi-hide-9999-events">Hide 9999 day cooldown events</label>');
   
	summaryContent.append(checkboxLabel);

	this.mHide9999CooldownEventsCheckbox.iCheck({
		checkboxClass: 'icheckbox_flat-orange',
		radioClass: 'iradio_flat-orange',
		increaseArea: '30%'
	});

	this.mHide9999CooldownEventsCheckbox.on('ifChecked ifUnchecked', null, this, function (_event) {
		self.toggleShowing9999CooldownEvents(self.mHide9999CooldownEventsCheckbox.prop('checked') === true);
	});

	var tableHeader = $('<div class="emi-table-header"/>');
	this.mEventCooldownHeaderContent.append(tableHeader);

	tableHeader
		.append($("<div class='emi-cooldown-item-name title-font-big font-bold font-color-brother-name'>Event Name</div>"))
		.append($("<div class='emi-cooldown-item-fired-on title-font-big font-bold font-color-brother-name'>Fired on Day</div>"))
		.append($("<div class='emi-cooldown-item-cooldown-until-day title-font-big font-bold font-color-brother-name'>Available On Day</div>"));
}

EventManagerScreen.prototype.createEventPoolContainer = function ()
{
	this.mEventPoolContainer = $('<div id="emi-event-pool-container" class="emi-content-container"/>');
	this.mContainer.append(this.mEventPoolContainer);

	this.mEventPoolMessage = $('<span class="emi-content-message title-font-big font-bold font-color-brother-name">No events in the pool</span>')
	.hide();
	this.mEventPoolContainer.append(this.mEventPoolMessage);

	this.mEventPoolScrollContainer = $('<div class="emi-scroll-container" />')
	.appendTo(this.mEventPoolContainer);

	this.mVisibleContainer = this.mEventPoolScrollContainer;

	this.mEventPoolContainer.aciScrollBar({
	         delta: 2,
	         lineDelay: 0,
	         lineTimer: 0,
	         pageDelay: 0,
	         pageTimer: 0,
	         bindKeyboard: false,
	         resizable: false,
	         smoothScroll: true
	   });
}

EventManagerScreen.prototype.createEventCooldownContainer = function ()
{
	this.mEventCooldownContainer = $('<div id="emi-event-cooldown-container" class="emi-content-container"/>')
		.hide();
	this.mContainer.append(this.mEventCooldownContainer);

	this.mEventCooldownMessage = $('<span class="emi-content-message title-font-big font-bold font-color-brother-name">No events on cooldown</span>')
		.hide();
	this.mEventCooldownContainer.append(this.mEventCooldownMessage);

	this.mEventCooldownScrollContainer = $('<div class="emi-scroll-container"/>')
	.appendTo(this.mEventCooldownContainer);

	this.mEventCooldownContainer.aciScrollBar({
	         delta: 2,
	         lineDelay: 0,
	         lineTimer: 0,
	         pageDelay: 0,
	         pageTimer: 0,
	         bindKeyboard: false,
	         resizable: false,
	         smoothScroll: true
	   });
}

EventManagerScreen.prototype.createFilterBar = function()
{
	var filterContainer = $('<div class="emi-overview-filter-container"/>')
		.appendTo(this.mContainer);
	var self = this;
    var filterRow = $('<div class="emi-overview-filter-by-name-row"/>')
    	.appendTo(filterContainer);
    var name = $('<span class="title-font-normal font-color-brother-name">Filter by Event Name</span>')
    	.appendTo(filterRow);
    var filterLayout = $('<div class="emi-overview-filter-bar-container"/>')
        .appendTo(filterRow);
    this.mNameFilterInput = $('<input type="text" class="emi-filter title-font-big font-bold font-color-brother-name"/>')
            .appendTo(filterLayout)
            .on("keyup", function(_event){
                var currentInput = $(this).val().toLowerCase();
                // remove extra characters that sneak in
                currentInput = currentInput.replace(/[\u0127]/g, '');
                currentInput = currentInput.replace(/\u0127/g, '');
                currentInput = currentInput.replace("", '');
                currentInput = currentInput.replace(//g, '');
                $(this).val(currentInput);

				//self.filterEvents(currentInput);
				self.mEventFilter(currentInput);
			});
	
	var resetFilterButton = this.createCustomTabButton("Reset", function() {
		self.filterEvents("");
		self.mEventFilter = "";
	}, 'emi-tab-button');

	filterRow.append(resetFilterButton);

	var legend = $('<span class="title-font-normal font-color-brother-name brother-highlight">Event may give a bro</span>')
	.appendTo(filterRow);
}

EventManagerScreen.prototype.createFooter = function ()
{
	var footer = $('<div class="emi-overview-footer"/>')
		.appendTo(this.mContainer);
    this.mLeaveButton = footer.createTextButton("Leave", $.proxy(function()
	{
        this.onLeaveButtonPressed();
    }, this), null, 1);
}
///
/// End creation of HTML elements
///

///
/// Begin adding data
///
EventManagerScreen.prototype.populateEventsContainer = function(_data)
{
	var self = this;

	if (this.mEventPoolScrollContainer.children().length > 0) {
		this.mEventPoolScrollContainer.empty();
	}

	var eventList = this.mEventData.BroHireEventsInPool.concat(this.mEventData.NonBroHireEventsInPool);

	if (eventList.length === 0) 
	{
		this.showMessage(this.mEventPoolContainer, "No available events");
		return;
	}

	eventList.sort(function (a, b) {
		return a.name.localeCompare(b.name);
	});

	$.each(eventList, function (_, _eventData) {
		var collectionDiv = self.createEventInPoolSection(_eventData);
		self.mEventPoolScrollContainer.append(collectionDiv);
	});

	//this.mHideNonBroEventsCheckbox.prop('checked', true).trigger('change');
	this.mHideNonBroEventsCheckbox.iCheck('check');
	this.toggleShowingNormalEventsInPool(true);
}

EventManagerScreen.prototype.populateEventCooldownContainer = function(_data)
{
	var self = this;

	if (this.mEventCooldownScrollContainer.children().length > 0) {
		this.mEventCooldownScrollContainer.empty();
	}

	if (this.mEventData.EventsOnCooldown.length === 0) 
	{
		this.showMessage(this.mEventCooldownContainer, "No events on cooldown");
		return;
	}

	var eventList = this.mEventData.EventsOnCooldown;

	eventList.sort(function(a, b) {
		return a.firedOnDay - b.firedOnDay;
	});

	$.each(eventList, function (_, _eventData) {
		var eventDIv = self.createEventOnCooldownSection(_eventData);
		self.mEventCooldownScrollContainer.append(eventDIv);
	});

	///doesn't work
	//this.mHide9999CooldownEventsCheckbox.prop('checked', true).trigger('change');
	this.mHide9999CooldownEventsCheckbox.iCheck('check');
	this.toggleShowing9999CooldownEvents(true);
}

EventManagerScreen.prototype.populateSummary = function(_data) 
{
	var broChance = 1.0;

	if (_data.AllScores > 0) {
		broChance = (_data.EventBroHireScore / _data.AllScores * 1.0 * 100.0);
	}

	var text = "Chance for a brother: " + broChance.toFixed(2) + "% " + "(" + _data.EventBroHireScore + " / " + _data.AllScores + ")";
	$("#emi-chance-for-a-brother").text(text);
}

EventManagerScreen.prototype.createEventInPoolSection = function(_eventData)
{
	var nameField = $("<div class='emi-event-item-name title-font-normal font-bold font-color-brother-name'>" + _eventData.name + "</div>");
	var scoreField = $("<div class='emi-event-item-score title-font-normal font-bold font-color-brother-name'>" + _eventData.score + "</div>");
	
	if (_eventData.mayGiveBrother) {
		nameField.addClass('brother-highlight');
		scoreField.addClass('brother-highlight');
	}

	var eventContainer = $('<div class="emi-event-container"/>')
		.attr('data-event-name', _eventData.name)
		.attr('is-bro-event', _eventData.mayGiveBrother)
		.attr('crises-event', _eventData.isCrisesEvent)
		.append(nameField)
		.append(scoreField);
	
	return eventContainer;
}

EventManagerScreen.prototype.createEventOnCooldownSection = function(_eventData)
{
	var firedOnDay = 0;
	var onCooldownUntilDay = 0;

	if (_eventData.firedOnDay !== null && _eventData.firedOnDay >= 0) {
		firedOnDay = _eventData.firedOnDay.toFixed(2);
	}

	if (_eventData.onCooldownUntilDay != null && _eventData.onCooldownUntilDay >= 0) {
		onCooldownUntilDay = _eventData.onCooldownUntilDay.toFixed(2);
	}

	var nameField = $("<div class='emi-cooldown-item-name title-font-normal font-bold font-color-brother-name'>" + _eventData.name + "</div>");
	var firedOnField = $("<div class='emi-cooldown-item-fired-on title-font-normal font-bold font-color-brother-name'>" + firedOnDay + "</div>");
	var onCooldownField = $("<div class='emi-cooldown-item-cooldown-until-day title-font-normal font-bold font-color-brother-name'>" + onCooldownUntilDay + "</div>");

	if (_eventData.mayGiveBrother) {
		nameField.addClass('brother-highlight');
		firedOnField.addClass('brother-highlight');
		onCooldownField.addClass('brother-highlight');
	}

	var eventContainer = $('<div class="emi-event-container"/>')
		.attr('data-event-name', _eventData.name)
		.attr('is-bro-event', _eventData.mayGiveBrother)
		.attr('on-cooldown-until-day', _eventData.onCooldownUntilDay)
		.append(nameField)
		.append(firedOnField)
		.append(onCooldownField);
	
	return eventContainer;
}
///
/// End adding data
///

///
/// Begin button press functions
///
EventManagerScreen.prototype.onLeaveButtonPressed = function()
{
	this.hide();
}

EventManagerScreen.prototype.switchToEventsInPoolPanel = function ()
{
	this.mVisibleContainer = this.mEventPoolScrollContainer;
	
	$('#emi-event-cooldown-button').removeClass("is-active");
	$('#emi-event-pool-button').addClass("is-active");
	
	this.mNameFilterInput.val("");
	this.mEventPoolScrollContainer.find(".emi-event-container").show();
	this.mEventCooldownScrollContainer.find(".emi-event-container").show();

	$("#emi-event-cooldown-container").hide();
	$("#emi-event-cooldown-header-content").hide();
	$("#emi-event-pool-container").show();
	$("#emi-event-pool-header-content").show();
}

EventManagerScreen.prototype.switchToEventsOnCooldownPanel = function () 
{
	this.mVisibleContainer = this.mEventCooldownScrollContainer;

	$('#emi-event-pool-button').removeClass("is-active");
	$('#emi-event-cooldown-button').addClass("is-active");

	this.mNameFilterInput.val("");
	this.mEventPoolScrollContainer.find(".emi-event-container").show();
	this.mEventCooldownScrollContainer.find(".emi-event-container").show();

	$("#emi-event-pool-container").hide();
	$("#emi-event-pool-header-content").hide();
	$("#emi-event-cooldown-container").show();
	$("#emi-event-cooldown-header-content").show();
}
///
/// End button press functions
///

///
/// Begin utility functions
///
EventManagerScreen.prototype.showMessage = function(_container, _message)
{
	return; //do nothing for now -
	_container.find('.emi-content-message')
		.text(_message)
		.show();
}

EventManagerScreen.prototype.hideMessage = function(_container) 
{
	return; //do nothing for now -
	_container.find('.emi-content-message')
		.hide();
}

EventManagerScreen.prototype.filterEvents = function(_showOnlyBroEvents, _show9999CooldownEvents)
{
	var self = this;

	if (this.mVisibleContainer == null) {
		return;
	}

	if (this.mVisibleContainer.children().length() === 0) {
		return;
	}

	this.mVisibleContainer.find(".emi-event-container").each(function() {
		// I think I need to make everything show first - think through this function again with some fresh coffeee..
		var showEvent = false;

		if (this.mEventFilter !== "" && $(this).attr("data-event-name").toLowerCase().search(_text) >= 0) {
			showEvent = true;
		}

		if (showEvent && _showOnlyBroEvents && $(this).attr("is-bro-event") === "true") {
			showEvent = true;
		}

		if (showEvent && _show9999CooldownEvents && parseInt($(this).attr("on-cooldown-until-day")) < 9999) {
			showEvent = true;
		}

		if (showEvent) {
			$(this).show();
		}
		else {
			$(this).hide();
		}

		///take 2
		$(this).show();

		var hideEvent = false;

		if (this.mEventFilter !== "" && this.mEventFilter.length() > 0 && $(this).attr("data-event-name").toLowerCase().search(_text) == -1) {
			hideEvent = true;
		}

		if (!hideEvent && _showOnlyBroEvents && $(this).attr("is-bro-event") === "false") {
			hideEvent = true;
		}

		if (!hideEvent && _show9999CooldownEvents && parseInt($(this).attr("on-cooldown-until-day")) >= 9999) {
			hideEvent = true;
		}


		if (hideEvent) {
			$(this).hide();
		}
	});
}

EventManagerScreen.prototype.toggleObscuringCrisesEvents = function(_obscure) 
{
	var self = this;
	this.mEventPoolScrollContainer.find(".emi-event-container").each(function() {
		if (_obscure && $(this).attr("crises-event")) {
			$(this).find(".emi-event-item-name").text("Crises Event")
		}
		else if (!_obscure && $(this).attr("crises-event")) {
			$(this).find(".emi-event-item-name").text($(this).attr("data-event-name"));
		}
	})
}

EventManagerScreen.prototype.filterEvents = function(_text) 
{
	var self = this;

	if (_text == "") 
	{
		self.mEventPoolScrollContainer.find(".emi-event-container").show();
		self.mEventCooldownScrollContainer.find(".emi-event-container").show();
		this.mNameFilterInput.val("");

		// will need to happen at some point but only if there are no data elements
		if (this.mEventData.BroHireEventsInPool.length > 0 || this.mEventData.NonBroHireEventsInPool.length > 0) {
			self.hideMessage(self.mEventCooldownContainer);
		}
		if (this.mEventData.EventsOnCooldown.length > 0) {
			self.hideMessage(self.mEventCooldownContainer);
		}
	}
	else 
	{
		if (self.mEventPoolContainer.is(':visible'))
		{
			if (self.mEventPoolScrollContainer.children().length === 0) {
				return;
			}

			self.mEventPoolScrollContainer.find(".emi-event-container").each(function() {
				if ($(this).attr("data-event-name").toLowerCase().search(_text) == -1) {
					$(this).hide();
				}
				else {
					$(this).show();
				}
			})

			if (!self.mEventPoolScrollContainer.find(".emi-event-container").is(":visible")) 
			{
				self.showMessage(self.mEventPoolContainer, "No events found");
			}
			else 
			{
				self.hideMessage(self.mEventPoolContainer);
			}
		}
		else
		{
			if (self.mEventCooldownScrollContainer.children().length === 0) {
				return;
			}

			self.mEventCooldownScrollContainer.find(".emi-event-container").each(function() {
				if ($(this).attr("data-event-name").toLowerCase().search(_text) == -1) {
					$(this).hide();
				}
				else {
					$(this).show();
				}
			})

			if (!self.mEventCooldownScrollContainer.find(".emi-event-container").is(":visible")) 
			{
				self.showMessage(self.mEventCooldownContainer, "No events found");
			}
			else 
			{
				self.hideMessage(self.mEventCooldownContainer);
			}
		}
	}
}

EventManagerScreen.prototype.toggleShowingNormalEventsInPool = function (_hideEvents)
{
	this.filterEvents("");

	if (_hideEvents) {
		this.mEventPoolScrollContainer.find(".emi-event-container").each(function() {
			console.log("Is bro event? " + $(this).attr("is-bro-event"));
			if ($(this).attr("is-bro-event") === "true") {
				$(this).show();
			}
			else {
				$(this).hide();
			}
		});
	}	
	else {
		this.mEventPoolScrollContainer.find(".emi-event-container").show();			
	}	
}

EventManagerScreen.prototype.toggleShowing9999CooldownEvents = function (_hideEvents) 
{
	this.filterEvents("");
	
	if (_hideEvents) {
		this.mEventCooldownScrollContainer.find(".emi-event-container").each(function() {
			//console.log("On cooldown until day: " + $(this).attr("on-cooldown-until-day"));
			if (parseInt($(this).attr("on-cooldown-until-day")) >= 9999) {
				$(this).hide();
			}
			else {
				$(this).show();
			}
		});
	}
	else {
		//on-cooldown-until-day
		this.mEventCooldownScrollContainer.find(".emi-event-container").show();	
	}
}
///
/// End utility functions
///

///
/// Begin custom UI elements
///
EventManagerScreen.prototype.createCustomEmiHeaderButton = function (_text, _callback, _classes) 
{
	var result = $('<div class="ui-control emi-custom-header-button text-font-normal"/>');

    if (_classes !== undefined && _classes !== null && typeof(_classes) === 'string')
    {
        result.addClass(_classes);
    }

	if (_text !== undefined && _text !== null && typeof(_text) === 'string')
    {
        var label = $('<span class="label">' + _text + '</span>');
        result.append(label);
    }

    if (_callback !== undefined && _callback !== null && typeof(_callback) === 'function')
    {
        result.on("click", function ()
        {
            var disabled = $(this).attr('disabled');
            if (disabled !== null && disabled !== 'disabled')
			{
                _callback($(this));
            }
        });
    }

    result.on("mousedown", function ()
    {
        var disabled = $(this).attr('disabled');
        if(disabled !== null && disabled !== 'disabled')
		{
            $(this).addClass('is-selected');
        }
		else
		{
            $(this).removeClass('is-selected');
        }
    });

    result.on("mouseup", function ()
    {
        $(this).removeClass('is-selected');
    });

    result.on("mouseenter", function ()
    {
        var disabled = $(this).attr('disabled');
        if (disabled !== null && disabled !== 'disabled')
        {
            $(this).addClass('is-selected');
        }
        else
        {
            $(this).removeClass('is-selected');
        }
    });

    result.on("mouseleave", function ()
    {
        $(this).removeClass('is-selected');
    });

    return result;
}

EventManagerScreen.prototype.createCustomTabButton = function(_text, _callback, _classes)
{
	var result = $('<div class="ui-control emi-custom-tab-button text-font-normal"/>');

	if (_classes !== undefined && _classes !== null && typeof(_classes) === 'string')
    {
        result.addClass(_classes);
    }

    if (_text !== undefined && _text !== null && typeof(_text) === 'string')
    {
        var label = $('<span class="label">' + _text + '</span>');
        result.append(label);
    }

    if (_callback !== undefined && _callback !== null && typeof(_callback) === 'function')
    {
    	result.click(function (_event)
    	{
			_callback($(this));
        });
    }

	return result;
}
///
/// End custom UI elements
///

///
/// Begin tooltips
///
EventManagerScreen.prototype.bindTooltips = function ()
{

};

EventManagerScreen.prototype.unbindTooltips = function ()
{

};
///
/// End tooltips
///

///
/// Begin popupDialog functions
///
// EventManagerScreen.prototype.setPopupDialog = function ( _dialog )
// {
// 	this.mPopupDialog = _dialog;
// 	this.notifyBackendPopupVisible(true);
// };

// EventManagerScreen.prototype.destroyPopupDialog = function ()
// {
// 	if(this.mPopupDialog !== null)
// 	{
// 		this.mPopupDialog.destroyPopupDialog();
// 		this.mPopupDialog = null;
// 	}
// 	this.notifyBackendPopupVisible(false);
// };
///
/// Begin popupDialog functions
///

///
/// Begin backend notification functions
///
EventManagerScreen.prototype.notifyBackendPopupVisible = function ( _data )
{
	if (this.mSQHandle !== null)
	{
		SQ.call(this.mSQHandle, 'onPopupVisible', _data);
	}
};

EventManagerScreen.prototype.notifyBackendOnShown = function ()
{
	if (this.mSQHandle !== null)
	{
		SQ.call(this.mSQHandle, 'onScreenShown');
	}
};

EventManagerScreen.prototype.notifyBackendOnHidden = function ()
{
	if (this.mSQHandle !== null)
	{
		SQ.call(this.mSQHandle, 'onScreenHidden');
	}
};

EventManagerScreen.prototype.notifyBackendOnAnimating = function ()
{
	if (this.mSQHandle !== null)
	{
		SQ.call(this.mSQHandle, 'onScreenAnimating');
	}
};
///
/// End backend notification functions
///

registerScreen("EventManagerScreen", new EventManagerScreen());