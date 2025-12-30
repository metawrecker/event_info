var EventScreen = function ()
{
	MSUUIScreen.call(this);
	//this.mEventListener = null;
	this.mContentContainer = null;
	this.mPopupDialog = null;
	this.mID = "EventScreen";
};

EventScreen.prototype = Object.create(MSUUIScreen.prototype);
Object.defineProperty(EventScreen.prototype, 'constructor', {
	value: EventScreen,
	enumerable: false,
	writable: true
});

EventScreen.prototype.create = function(_parentDiv)
{
	this.createDIV(_parentDiv);
	//this.bindTooltips();
};

EventScreen.prototype.createDIV = function (_parentDiv)
{

};

// EventScreen.prototype.registerEventListener = function (_listener)
// {
// 	this.mEventListener = _listener;
// };

EventScreen.prototype.onConnection = function (_handle, _parentDiv)
{
	_parentDiv = _parentDiv || $('.root-screen');
    this.mSQHandle = _handle;
    this.register(_parentDiv);
};

EventScreen.prototype.onDisconnection = function ()
{
    this.mSQHandle = null;
    this.unregister();
};

EventScreen.prototype.destroyDIV = function ()
{
	this.mContainer.empty();
	this.mContainer.remove();
	this.mContainer = null;
};

// EventScreen.prototype.bindTooltips = function ()
// {

// };

// EventScreen.prototype.unbindTooltips = function ()
// {

// };

EventScreen.prototype.show = function (_data)
{
	var self = this;
	var moveTo = { opacity: 1};
	var offset = -this.mContainer.width();
	// if (_moveLeftRight === true)
	// {
	// 	moveTo = { opacity: 1, left: '0', right: '0' };
	// 	var offset = -(this.mContentContainer.width());
	// 	if (_considerParent === true && this.mContentContainer.parent() !== null && this.mContentContainer.parent() !== undefined)
	// 	{
	// 		offset -= this.mContentContainer.parent().width()
	// 	}
	// 	this.mContentContainer.css('left', offset);
	// }
	this.mContainer.velocity("finish", true).velocity(moveTo,
	{
		duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
		easing: 'swing',
		begin: function ()
		{
			$(this).removeClass('display-none').addClass('display-block');
			self.notifyBackendOnAnimating();
		},
		complete: function ()
		{
			self.mIsVisible = true;
			self.notifyBackendOnShown();
		}
	});
	this.onShow();
};

EventScreen.prototype.hide = function ()
{
	var self = this;
	var moveTo = { opacity: 0};
	var offset = -this.mContainer.width();
	// if (_moveLeftRight === true)
	// {
	// 	var offset = -(this.mContentContainer.width());
	// 	if (_considerParent === true && this.mContentContainer.parent() !== null && this.mContentContainer.parent() !== undefined)
	// 	{
	// 		offset -= this.mContentContainer.parent().width()
	// 	}
	// 	moveTo["left"] = offset;
	// }
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
			$(this).removeClass('display-block').addClass('display-none');
			self.notifyBackendOnHidden();
		}
	});
	this.onHide();
};

EventScreen.prototype.onShow = function()
{
};

EventScreen.prototype.onHide = function()
{
};



EventScreen.prototype.destroy = function()
{
	//this.unbindTooltips();
	this.destroyDIV();
};

EventScreen.prototype.register = function (_parentDiv)
{
	console.log(this.mID + '::REGISTER');

	if (this.mContainer !== null)
	{
		console.error("ERROR: Failed to register " + this.mID + ". Reason: " + this.mID + " is already initialized.");
		return;
	}

	if (_parentDiv !== null && typeof(_parentDiv) == 'object')
	{
		this.create(_parentDiv);
	}
};

EventScreen.prototype.unregister = function ()
{
	console.log(this.mID +'::UNREGISTER');

	if (this.mContainer === null)
	{
		console.error("ERROR: Failed to unregister " + this.mID + ". Reason: " + this.mID + " is not initialized.");
		return;
	}

	this.destroy();
};

EventScreen.prototype.isRegistered = function ()
{
	if (this.mContainer !== null)
	{
		return this.mContainer.parent().length !== 0;
	}

	return false;
};

EventScreen.prototype.showBackgroundImage = function ()
{

};

EventScreen.prototype.setPopupDialog = function ( _dialog )
{
	this.mPopupDialog = _dialog;
	this.notifyBackendPopupVisible(true);
};

EventScreen.prototype.destroyPopupDialog = function ()
{
	if(this.mPopupDialog !== null)
	{
		this.mPopupDialog.destroyPopupDialog();
		this.mPopupDialog = null;
	}
	this.notifyBackendPopupVisible(false);
};

EventScreen.prototype.notifyBackendPopupVisible = function ( _data )
{
	SQ.call(this.mSQHandle, 'onPopupVisible', _data);
};

//Notify backend Functions
EventScreen.prototype.notifyBackendOnShown = function ()
{
	if (this.mSQHandle !== null)
	{
		SQ.call(this.mSQHandle, 'onScreenShown');
	}
};

EventScreen.prototype.notifyBackendOnHidden = function ()
{
	if (this.mSQHandle !== null)
	{
		SQ.call(this.mSQHandle, 'onScreenHidden');
	}
};

EventScreen.prototype.notifyBackendOnAnimating = function ()
{
	if (this.mSQHandle !== null)
	{
		SQ.call(this.mSQHandle, 'onScreenAnimating');
	}
};

registerScreen("EventScreen", new EventScreen());