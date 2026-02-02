"use strict";
var EventManagerScreen = function (_parent)
{
	MSUUIScreen.call(this);

	this.mID = "EventManagerScreen";
	this.mModId = "mod_event_manager_info";
	this.mContainer = null;
	this.mDialogContainer = null;
	this.mContentContainer = null;
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

	this.mVisibleContainer = null;
	this.mEventFilterText = "";
	this.mObscureCrisesEvents = true;
};

/*
	{
		BroHireEventsInPool = [{
			id = "",
			name = "",
			score = 0,
			cooldown = 0,
			isBroEvent = true,
			mayGiveBrother = true/false,
			chanceForBrother = 0,
			isCrisesEvent = false,
			icon = ""
		}],
		NonBroHireEventsInPool = [{
			id = "",
			name = "",
			score = 0,
			cooldown = 0,
			isBroEvent = false,
			mayGiveBrother = false,
			chanceForBrother = 0,
			isCrisesEvent = false,
			icon = ""
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
	this.bindTooltips();
};

EventManagerScreen.prototype.setData = function (_data)
{    
	this.mEventData = _data;

	this.populateSummary(_data);
	this.populateEventsContainer(_data);
	this.populateEventCooldownContainer(_data);
	this.toggleObscuringCrisesEvents();
	this.setDefaultsPerMSUISettings();
	this.filterEvents();
};

EventManagerScreen.prototype.destroyDIV = function ()
{
	this.mHideNonBroEventsCheckbox = null;
	this.mHide9999CooldownEventsCheckbox = null;
	this.mNameFilterInput = null;
	this.mEventData = null;
	this.mEventPoolMessage = null;
	this.mEventCooldownMessage = null;
	this.mVisibleContainer = null;
	this.mEventFilterText = "";

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

	this.mDialogContainer.empty();
	this.mDialogContainer.remove();
	this.mDialogContainer = null;

	this.mContainer.empty();
	this.mContainer.remove();
	this.mContainer = null;
};

EventManagerScreen.prototype.onShow = function()
{
	//this.mNameFilterInput.focus();
};

EventManagerScreen.prototype.onHide = function()
{
	this.switchToEventsInPoolPanel();
};

EventManagerScreen.prototype.destroy = function()
{
	this.unbindTooltips();
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
	this.mContainer = $("<div class='emi-screen display-none opacity-none'/>")
		.appendTo(_parentDiv);

	var dialogLayout = $("<div class='emi-screen-container'/>")
	this.mContainer.append(dialogLayout);

	this.mDialogContainer = dialogLayout.createDialog('Event Info (0.9.8)', 'View available events and events on cooldown', '', true, 'dialog-1024-768');

	this.mPageTabContainer = $('<div class="l-tab-container"/>');
    this.mDialogContainer.findDialogTabContainer().append(this.mPageTabContainer);

	this.mContentContainer = this.mDialogContainer.findDialogContentContainer();

	this.createButtonBar();
	this.createTableHeaderSpaceForEventPoolContainer();
	this.createTableHeaderSpaceForEventCooldownContainer();
	this.createEventPoolContainer();
	this.createEventCooldownContainer();
	this.createFilterBar();
	this.createFooter();

	this.mIsVisible = false;
};

EventManagerScreen.prototype.createButtonBar = function () 
{
	var self = this
	var layout = $('<div class="l-tab-button"/>');
    this.mPageTabContainer.append(layout);
    var eventPoolButton = layout.createTabTextButton("Event Pool", function()
    {
        self.switchToEventsInPoolPanel();
    }, null, '', 7);

    layout = $('<div class="l-tab-button"/>');
    this.mPageTabContainer.append(layout);
    var eventCooldownButton = layout.createTabTextButton("On Cooldown", function ()
    {
        self.switchToEventsOnCooldownPanel();
    }, null, '', 7);

	eventPoolButton.addClass('is-selected');

	eventPoolButton.attr("id", "emi-event-pool-button");
	eventCooldownButton.attr("id", "emi-event-cooldown-button");
}

EventManagerScreen.prototype.createTableHeaderSpaceForEventPoolContainer = function ()
{
	var self = this;
	this.mEventPoolHeaderContent = $('<div id="emi-event-pool-header-content" class="emi-content-header"/>')
		.appendTo(this.mContentContainer);

	var summaryContent = $('<div class="emi-event-summary"/>');
	this.mEventPoolHeaderContent.append(summaryContent);

	var chanceForABro = $('<span id="emi-chance-for-a-brother" class="emi-event-summary-content title-font-normal font-color-description">Chance for a brother event ' + 0 + '</span>');
	summaryContent.append(chanceForABro);
	chanceForABro.bindTooltip({contentType: 'msu-generic', modId: this.mModId, elementId: "Form.EventBroChance"});
	
	this.mHideNonBroEventsCheckbox = $('<input type="checkbox" class="emi-checkbox" id="emi-hide-non-bro-events"/>');
	summaryContent.append(this.mHideNonBroEventsCheckbox);

    var checkboxLabel = $('<label class="emi-checkbox-label title-font-normal font-bold font-color-description" for="emi-hide-non-bro-events">Show only brother events</label>');

	summaryContent.append(checkboxLabel);

	this.mHideNonBroEventsCheckbox.iCheck({
		checkboxClass: 'icheckbox_flat-orange',
		radioClass: 'iradio_flat-orange',
		increaseArea: '30%'
	});

	this.mHideNonBroEventsCheckbox.on('ifChecked ifUnchecked', null, this, function (_event) {
		self.filterEvents();
	});

	var tableHeader = $('<div class="emi-table-header"/>');
	this.mEventPoolHeaderContent.append(tableHeader);

	tableHeader
		.append($("<div class='emi-event-item-icon-container title-font-normal font-bold font-color-description'>Icon</div>"))
		.append($("<div class='emi-event-item-name title-font-normal font-bold font-color-description'>Event Name</div>"))
		.append($("<div class='emi-event-item-score title-font-normal font-bold font-color-description'>Score</div>"))
		.append($("<div class='emi-event-item-cooldown title-font-normal font-bold font-color-description'>Cooldown</div>"));
}

EventManagerScreen.prototype.createTableHeaderSpaceForEventCooldownContainer = function ()
{
	var self = this;
	this.mEventCooldownHeaderContent = $('<div id="emi-event-cooldown-header-content" class="emi-content-header"/>')
		.appendTo(this.mContentContainer)
		.hide();

	var summaryContent = $('<div class="emi-event-summary"/>');
	this.mEventCooldownHeaderContent.append(summaryContent);

	this.mHide9999CooldownEventsCheckbox = $('<input type="checkbox" class="emi-checkbox" id="emi-hide-9999-events"/>');
	summaryContent.append(this.mHide9999CooldownEventsCheckbox);

    var checkboxLabel = $('<label class="emi-checkbox-label title-font-normal font-bold font-color-description" for="emi-hide-9999-events">Hide 9999 day cooldown events</label>');
   
	summaryContent.append(checkboxLabel);

	this.mHide9999CooldownEventsCheckbox.iCheck({
		checkboxClass: 'icheckbox_flat-orange',
		radioClass: 'iradio_flat-orange',
		increaseArea: '30%'
	});

	this.mHide9999CooldownEventsCheckbox.on('ifChecked ifUnchecked', null, this, function (_event) {
		self.filterEvents();
	});

	var tableHeader = $('<div class="emi-table-header"/>');
	this.mEventCooldownHeaderContent.append(tableHeader);

	tableHeader
		.append($("<div class='emi-cooldown-item-icon-container title-font-normal font-bold font-color-description'>Icon</div>"))
		.append($("<div class='emi-cooldown-item-name title-font-normal font-bold font-color-description'>Event Name</div>"))
		.append($("<div class='emi-cooldown-item-fired-on title-font-normal font-bold font-color-description'>Fired on Day</div>"))
		.append($("<div class='emi-cooldown-item-cooldown-until-day title-font-normal font-bold font-color-description'>Available On Day</div>"));
}

EventManagerScreen.prototype.createEventPoolContainer = function ()
{
	this.mEventPoolContainer = $('<div id="emi-event-pool-container" class="emi-content-container"/>');
	this.mContentContainer.append(this.mEventPoolContainer);

	this.mEventPoolMessage = $('<span class="emi-content-message title-font-normal font-bold font-color-description">No events in the pool</span>')
	.hide();
	this.mEventPoolContainer.append(this.mEventPoolMessage);

	this.mEventPoolScrollContainer = $('<div id="emi-event-pool-scroll-container" class="emi-scroll-container" />')
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
	this.mContentContainer.append(this.mEventCooldownContainer);

	this.mEventCooldownMessage = $('<span class="emi-content-message title-font-normal font-bold font-color-description">No events on cooldown</span>')
		.hide();
	this.mEventCooldownContainer.append(this.mEventCooldownMessage);

	this.mEventCooldownScrollContainer = $('<div id="emi-event-cooldown-scroll-container" class="emi-scroll-container"/>')
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
		.appendTo(this.mContentContainer);
	var self = this;
    var filterRow = $('<div class="emi-overview-filter-by-name-row"/>')
    	.appendTo(filterContainer);
    var name = $('<span class="title-font-normal font-color-description">Filter by Event Name</span>')
    	.appendTo(filterRow);
    var filterLayout = $('<div class="emi-overview-filter-bar-container"/>')
        .appendTo(filterRow);
	this.mNameFilterInput = $('<input type="text" class="emi-filter title-font-normal font-bold font-color-description"/>')
		.appendTo(filterLayout)
		.on("keydown.input", function (_event) {
			//ignore keypress ctrl + e, which is the default keybind to open/close the UI
			if (_event.ctrlKey && _event.keyCode === KeyConstants.E) {
				// _event.preventDefault();
				// this.mContainer.focus();
				// self.onLeaveButtonPressed();
			}
		})
		.on("keyup", function(_event){
			var currentInput = $(this).val().toLowerCase();
			// remove extra characters that sneak in
			currentInput = currentInput.replace(/[\u0127]/g, '');
			currentInput = currentInput.replace(/\u0127/g, '');
			currentInput = currentInput.replace("", '');
			currentInput = currentInput.replace(//g, '');
			$(this).val(currentInput);

			self.mEventFilterText = currentInput;
			self.filterEvents();
		});
	
	var resetFilterButton = this.createCustomTabButton("Reset", function () {
		self.mNameFilterInput.val("");
		self.mEventFilterText = "";
		self.filterEvents();
	}, 'emi-tab-button');

	filterRow.append(resetFilterButton);

	var legend = $('<span class="title-font-normal font-color-description brother-highlight emi-is-brother-event">Event may give a bro</span>')
	.appendTo(filterRow);
}

EventManagerScreen.prototype.createFooter = function ()
{
	var self = this;

    var footerButtonBar = $('<div class="l-button-bar"/>');
    this.mDialogContainer.findDialogFooterContainer().append(footerButtonBar);

    var layout = $('<div class="l-leave-button"/>');
    footerButtonBar.append(layout);
    this.mLeaveButton = layout.createTextButton("Close", function()
	{
        self.onLeaveButtonPressed();
    }, '', 1);
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
		var collectionDiv = self.createEventInPoolRow(_eventData);
		self.mEventPoolScrollContainer.append(collectionDiv);
	});
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
		var eventDIv = self.createEventOnCooldownRow(_eventData);
		self.mEventCooldownScrollContainer.append(eventDIv);
	});
}

EventManagerScreen.prototype.populateSummary = function(_data) 
{
	var broChance = 1.0;

	if (_data.AllScores > 0) {
		broChance = (_data.EventBroHireScore / _data.AllScores * 1.0 * 100.0);
	}

	var text = "Chance for a brother event to fire: " + broChance.toFixed(2) + "% " + "(" + _data.EventBroHireScore + " / " + _data.AllScores + ")";
	$("#emi-chance-for-a-brother").text(text);
}

EventManagerScreen.prototype.createEventInPoolRow = function(_eventData)
{
	var iconField = $("<div class='emi-event-item-icon-container'/>");
	var image = $('<img class="emi-event-item-icon"/>');
    image.attr('src', Path.GFX + _eventData.icon);
	iconField.append(image);

	var eventName = _eventData.name;

	if (_eventData.chanceForBrother < 100) {
		eventName = eventName + " (" + _eventData.chanceForBrother + "% Chance)";
	}

	var nameField = $("<div class='emi-event-item-name title-font-normal font-bold font-color-description'>" + eventName + "</div>");
	var scoreField = $("<div class='emi-event-item-score title-font-normal font-bold font-color-description'>" + _eventData.score + "</div>");
	var cooldownField = $("<div class='emi-event-item-cooldown title-font-normal font-bold font-color-description'>" + _eventData.cooldown + "</div>");
	
	if (_eventData.mayGiveBrother) {
		nameField.addClass('brother-highlight').addClass('emi-is-brother-event'); ///.addClass('font-bold');
		scoreField.addClass('brother-highlight'); //.addClass('font-bold');
		cooldownField.addClass('brother-highlight'); //.addClass('font-bold');
	}
	else 
	{
		// nameField.addClass('non-brother-highlight');
		// scoreField.addClass('non-brother-highlight');
		// cooldownField.addClass('non-brother-highlight');
	}

	var eventContainer = $('<div class="emi-event-container"/>')
		.attr('data-event-name', _eventData.name)
		.attr('is-bro-event', _eventData.isBroEvent)
		.attr('crises-event', _eventData.isCrisesEvent)
		.append(iconField)
		.append(nameField)
		.append(scoreField)
		.append(cooldownField);

	// if (_eventData.mayGiveBrother) {
	// 	eventContainer.addClass('emi-is-brother-event');
	// }
	
	return eventContainer;
}

EventManagerScreen.prototype.createEventOnCooldownRow = function(_eventData)
{
	var firedOnDay = 0;
	var onCooldownUntilDay = 0;
	var iconField = $("<div class='emi-cooldown-item-icon-container'/>");
	var image = $('<img class="emi-event-item-icon"/>');
    image.attr('src', Path.GFX + _eventData.icon);
	iconField.append(image);

	if (_eventData.firedOnDay !== null && _eventData.firedOnDay >= 0) {
		firedOnDay = _eventData.firedOnDay.toFixed(2);
	}

	if (_eventData.onCooldownUntilDay != null && _eventData.onCooldownUntilDay >= 0) {
		onCooldownUntilDay = _eventData.onCooldownUntilDay.toFixed(2);
	}

	var nameField = $("<div class='emi-cooldown-item-name title-font-normal font-bold font-color-description'>" + _eventData.name + "</div>");
	var firedOnField = $("<div class='emi-cooldown-item-fired-on title-font-normal font-bold font-color-description'>" + firedOnDay + "</div>");
	var onCooldownField = $("<div class='emi-cooldown-item-cooldown-until-day title-font-normal font-bold font-color-description'>" + onCooldownUntilDay + "</div>");

	if (_eventData.mayGiveBrother) {
		nameField.addClass('brother-highlight').addClass('emi-is-brother-event'); //.addClass('font-bold');
		firedOnField.addClass('brother-highlight'); //.addClass('font-bold');
		onCooldownField.addClass('brother-highlight'); //.addClass('font-bold');
	}
	else 
	{
		// nameField.addClass('non-brother-highlight');
		// firedOnField.addClass('non-brother-highlight');
		// onCooldownField.addClass('non-brother-highlight');
	}

	var eventContainer = $('<div class="emi-event-container"/>')
		.attr('data-event-name', _eventData.name)
		.attr('is-bro-event', _eventData.isBroEvent)
		.attr('on-cooldown-until-day', _eventData.onCooldownUntilDay)
		.append(iconField)
		.append(nameField)
		.append(firedOnField)
		.append(onCooldownField);

	// if (_eventData.mayGiveBrother) {
	// 	eventContainer.addClass('emi-is-brother-event');
	// }
	
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
	this.notifyBackendToCloseUI();
}

EventManagerScreen.prototype.switchToEventsInPoolPanel = function ()
{
	this.mVisibleContainer = this.mEventPoolScrollContainer;

	$('#emi-event-cooldown-button').removeClass("is-selected");
	$('#emi-event-pool-button').addClass("is-selected");
	
	this.mNameFilterInput.val("");
	this.mEventFilterText = "";
	this.mEventPoolScrollContainer.find(".emi-event-container").show();
	this.mEventCooldownScrollContainer.find(".emi-event-container").show();

	$("#emi-event-cooldown-container").hide();
	$("#emi-event-cooldown-header-content").hide();
	$("#emi-event-pool-container").show();
	$("#emi-event-pool-header-content").show();
	
	this.filterEvents();
}

EventManagerScreen.prototype.switchToEventsOnCooldownPanel = function () 
{
	this.mVisibleContainer = this.mEventCooldownScrollContainer;

	$('#emi-event-pool-button').removeClass("is-selected");
	$('#emi-event-cooldown-button').addClass("is-selected");

	this.mNameFilterInput.val("");
	this.mEventFilterText = "";
	this.mEventPoolScrollContainer.find(".emi-event-container").show();
	this.mEventCooldownScrollContainer.find(".emi-event-container").show();

	$("#emi-event-pool-container").hide();
	$("#emi-event-pool-header-content").hide();
	$("#emi-event-cooldown-container").show();
	$("#emi-event-cooldown-header-content").show();

	this.filterEvents();
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

EventManagerScreen.prototype.filterEvents = function()
{
	var self = this;

	if (this.mVisibleContainer == null) {
		return;
	}

	if (this.mVisibleContainer.children().length === 0) {
		return;
	}

	var filterText = "";
	
	if (this.mEventFilterText != null) {
		filterText = this.mEventFilterText;
	};

	var showOnlyBroEvents = this.mHideNonBroEventsCheckbox.prop('checked') === true;
	var hide9999CooldownEvents = this.mHide9999CooldownEventsCheckbox.prop('checked') === true;

	this.mVisibleContainer.find(".emi-event-container").each(function() {
		$(this).show();

		var hideEvent = false;

		if (filterText !== "" && filterText.length > 0 && $(this).attr("data-event-name").toLowerCase().search(filterText) == -1) {
			hideEvent = true;
		}

		if (self.mVisibleContainer.attr("id") == "emi-event-pool-scroll-container" && !hideEvent && showOnlyBroEvents && $(this).attr("is-bro-event") === "false") {
			hideEvent = true;
		}

		if (self.mVisibleContainer.attr("id") == "emi-event-cooldown-scroll-container" && !hideEvent && hide9999CooldownEvents && parseInt($(this).attr("on-cooldown-until-day")) >= 9999) {
			hideEvent = true;
		}

		if (hideEvent) {
			$(this).hide();
		}
	});
}

EventManagerScreen.prototype.toggleObscuringCrisesEvents = function() 
{
	var obscureCrisesEvents = this.mObscureCrisesEvents;

	this.mEventPoolScrollContainer.find(".emi-event-container").each(function() {
		if (obscureCrisesEvents && $(this).attr("crises-event") == "true") {
			$(this).find(".emi-event-item-name").text("Crises Event")
		}
		else if (!obscureCrisesEvents && $(this).attr("crises-event") == "true") {
			$(this).find(".emi-event-item-name").text($(this).attr("data-event-name"));
		}
	})
}

EventManagerScreen.prototype.setDefaultsPerMSUISettings = function() 
{
	var showOnlyBroEvents = MSU.getSettingValue(this.mModId, "DefaultOnlyShowBroEvents");
	var hide9999CooldownEvents = MSU.getSettingValue(this.mModId, "DefaultHide9999Events");
	var obscureCrisesEvents = MSU.getSettingValue(this.mModId, "ObscureCrisesEvents");

	if (showOnlyBroEvents) {
		this.mHideNonBroEventsCheckbox.iCheck('check');
	} 
	else {
		this.mHideNonBroEventsCheckbox.iCheck('uncheck');
	}

	if (hide9999CooldownEvents) {
		this.mHide9999CooldownEventsCheckbox.iCheck('check');
	}
	else {
		this.mHide9999CooldownEventsCheckbox.iCheck('uncheck');
	}

	this.mObscureCrisesEvents = obscureCrisesEvents;
}

///
/// Begin custom UI elements
///
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
EventManagerScreen.prototype.notifyBackendToCloseUI = function ()
{
    if (this.mSQHandle !== null)
    {
        SQ.call(this.mSQHandle, 'onCloseButtonPressed');
    }
}
///
/// End backend notification functions
///

registerScreen("EventManagerScreen", new EventManagerScreen());