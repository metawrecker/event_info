"use strict";
var EventInfoScreen = function (_parent)
{
	MSUUIScreen.call(this);

	this.mID = "EventInfoScreen";
	this.mModId = "mod_event_info";
	this.mContainer = null;
	this.mDialogContainer = null;
	this.mContentContainer = null;

	this.mEventPoolHeaderContent = null;
	this.mEventPoolContainer = null;
	this.mEventPoolScrollContainer = null;
	
	this.mEventCooldownHeaderContent = null;
	this.mEventCooldownContainer = null;
	this.mEventCooldownScrollContainer = null;

	this.mEventInfoHeaderContent = null;
	this.mEventInfoContainer = null;
	this.mEventInfoScrollContainer = null;

	this.mEventPoolMessage = null;
	this.mEventCooldownMessage = null;

	this.mEventData = null;
	this.mEventInfo = null;
	this.mNameFilterInput = null;
	this.mHideNonBroEventsCheckbox = null;
	this.mHide9999CooldownEventsCheckbox = null;

	this.mVisibleContainer = null;
	this.mEventFilterText = "";
	this.mObscureCrisesEvents = true;
};

//event info page
/*
	mEventInfo = {
		AnyNews = "",
		LastEventDayAndHour = "",
		CurrentTile = "",
		CurrentTerrain = "",
		EnemyWithin4Tiles = ""
	}
*/

/*
	mEventData = {
		BroHireEventsInPool = [{
			id = "",
			name = "",
			score = 0,
			cooldown = 0,
			isBroEvent = true,
			mayGiveBrother = true/false,
			chanceForBrother = 0,
			isCrisesEvent = false,
			icon = "",
			background = ""
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
			icon = "",
			background = ""
		}],
		EventsOnCooldown = [{
			id = "",
			name = "",
			score = 0,
			onCooldownUntilDay = 0,
			firedOnDay = 0
			mayGiveBrother = false,
			background = ""
		}],
		AllScores = 0,
		NonEventBroHireScore = 0,
		EventBroHireScore = 0
	};
*/

EventInfoScreen.prototype = Object.create(MSUUIScreen.prototype);
Object.defineProperty(EventInfoScreen.prototype, 'constructor', {
	value: EventInfoScreen,
	enumerable: false,
	writable: true
});

///
/// Begin form functions
///
EventInfoScreen.prototype.create = function(_parentDiv)
{
	this.createDIV(_parentDiv);
	this.bindTooltips();
};

EventInfoScreen.prototype.setData = function (_data)
{    
	this.mEventData = _data;

	this.populateSummary(_data);
	this.populateEventsContainer(_data);
	this.populateEventCooldownContainer(_data);
	this.setDefaultsPerMSUISettings();
	this.toggleObscuringCrisesEvents();
	this.filterEvents();
};

EventInfoScreen.prototype.setInfo = function(_info)
{
	this.populateEventInfoFields(_info);
}

EventInfoScreen.prototype.destroyDIV = function ()
{
	this.mHideNonBroEventsCheckbox = null;
	this.mHide9999CooldownEventsCheckbox = null;
	this.mNameFilterInput = null;
	this.mEventData = null;
	this.mEventInfo = null;
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

	this.mEventInfoHeaderContent.empty();
	this.mEventInfoHeaderContent.remove();
	this.mEventInfoHeaderContent = null;

	this.mEventInfoContainer.empty();
	this.mEventInfoContainer.remove();
	this.mEventInfoContainer = null;

	this.mDialogContainer.empty();
	this.mDialogContainer.remove();
	this.mDialogContainer = null;

	this.mContainer.empty();
	this.mContainer.remove();
	this.mContainer = null;
};

EventInfoScreen.prototype.onShow = function()
{
	//this.mNameFilterInput.focus();
};

EventInfoScreen.prototype.onHide = function()
{
	this.switchToEventsInPoolPanel();
};

EventInfoScreen.prototype.destroy = function()
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
EventInfoScreen.prototype.createDIV = function (_parentDiv)
{
	this.mContainer = $("<div class='emi-screen display-none opacity-none'/>")
		.appendTo(_parentDiv);

	var dialogLayout = $("<div class='emi-screen-container'/>")
	this.mContainer.append(dialogLayout);

	this.mDialogContainer = dialogLayout.createDialog('Event Info', 'View events and event manager details', '', true, 'dialog-1024-768');

	this.mPageTabContainer = $('<div class="l-tab-container"/>');
    this.mDialogContainer.findDialogTabContainer().append(this.mPageTabContainer);

	this.mContentContainer = this.mDialogContainer.findDialogContentContainer();

	this.createButtonBar();
	this.createTableHeaderSpaceForEventPoolContainer();
	this.createTableHeaderSpaceForEventCooldownContainer();
	this.createTableHeaderSpaceForEventInfoContainer();
	this.createEventPoolContainer();
	this.createEventCooldownContainer();
	this.createEventInfoContainer();
	this.createFilterBar();
	this.createFooter();

	this.mIsVisible = false;
};

EventInfoScreen.prototype.createButtonBar = function () 
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

	layout = $('<div class="l-tab-button"/>');
    this.mPageTabContainer.append(layout);
    var eventInfoButton = layout.createTabTextButton("Info", function ()
    {
        self.switchToEventInfoPanel();
    }, null, '', 7);

	eventPoolButton.addClass('is-selected');

	eventPoolButton.attr("id", "emi-event-pool-button");
	eventCooldownButton.attr("id", "emi-event-cooldown-button");
	eventInfoButton.attr("id", "emi-event-info-button");
}

EventInfoScreen.prototype.createTableHeaderSpaceForEventPoolContainer = function ()
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

EventInfoScreen.prototype.createTableHeaderSpaceForEventCooldownContainer = function ()
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

EventInfoScreen.prototype.createTableHeaderSpaceForEventInfoContainer = function ()
{
	// var self = this;
	// this.mEventInfoHeaderContent = $('<div id="emi-event-info-header-content" class="emi-content-header"/>')
	// 	.appendTo(this.mContentContainer)
	// 	.hide();

	// var summaryContent = $('<div class="emi-event-summary"/>');
	// this.mEventInfoHeaderContent.append(summaryContent);

	// var pageDescription = $('<span class="emi-event-summary-content title-font-normal font-color-description"></span>')
	// 	.appendTo(summaryContent);
}

EventInfoScreen.prototype.createEventPoolContainer = function ()
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

EventInfoScreen.prototype.createEventCooldownContainer = function ()
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

EventInfoScreen.prototype.createEventInfoContainer = function()
{
	this.mEventInfoContainer = $('<div id="emi-event-info-container" class="emi-info-content-container"/>')
		.hide();
	this.mContentContainer.append(this.mEventInfoContainer);

	this.mEventInfoScrollContainer = $('<div id="emi-event-info-scroll-container" class="emi-scroll-container"/>')
	.appendTo(this.mEventInfoContainer);

	var table = $('<table class="emi-info-table"/>')
		.appendTo(this.mEventInfoScrollContainer);

	var row = $('<tr />')
		.appendTo(table);

	var cell1 = $('<td class="emi-info-cell" />')
		.appendTo(row);

	var cell2 = $('<td class="emi-info-cell" />')
		.appendTo(row);

	var lastEventDayTile = $('<div class="emi-tile"/>')
		.appendTo(cell1);
	var lastEventDayHeader = $('<p class="emi-tile-header font-color-description font-bold title-font-normal">Last Event on Day</p>')
		.appendTo(lastEventDayTile);
	var lastEventDayText = $('<p id="emi-last-event-day" class="emi-tile-text font-color-description title-font-small">0</p>')
		.appendTo(lastEventDayTile);

	var anyNewsTile = $('<div class="emi-tile"/>')
		.appendTo(cell2);
	var anyNewsHeader = $('<p class="emi-tile-header font-color-description font-bold title-font-normal">Any News</p>')
		.appendTo(anyNewsTile);
	var anyNewsText = $('<p id="emi-any-news" class="emi-tile-text font-color-description title-font-small">No</p>')
		.appendTo(anyNewsTile);

	anyNewsTile.bindTooltip({contentType: 'msu-generic', modId: this.mModId, elementId: "EventInfo.NewsList"});

	row = $('<tr />')
		.appendTo(table);

	cell1 = $('<td class="emi-info-cell" />')
		.appendTo(row);

	cell2 = $('<td class="emi-info-cell" />')
		.appendTo(row);

	var fourTileCheckTile = $('<div class="emi-tile"/>')
		.appendTo(cell1);
	var fourTileCheckHeader = $('<p class="emi-tile-header font-color-description font-bold title-font-normal">Too close to a hostile entity</p>')
		.appendTo(fourTileCheckTile);
	var fourTileCheckText = $('<p id="emi-within-4-tiles" class="emi-tile-text font-color-description title-font-small">No</p>')
		.appendTo(fourTileCheckTile);

	var currentTileTile = $('<div class="emi-tile"/>')
		.appendTo(cell2);
	var currentTileHeader = $('<p class="emi-tile-header font-color-description font-bold title-font-normal">Current Tile</p>')
		.appendTo(currentTileTile);
	var currentTileText = $('<p id="emi-current-tile" class="emi-tile-text font-color-description title-font-small">NA</p>')
		.appendTo(currentTileTile);

	row = $('<tr />')
		.appendTo(table);

	cell1 = $('<td class="emi-info-cell" />')
		.appendTo(row);

	var currentTerrainTile = $('<div class="emi-tile"/>')
		.appendTo(cell1);
	var currentTerrainHeader = $('<p class="emi-tile-header font-color-description font-bold title-font-normal">Current Terrain</p>')
		.appendTo(currentTerrainTile);
	var currentTerrainText = $('<p id="emi-current-terrain" class="emi-tile-text font-color-description title-font-small">NA</p>')
		.appendTo(currentTerrainTile);

	this.mEventInfoContainer.aciScrollBar({
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

EventInfoScreen.prototype.createFilterBar = function()
{
	var filterContainer = $('<div id="emi-filter-row" class="emi-overview-filter-container"/>')
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

EventInfoScreen.prototype.createFooter = function ()
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

	var version = $('<span class="emi-footer-version-number font-color-description font-bold title-font-normal">Version 0.9.9</span>')
	this.mDialogContainer.findDialogFooterContainer().append(version);
}
///
/// End creation of HTML elements
///

///
/// Begin adding data
///
EventInfoScreen.prototype.populateEventsContainer = function(_data)
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

EventInfoScreen.prototype.populateEventCooldownContainer = function(_data)
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
		return a.firedOnNumber - b.firedOnNumber;
	});

	$.each(eventList, function (_, _eventData) {
		var eventDIv = self.createEventOnCooldownRow(_eventData);
		self.mEventCooldownScrollContainer.append(eventDIv);
	});
}

EventInfoScreen.prototype.populateSummary = function(_data) 
{
	var broChance = 1.0;

	if (_data.AllScores > 0) {
		broChance = (_data.EventBroHireScore / _data.AllScores * 1.0 * 100.0);
	}

	var text = "Chance for a brother event to fire: " + broChance.toFixed(2) + "% " + "(" + _data.EventBroHireScore + " / " + _data.AllScores.toFixed(0) + ")";
	$("#emi-chance-for-a-brother").text(text);
}

EventInfoScreen.prototype.createEventInPoolRow = function(_eventData)
{
	var iconField = $("<div class='emi-event-item-icon-container'/>");
	var image = $('<img class="emi-event-item-icon"/>');
    image.attr('src', Path.GFX + _eventData.icon);
	iconField.append(image);

	image.bindTooltip({contentType: 'msu-generic', modId: this.mModId, elementId: "EventPool.IconTooltip", eventId: _eventData.id, background: _eventData.background});

	var eventName = _eventData.name;
	var eventScore = 0;
	var eventCooldown = 0;

	if (_eventData.chanceForBrother < 100) {
		eventName = eventName + " (" + _eventData.chanceForBrother + "% Chance)";
	}

	if (_eventData.score != null && _eventData.score >= 0) {
		eventScore = _eventData.score.toFixed(0);
	}

	if (_eventData.cooldown != null && _eventData.cooldown >= 0) {
		eventCooldown = _eventData.cooldown.toFixed(0);
	}

	var nameField = $("<div class='emi-event-item-name title-font-normal font-bold font-color-description'>" + eventName + "</div>");
	var scoreField = $("<div class='emi-event-item-score title-font-normal font-bold font-color-description'>" + eventScore + "</div>");
	var cooldownField = $("<div class='emi-event-item-cooldown title-font-normal font-bold font-color-description'>" + eventCooldown + "</div>");
	
	if (_eventData.mayGiveBrother) {
		nameField.addClass('brother-highlight').addClass('emi-is-brother-event');
		scoreField.addClass('brother-highlight');
		cooldownField.addClass('brother-highlight'); 
	}

	var eventContainer = $('<div class="emi-event-container"/>')
		.attr('data-event-name', _eventData.name)
		.attr('is-bro-event', _eventData.isBroEvent)
		.attr('crises-event', _eventData.isCrisesEvent)
		.append(iconField)
		.append(nameField)
		.append(scoreField)
		.append(cooldownField);

	return eventContainer;
}

EventInfoScreen.prototype.createEventOnCooldownRow = function(_eventData)
{
	var onCooldownUntilDay = 0;
	var iconField = $("<div class='emi-cooldown-item-icon-container'/>");
	var image = $('<img class="emi-event-item-icon"/>');
    image.attr('src', Path.GFX + _eventData.icon);
	iconField.append(image);

	image.bindTooltip({contentType: 'msu-generic', modId: this.mModId, elementId: "EventPool.IconTooltip", eventId: _eventData.id, background: _eventData.background});

	if (_eventData.onCooldownUntilDay != null && _eventData.onCooldownUntilDay >= 0) {
		onCooldownUntilDay = _eventData.onCooldownUntilDay.toFixed(0);
	}

	var nameField = $("<div class='emi-cooldown-item-name title-font-normal font-bold font-color-description'>" + _eventData.name + "</div>");
	var firedOnField = $("<div class='emi-cooldown-item-fired-on title-font-normal font-bold font-color-description'>" + _eventData.firedOnDay + "</div>");
	var onCooldownField = $("<div class='emi-cooldown-item-cooldown-until-day title-font-normal font-bold font-color-description'>" + onCooldownUntilDay + "</div>");

	if (_eventData.mayGiveBrother) {
		nameField.addClass('brother-highlight').addClass('emi-is-brother-event');
		firedOnField.addClass('brother-highlight');
		onCooldownField.addClass('brother-highlight'); 
	}

	var eventContainer = $('<div class="emi-event-container"/>')
		.attr('data-event-name', _eventData.name)
		.attr('is-bro-event', _eventData.isBroEvent)
		.attr('on-cooldown-until-day', _eventData.onCooldownUntilDayNumber)
		.append(iconField)
		.append(nameField)
		.append(firedOnField)
		.append(onCooldownField);
	
	return eventContainer;
}

EventInfoScreen.prototype.populateEventInfoFields = function(_data) 
{
	$("#emi-last-event-day").text(_data.LastEventDayAndHour);
	$("#emi-any-news").text(_data.AnyNews);
	$("#emi-within-4-tiles").text(_data.EnemyWithin4Tiles);
	$("#emi-current-tile").text(_data.CurrentTile);
	$("#emi-current-terrain").text(_data.CurrentTerrain);
}
///
/// End adding data
///

///
/// Begin button press functions
///
EventInfoScreen.prototype.onLeaveButtonPressed = function()
{
	this.notifyBackendToCloseUI();
}

EventInfoScreen.prototype.switchToEventsInPoolPanel = function ()
{
	this.mVisibleContainer = this.mEventPoolScrollContainer;

	this.setActiveButton('emi-event-pool-button');
	this.toggleFilterRow(true);
	this.clearFilter();
	this.setContentFocus('emi-event-pool');
	this.filterEvents();
}

EventInfoScreen.prototype.switchToEventsOnCooldownPanel = function () 
{
	this.mVisibleContainer = this.mEventCooldownScrollContainer;

	this.setActiveButton('emi-event-cooldown-button');
	this.toggleFilterRow(true);
	this.clearFilter();
	this.setContentFocus('emi-event-cooldown');
	this.filterEvents();
}

EventInfoScreen.prototype.switchToEventInfoPanel = function () 
{
	this.mVisibleContainer = this.mEventInfoScrollContainer;

	this.setActiveButton('emi-event-info-button');
	this.toggleFilterRow(false);
	this.clearFilter();
	this.setContentFocus('emi-event-info');
}

EventInfoScreen.prototype.setActiveButton = function(_buttonId)
{
	var buttons = [
		"emi-event-pool-button",
		"emi-event-cooldown-button",
		"emi-event-info-button"
	];

	$.each(buttons, function(_, _id) {
		if (_id == _buttonId) {
			$('#' + _id).addClass("is-selected");
		}
		else {
			$('#' + _id).removeClass("is-selected");
		}
	});
}

EventInfoScreen.prototype.clearFilter = function()
{
	this.mNameFilterInput.val("");
	this.mEventFilterText = "";
	this.mEventPoolScrollContainer.find(".emi-event-container").show();
	this.mEventCooldownScrollContainer.find(".emi-event-container").show();
}

EventInfoScreen.prototype.toggleFilterRow = function(_show) 
{
	if (_show) {
		$('#emi-filter-row').show();
	}
	else {
		$('#emi-filter-row').hide();
	}
}

EventInfoScreen.prototype.setContentFocus = function(_sectionIdStart)
{
	var sectionIds = [
		"emi-event-cooldown-container",
		"emi-event-cooldown-header-content",
		"emi-event-pool-container",
		"emi-event-pool-header-content",
		"emi-event-info-container",
		"emi-event-info-header-content"
	];

	$.each(sectionIds, function(_, _id) {
		if (_id.indexOf(_sectionIdStart) == 0) {
			$("#" + _id).show();
		}
		else {
			$("#" + _id).hide();
		}
	});
}
///
/// End button press functions
///

///
/// Begin utility functions
///
EventInfoScreen.prototype.showMessage = function(_container, _message)
{
	return; //do nothing for now -
	_container.find('.emi-content-message')
		.text(_message)
		.show();
}

EventInfoScreen.prototype.hideMessage = function(_container) 
{
	return; //do nothing for now -
	_container.find('.emi-content-message')
		.hide();
}

EventInfoScreen.prototype.filterEvents = function()
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

EventInfoScreen.prototype.toggleObscuringCrisesEvents = function() 
{
	var obscureCrisesEvents = this.mObscureCrisesEvents;

	this.mEventPoolScrollContainer.find(".emi-event-container").each(function() {
		if (obscureCrisesEvents && $(this).attr("crises-event") == "true" && $(this).attr("is-bro-event") === "false") {
			$(this).find(".emi-event-item-name").text("Crises Event")
		}
		else if (!obscureCrisesEvents && $(this).attr("crises-event") == "true") {
			$(this).find(".emi-event-item-name").text($(this).attr("data-event-name"));
		}
	})
}

EventInfoScreen.prototype.setDefaultsPerMSUISettings = function() 
{
	var showOnlyBroEvents = false; 
	var hide9999CooldownEvents = true; 
	var obscureCrisesEvents = true;

	try {
		showOnlyBroEvents = MSU.getSettingValue(this.mModId, "DefaultOnlyShowBroEvents");
		hide9999CooldownEvents = MSU.getSettingValue(this.mModId, "DefaultHide9999Events");
		obscureCrisesEvents = MSU.getSettingValue(this.mModId, "ObscureCrisesEvents");
	} catch (error) {
		console.log("Error while getting MSU settings for Event Info mod" + error);
	}

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
EventInfoScreen.prototype.createCustomTabButton = function(_text, _callback, _classes)
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
EventInfoScreen.prototype.bindTooltips = function ()
{

};

EventInfoScreen.prototype.unbindTooltips = function ()
{

};
///
/// End tooltips
///

///
/// Begin popupDialog functions
///
// EventInfoScreen.prototype.setPopupDialog = function ( _dialog )
// {
// 	this.mPopupDialog = _dialog;
// 	this.notifyBackendPopupVisible(true);
// };

// EventInfoScreen.prototype.destroyPopupDialog = function ()
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
EventInfoScreen.prototype.notifyBackendToCloseUI = function ()
{
    if (this.mSQHandle !== null)
    {
        SQ.call(this.mSQHandle, 'onCloseButtonPressed');
    }
}
///
/// End backend notification functions
///

registerScreen("EventInfoScreen", new EventInfoScreen());