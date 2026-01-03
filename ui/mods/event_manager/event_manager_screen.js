"use strict";
var EventManagerScreen = function (_parent)
{
	MSUUIScreen.call(this);
	//this.mEventListener = null;
	this.mContainer = null;
	this.mContentContainer = null;
	this.mContentScrollContainer = null;
	//this.mPopupDialog = null;
	this.mEventList = null;
	this.mID = "EventManagerScreen";
};

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

EventManagerScreen.prototype.show = function (_data)
{
	if (_data != null) {
		//this.initScrollContainer();
		this.createContent(_data);
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

EventManagerScreen.prototype.createDIV = function (_parentDiv)
{
	var self = this;
	
	this.mContainer = $("<div class='emi-overview-screen'/>")
		.appendTo(_parentDiv)
		.hide();
	$('<div class="emi-overview-title title-font-very-big font-bold font-color-title">Events in the Queue</div>')
		.appendTo(this.mContainer);

	this.mContentContainer  = $('<div class="emi-overview-content-container"/>');
	this.mContainer.append(this.mContentContainer);

	this.initScrollContainer();

	this.mContentContainer.aciScrollBar({
	         delta: 2,
	         lineDelay: 0,
	         lineTimer: 0,
	         pageDelay: 0,
	         pageTimer: 0,
	         bindKeyboard: false,
	         resizable: false,
	         smoothScroll: true
	   });

	// var filterContainer = $('<div class="emi-overview-filter-container"/>')
	// 	.appendTo(this.mContainer);
	// this.createFilterBar(filterContainer);

	var footer = $('<div class="emi-overview-footer"/>')
		.appendTo(this.mContainer);
    this.mLeaveButton = footer.createTextButton("Leave", $.proxy(function()
	{
        this.onLeaveButtonPressed();
    }, this), null, 1);
};

EventManagerScreen.prototype.initScrollContainer = function ()
{
	this.mContentScrollContainer = $('<div class="emi-scroll-container"/>')
	.appendTo(this.mContentContainer);
}

EventManagerScreen.prototype.createContent = function(_data)
{
	var self = this;
	this.mEventList = _data;

	if (this.mContentScrollContainer.children().length > 0) {
		this.mContentScrollContainer.empty();
	}

	$.each(this.mEventList, function(_, _eventData)
	{
		var collectionDiv = self.createEventSection(_eventData);
		self.mContentScrollContainer.append(collectionDiv)
	})
}

EventManagerScreen.prototype.createEventSection = function(_eventData)
{
	var self = this;
	var eventContainer = $('<div class="emi-event-container"/>')
		.append($("<div class='emi-event-item-name title-font-normal font-bold font-color-brother-name'>" + _eventData.name + "</div>"))
		.append($("<div class='emi-event-item-score title-font-normal font-bold font-color-brother-name'>" + _eventData.score + "</div>"))
	
	// $.each(_perkGroupCollection.PerkGroups, function(_perkGroupID, _perkGroupData)
	// {
	// 	perkGroupCollectionContainer.append(self.createPerkGroupRow(_perkGroupData));
	// })
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