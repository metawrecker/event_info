"use strict";
var EventManagerScreen = function (_parent)
{
	MSUUIScreen.call(this);
	this.mContainer = null;
	this.mEventPoolContainer = null;
	this.mEventPoolScrollContainer = null;
	this.mEventCooldownContainer = null;
	this.mEventCooldownScrollContainer = null;
	this.mEventData = null;
	//this.mTotalScore = 0;
	this.mID = "EventManagerScreen";
	//this.mHeader = "Events in Queue";
};

/*
	{
		BroHireEventsInPool = [{
			id = "",
			name = "",
			score = 0,
			cooldown = 0,
			mayGiveBrother = true
		}],
		NonBroHireEventsInPool = [{
			id = "",
			name = "",
			score = 0,
			cooldown = 0,
			mayGiveBrother = false
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

EventManagerScreen.prototype.create = function(_parentDiv)
{
	this.createDIV(_parentDiv);
	//this.bindTooltips();
};

EventManagerScreen.prototype.createDIV = function (_parentDiv)
{
	var self = this;
	
	this.mContainer = $("<div class='emi-screen'/>")
		.appendTo(_parentDiv)
		.hide();
	
	this.createHeader();
	this.createButtonBar();
	this.createEventPoolContainer();
	this.createEventCooldownContainer();
	this.createFilterBar();
	this.createFooter();
};

EventManagerScreen.prototype.createHeader = function ()
{
	$('<div id="emi-header" class="emi-title title-font-very-big font-bold font-color-title">Available Events</div>')
		.appendTo(this.mContainer);
}

EventManagerScreen.prototype.createButtonBar = function () 
{
	var self = this
	this.mPageTabContainer = $('<div class="emi-tab-button-bar"/>');
	this.mContainer.append(this.mPageTabContainer);

	var eventPoolButton = this.createEmiCustomButton(function(_button) {
		self.switchToEventsInPoolPanel();
	}, 'emi-tab-button');

	var eventCooldownButton = this.createEmiCustomButton(function(_button) {
		self.switchToEventsOnCooldownPanel();
	}, 'emi-tab-button');

	// var eventPoolButton = this.mPageTabContainer.createCustomButton(null, function (_button)
	// {
	// 	self.switchToEventsInPoolPanel();
	// }, 'emi-tab-button', 9);

	// var eventCooldownButton = this.mPageTabContainer.createCustomButton(null, function (_button)
	// {
	// 	self.switchToEventsOnCooldownPanel();
	// }, 'emi-tab-button', 9);

	eventPoolButton.text("Available Events");
	//eventPoolButton.removeClass('button');
	eventCooldownButton.text("Events on Cooldown");
	//eventCooldownButton.removeClass('button');

	eventPoolButton.addClass('is-selected');

	this.mPageTabContainer.append(eventPoolButton);
	this.mPageTabContainer.append(eventCooldownButton);


	// var layout = $('<div class="emi-tab-button"/>');
	// this.mPageTabContainer.append(layout);

	// var button = this.mListScrollContainer.createCustomButton(null, function (_button)
	// {
	// 	self.switchToPanel(_panel);
	// 	self.switchToFirstPage(_panel);
	// }, 'msu-button');

	// button.text(_panel.name);
	// button.removeClass('button');

	// var eventsInQueueButton = layout.createCustomButton('Active Queue', function () 
	// {
	// 	self.switchToEventsInPoolPanel();
	// }, null, null, 7);

	// eventsInQueueButton.click();

	// layout = $('<div class="emi-tab-button"/>');
	// this.mPageTabContainer.append(layout);
	// var eventsOnCooldownButton = layout.createCustomButton('Events On Cooldown', function () 
	// {
	// 	self.switchToEventsOnCooldownPanel();
	// }, null, null, 7);
}

EventManagerScreen.prototype.createEmiCustomButton = function (_callback, _classes) 
{
	var result = $('<div class="ui-control emi-custom-button text-font-normal"/>');

    // if (_size === undefined)
    //     result = $('<div class="ui-control button text-font-normal"/>');
    // else
    //     result = $('<div class="ui-control button-' + _size + ' text-font-normal"/>');

    if (_classes !== undefined && _classes !== null && typeof(_classes) === 'string')
    {
        result.addClass(_classes);
    }

    // if (_content !== undefined && _content !== null && typeof(_content) === 'object')
    // {
    //     result.append(_content);
    // }

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

    //this.append(result);

    return result;
}

EventManagerScreen.prototype.createEventPoolContainer = function ()
{
	this.mEventPoolContainer = $('<div id="emi-event-pool-container" class="emi-content-container"/>');
	this.mContainer.append(this.mEventPoolContainer);

	var summaryContent = $('<div class="emi-event-summary"/>');
	this.mEventPoolContainer.append(summaryContent);

	var totalScoreSpan = $('<span id="emi-total-score" class="title-font-normal font-color-subtitle">Total Event Score ' + 0 + '</span>')
	.appendTo(summaryContent);

	var brotherScoreSpan = $('<span id="emi-brother-score" class="title-font-normal font-color-subtitle">Total Brother Score ' + 0 + '</span>')
	.appendTo(summaryContent);

	var tableHeader = $('<div class="emi-table-header"/>');
	this.mEventPoolContainer.append(tableHeader);

	tableHeader
	.append($("<div class='emi-event-item-name title-font-big font-bold font-color-brother-name'>Event Name</div>"))
	.append($("<div class='emi-event-item-score title-font-big font-bold font-color-brother-name'>Score</div>"));

	this.mEventPoolScrollContainer = $('<div class="emi-scroll-container"/>')
	.appendTo(this.mEventPoolContainer);

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

	var tableHeader = $('<div class="emi-table-header"/>');
	this.mEventCooldownContainer.append(tableHeader);

	tableHeader
	.append($("<div class='emi-cooldown-item-name title-font-big font-bold font-color-brother-name'>Event Name</div>"))
	.append($("<div class='emi-cooldown-item-fired-on title-font-big font-bold font-color-brother-name'>Fired on Day</div>"))
	.append($("<div class='emi-cooldown-item-cooldown-until-day title-font-big font-bold font-color-brother-name'>Available On Day</div>"));

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
    var name = $('<span class="title-font-normal font-color-subtitle">Filter by name</span>')
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
                // if (currentInput == "")
                // {
                //     self.mContentScrollContainer.find(".dpf-l-perk-container").show();
                //     self.mContentScrollContainer.find(".dpf-overview-perks-row").show();
                // }
                // else
                // {
                //     self.mContentScrollContainer.find('.dpf-l-perk-container[data-perktype="perk"]').each(function(){
                //         if ($(this).attr("data-perkname").toLowerCase().search(currentInput) == -1)
                //         {
                //             $(this).hide();
                //         }
                //         else
                //         {
                //             $(this).show();
                //             $(this).parent().parent().show(); // show perk row otherwise it won't reset
                //         }
                //     })
                //     self.mContentScrollContainer.find(".dpf-overview-perks-row").each(function(){
                //         var visibleChildren = $(this).find('.dpf-l-perk-container[data-perktype="perk"]:visible');
                //         if (visibleChildren.length == 0)
                //             $(this).hide()
                //         else $(this).show()
                //     })
                // }
            })
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




EventManagerScreen.prototype.show = function (_data)
{
	if (_data != null) {
		this.mEventData = _data;

		//this.mTotalScore = _data.AllScores;
		
		this.populateSummary(_data);
		this.populateEventsContainer(_data);
		this.populateEventCooldownContainer(_data);
	}

	var self = this;
	var moveTo = { opacity: 1};
	//var offset = -this.mContainer.width();
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
	var moveTo = { opacity: 0};

	//need to reset the form...
	/*
		clear filters
		move back to event pool page

	*/

	//var offset = -this.mContainer.width();
	this.mContainer.velocity("finish", true).velocity(moveTo,
	{
		duration: Constants.SCREEN_FADE_IN_OUT_DELAY,
		easing: 'swing',
		begin: function()
		{
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



// EventManagerScreen.prototype.initScrollContainer = function ()
// {

// }

EventManagerScreen.prototype.populateEventsContainer = function(_data)
{
	var self = this;

	if (this.mEventPoolScrollContainer.children().length > 0) {
		this.mEventPoolScrollContainer.empty();
	}

	var eventList = this.mEventData.BroHireEventsInPool.concat(this.mEventData.NonBroHireEventsInPool);

	eventList.sort(function (a, b) {
		return a.name.localeCompare(b.name);
	});

	$.each(eventList, function (_, _eventData) {
		var collectionDiv = self.createEventInPoolSection(_eventData);
		self.mEventPoolScrollContainer.append(collectionDiv);
	});
}

EventManagerScreen.prototype.populateEventCooldownContainer = function(_data)
{
	var self = this;

	if (this.mEventCooldownScrollContainer.children().length > 0) {
		this.mEventCooldownScrollContainer.empty();
	}

	var eventList = this.mEventData.EventsOnCooldown;

	eventList.sort(function(a,b) {
		return a.firedOnDay > b.firedOnDay;
	});

	$.each(eventList, function (_, _eventData) {
		var eventDIv = self.createEventOnCooldownSection(_eventData);
		self.mEventCooldownScrollContainer.append(eventDIv);
	});
}

EventManagerScreen.prototype.populateSummary = function(_data) 
{
	var broChance = 1.0;

	if (_data.AllScores > 0) {
		broChance = (_data.EventBroHireScore / _data.AllScores * 1.0);
	}

	$("#emi-total-score").text("Total Event Score: " + _data.AllScores + "     ");
	$("#emi-brother-score").text("Brother Event Score: " + _data.EventBroHireScore + " (" + broChance.toFixed(2) + "%)");
}

EventManagerScreen.prototype.createEventInPoolSection = function(_eventData)
{
	var eventContainer = $('<div class="emi-event-container"/>')
		.append($("<div class='emi-event-item-name title-font-normal font-bold font-color-brother-name'>" + _eventData.name + "</div>"))
		.append($("<div class='emi-event-item-score title-font-normal font-bold font-color-brother-name'>" + _eventData.score + "</div>"));

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

	var eventContainer = $('<div class="emi-event-container"/>')
		.append($("<div class='emi-cooldown-item-name title-font-normal font-bold font-color-brother-name'>" + _eventData.name + "</div>"))
		.append($("<div class='emi-cooldown-item-fired-on title-font-normal font-bold font-color-brother-name'>" + firedOnDay + "</div>"))
		.append($("<div class='emi-cooldown-item-cooldown-until-day title-font-normal font-bold font-color-brother-name'>" + onCooldownUntilDay + "</div>"));
	return eventContainer;
}

// EventManagerScreen.prototype.registerEventListener = function (_listener)
// {
// 	this.mEventListener = _listener;
// };

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
	this.mContainer.empty();
	this.mContainer.remove();
	this.mContainer = null;
};

EventManagerScreen.prototype.onLeaveButtonPressed = function()
{
	this.hide();
}

EventManagerScreen.prototype.switchToEventsOnCooldownPanel = function () 
{
	//this.mHeader = "Events in Queue";
	$("#emi-header").text("Events on Cooldown");
	$("#emi-event-pool-container").hide();
	$("#emi-event-cooldown-container").show();

}

EventManagerScreen.prototype.switchToEventsInPoolPanel = function ()
{
	//this.mHeader = "Events on Cooldown";
	$("#emi-header").text("Available Events");
	$("#emi-event-cooldown-container").hide();
	$("#emi-event-pool-container").show();

}

// EventManagerScreen.prototype.bindTooltips = function ()
// {

// };

// EventManagerScreen.prototype.unbindTooltips = function ()
// {

// };



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

// EventManagerScreen.prototype.register = function (_parentDiv)
// {
// 	console.log(this.mID + '::REGISTER');

// 	if (this.mContainer !== null)
// 	{
// 		console.error("ERROR: Failed to register " + this.mID + ". Reason: " + this.mID + " is already initialized.");
// 		return;
// 	}

// 	if (_parentDiv !== null && typeof(_parentDiv) == 'object')
// 	{
// 		this.create(_parentDiv);
// 	}
// };

// EventManagerScreen.prototype.unregister = function ()
// {
// 	console.log(this.mID +'::UNREGISTER');

// 	if (this.mContainer === null)
// 	{
// 		console.error("ERROR: Failed to unregister " + this.mID + ". Reason: " + this.mID + " is not initialized.");
// 		return;
// 	}

// 	this.destroy();
// };

// EventManagerScreen.prototype.isRegistered = function ()
// {
// 	if (this.mContainer !== null)
// 	{
// 		return this.mContainer.parent().length !== 0;
// 	}

// 	return false;
// };

// EventManagerScreen.prototype.showBackgroundImage = function ()
// {

// };

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

EventManagerScreen.prototype.notifyBackendPopupVisible = function ( _data )
{
	if (this.mSQHandle !== null)
	{
		SQ.call(this.mSQHandle, 'onPopupVisible', _data);
	}
};

//Notify backend Functions
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

registerScreen("EventManagerScreen", new EventManagerScreen());