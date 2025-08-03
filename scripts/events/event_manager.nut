this.event_manager <- {
	m = {
		LastEventTime = 0.0,
		LastCheckTime = 0.0,
		LastEventID = "",
		Events = [],
		SpecialEvents = [],
		ActiveEvent = null,
		Thread = null,
		VictoryScreen = null,
		DefeatScreen = null,
		ForceScreen = null,
		LastBattleTime = 0,
		IsEventShown = false
	},
	function hasActiveEvent()
	{
		return this.m.ActiveEvent != null;
	}

	function getLastBattleTime()
	{
		return this.m.LastBattleTime;
	}

	function getLastEventID()
	{
		return this.m.LastEventID;
	}

	function updateBattleTime()
	{
		this.m.LastBattleTime = this.Time.getVirtualTimeF();
		this.m.Thread = null;
	}

	function resetLastEventTime()
	{
		this.m.LastEventTime = -9000.0;
		this.m.LastCheckTime = -9000.0;
	}

	function addSpecialEvent( _e )
	{
		this.m.SpecialEvents.push(_e);
	}

	function getEvent( _id )
	{
		foreach( event in this.m.Events )
		{
			if (event.getID() == _id)
			{
				return event;
			}
		}

		return null;
	}

	function create()
	{
		local scriptFiles = this.IO.enumerateFiles("scripts/events/events/");

		foreach( i, scriptFile in scriptFiles )
		{
			this.m.Events.push(this.new(scriptFile));
		}

		if (this.Const.DLC.Desert)
		{
			this.addSpecialEvent("event.manhunters_origin_capture_prisoner");
		}

		this.addSpecialEvent("event.helped_caravan");
		this.m.LastEventTime = this.Time.getVirtualTimeF();
	}

	function fire( _id, _update = true )
	{
		if (this.m.ActiveEvent != null && this.m.ActiveEvent.getID() != _id)
		{
			this.logInfo("Failed to fire event - another event with id \'" + this.m.ActiveEvent.getID() + "\' is already queued.");
			return false;
		}

		local event = this.getEvent(_id);

		if (event != null)
		{
			if (_update)
			{
				event.update();
			}

			this.m.ActiveEvent = event;
			this.m.ActiveEvent.fire();

			if (this.World.State.showEventScreen(this.m.ActiveEvent))
			{
				return true;
			}
			else
			{
				this.m.ActiveEvent.clear();
				this.m.ActiveEvent = null;
				return false;
			}
		}
		else
		{
			this.logInfo("Failed to fire event - with id \'" + _id + "\' not found.");
			return false;
		}
	}

	function canFireEvent( _ignoreEvaluating = false, _ignorePreviousBattle = false )
	{
		if (this.World.State.getMenuStack().hasBacksteps() || this.LoadingScreen != null && (this.LoadingScreen.isAnimating() || this.LoadingScreen.isVisible()) || this.World.State.m.EventScreen.isVisible() || this.World.State.m.EventScreen.isAnimating())
		{
			return false;
		}

		if (("State" in this.Tactical) && this.Tactical.State != null)
		{
			return false;
		}

		if (this.m.ActiveEvent != null)
		{
			return false;
		}

		if (!_ignoreEvaluating && this.m.Thread != null)
		{
			return false;
		}

		if (!_ignorePreviousBattle && this.Time.getVirtualTimeF() - this.m.LastBattleTime < 2.0)
		{
			return false;
		}

		local parties = this.World.getAllEntitiesAtPos(this.World.State.getPlayer().getPos(), 400.0);

		foreach( party in parties )
		{
			if (!party.isAlliedWithPlayer())
			{
				return false;
			}
		}

		return true;
	}

	function updateSpecialEvents()
	{
		foreach( e in this.m.SpecialEvents )
		{
			if (this.getEvent(e).isValid())
			{
				if (this.canFireEvent(true, true))
				{
					this.fire(e);
				}
				else
				{
					this.Time.scheduleEvent(this.TimeUnit.Real, 4000, function ( _tag )
					{
						if (this.World.Events.canFireEvent(true, true))
						{
							this.World.Events.fire(e);
						}
					}, null);
				}

				return true;
			}
		}

		  // [037]  OP_CLOSE          0      1    0    0
		return false;
	}

	function calcDaysTillNextEvent()
	{
		local timeF = this.Time.getVirtualTimeF();
		local lastEvent = this.m.LastEventTime;

		local timeSinceLastEvent = this.Time.getVirtualTimeF() - this.m.LastEventTime - this.Const.Events.GlobalMinDelay;
		local chanceToFireEvent = this.Const.Events.GlobalBaseChance + timeSinceLastEvent * this.Const.Events.GlobalChancePerSecond;

		local timeCheck = this.m.LastEventTime + this.Const.Events.GlobalMinDelay > this.Time.getVirtualTimeF();
		local delayPeriod = this.m.LastEventTime + this.Const.Events.GlobalMinDelay;
		local secondsCheck = this.Time.getVirtualTimeF() - this.m.LastCheckTime <= this.World.getTime().SecondsPerHour * 2;

		//local

		/*
		gt.Const.Events <- {
			GlobalMinDelay = 240.0,
			GlobalBaseChance = 1.0,
			GlobalChancePerSecond = 0.21,
			AllottedTimePerEvaluationRun = 0.001,
			GlobalSound = "sounds/new_round_03.wav"
		};
		*/

		//::logInfo("::Time.getVirtualTimeF() " + ::Time.getVirtualTimeF()); // Float = some time value that is similar to time.Time but slower
		local time = ::World.getTime();
		//:;:logInfo("SecondsPerDay " + time.SecondsPerDay); // Always 105
		//::logInfo("SecondsPerHour " + time.SecondsPerHour); // Always 4,375
		//::logInfo("SecondsOfDay " + time.SecondsOfDay); // Unsigned between 0 and 104
		//::logInfo("Minutes " + time.Minutes); // Unsigned between 0 and 59
		//::logInfo("Hours " + time.Hours); // Unsigned between 0 and 23
		//::logInfo("Days " + time.Days); // Unsigned describing the day, Battle Brothers is in
		//::logInfo("Time " + time.Time); // Float = age (days, hours, minutes) of this world in "BB Seconds"
		//::logInfo("TimeOfDay " + time.TimeOfDay); // Unsigned between 0 and 7 for mapping the time names on the UI clock
		//::logInfo("IsDaytime " + time.IsDaytime); // Bool, that is only false while TimeOfDay == 6, aka it's "Night"

		local logEvents = {};
		//  {
		// 	"TimeF: ", timef
		// }

		logEvents["TimeF"] <- timeF;
		logEvents["LastEvent"] <- lastEvent;
		logEvents["LastCheckTime"] <- this.m.LastCheckTime;
		logEvents["TimeSinceLastEvent"] <- timeSinceLastEvent;
		logEvents["ChanceToFire"] <- chanceToFireEvent;
		logEvents["TimeCheck"] <- timeCheck;
		logEvents["DelayPeriod"] <- delayPeriod;
		logEvents["SecondsPerHour"] <- this.World.getTime().SecondsPerHour * 2;
		logEvents["SecondsCheck"] <- secondsCheck;
		logEvents["DayNumber"] <- time.Days;

		::MSU.Log.printData(logEvents);

		//logWarning(logEvents);

		// ::logWarning("TimeF: " + timeF);
		// ::logWarning("Last Event: " + lastEvent);

		// ::logWarning("Time since last event: " + timeSinceLastEvent + ". % chance to fire: " + chanceToFireEvent);
	}

	function update()
	{
		//::logWarning("Running update()");

		//calcDaysTillNextEvent();

		if (this.World.State.getMenuStack().hasBacksteps() || this.LoadingScreen != null && (this.LoadingScreen.isAnimating() || this.LoadingScreen.isVisible()))
		{
			return;
		}

		if (("State" in this.Tactical) && this.Tactical.State != null)
		{
			return;
		}

		if (this.m.ActiveEvent != null)
		{
			if (!this.m.IsEventShown && (this.m.ActiveEvent.getScore() != 0 || this.m.ActiveEvent.isSpecial()))
			{
				if (!this.m.ActiveEvent.isSpecial() && this.m.ActiveEvent.getScore() < 500)
				{
					local parties = this.World.getAllEntitiesAtPos(this.World.State.getPlayer().getPos(), 400.0);

					foreach( party in parties )
					{
						if (!party.isAlliedWithPlayer())
						{
							return;
						}
					}
				}

				if (this.m.ForceScreen != null)
				{
					this.m.ActiveEvent.setScreen(this.m.ActiveEvent.getScreen(this.m.ForceScreen));
					this.m.ForceScreen = null;
				}

				this.m.IsEventShown = this.World.State.showEventScreen(this.m.ActiveEvent) != false;
			}

			return;
		}

		if (this.updateSpecialEvents())
		{
			//::logWarning("Qualified for special events");
			return;
		}

		if (this.m.Thread != null)
		{
			if (resume this.m.Thread != false)
			{
				this.m.Thread = null;
			}

			//::logWarning("Thread is not empty");
			return;
		}

		if (this.Time.getVirtualTimeF() - this.m.LastBattleTime < 2.0)
		{
			return;
		}

//		local virtualTimer = this.Time.getVirtualTimeF();
//		local lastBattleTime = this.m.LastBattleTime;

//		::logWarning("Virtual Timer: " + virtualTimer + ". last battle " + lastBattleTime + ". global min delay " + this.Const.Events.GlobalMinDelay + ". last event time " + this.m.LastEventTime);



		if (this.m.LastEventTime + this.Const.Events.GlobalMinDelay > this.Time.getVirtualTimeF())
		{
			//::logWarning("Last event + global min delay are greater than timeF");
			return;
		}

		if (this.Time.getVirtualTimeF() - this.m.LastCheckTime <= this.World.getTime().SecondsPerHour * 2)
		{
			//::logWarning("TimeF - last check <= SecondsPerHour * 2")
			return;
		}

		this.m.LastCheckTime = this.Time.getVirtualTimeF();
		local timeSinceLastEvent = this.Time.getVirtualTimeF() - this.m.LastEventTime - this.Const.Events.GlobalMinDelay;
		local chanceToFireEvent = this.Const.Events.GlobalBaseChance + timeSinceLastEvent * this.Const.Events.GlobalChancePerSecond;

		// ::logWarning("Time since last event: " + timeSinceLastEvent);
		// ::logWarning("Chance to fire event: " + chanceToFireEvent);

		if (this.Time.getVirtualTimeF() - this.m.LastBattleTime >= 5.0 && this.Math.rand(1, 100) > chanceToFireEvent)
		{
			//::logWarning("Not firing event yet");
			return;
		}

		local parties = this.World.getAllEntitiesAtPos(this.World.State.getPlayer().getPos(), 400.0);

		foreach( party in parties )
		{
			if (!party.isAlliedWithPlayer())
			{
				//::logWarning("Enemies too close to fire event!");
				return;
			}
		}

		this.m.Thread = this.selectEvent();

		if (resume this.m.Thread != false)
		{
			this.m.Thread = null;
		}
	}

	function selectEvent()
	{
		// Function is a generator.
		local score = 0;
		local eventToFire;
		local isNewsReady = this.World.Statistics.isNewsReady();
		local limit = this.Math.max(1, this.World.getSpeedMult()) * 3;
		local eventsInPool = {};

		for( local i = 0; i < this.m.Events.len(); i = ++i )
		{
			if (this.m.LastEventID == this.m.Events[i].getID() && !this.m.Events[i].isSpecial())
			{
				this.m.Events[i].clear();
			}
			else
			{
				this.m.Events[i].update();
			}

			if (i % limit == 0)
			{
				yield false;
			}

			if (this.m.Events[i].getScore() <= 0 || isNewsReady && this.m.Events[i].getScore() < 2000 || this.Time.getVirtualTimeF() - this.m.LastBattleTime < 5.0 && this.m.Events[i].getScore() < 500)
			{
				//this.logWarning("...Skipping event??: " + this.m.Events[i].getID() + " with score of " + this.m.Events[i].getScore());
			}
			else
			{
				//this.logWarning("Added to event pool: " + this.m.Events[i].getID() + " with score of " + this.m.Events[i].getScore());
				eventsInPool[this.m.Events[i].getID()] <- this.m.Events[i].getScore();

				score = score + this.m.Events[i].getScore();
			}
		}

		//this.logWarning("...Max possible score to pick from: " + score);

		local pick = this.Math.rand(1, score);
		yield false;

		this.logWarning("...Picking ticket #: " + pick + " of max entries " + score);
		::MSU.Log.printData(eventsInPool);

		for( local i = 0; i < this.m.Events.len(); i = ++i )
		{
			if (this.m.Events[i].getScore() <= 0 || isNewsReady && this.m.Events[i].getScore() < 2000 || this.Time.getVirtualTimeF() - this.m.LastBattleTime < 5.0 && this.m.Events[i].getScore() < 500)
			{
			}
			else
			{
				//this.logWarning("Trying to pick event using number " + i + " with pick score of " + pick + ". Evaluating event: " + this.m.Events[i].getID() + " which requires a score of " + this.m.Events[i].getScore());

				if (pick <= this.m.Events[i].getScore())
				{
					eventToFire = this.m.Events[i];
					break;
				}

				pick = pick - this.m.Events[i].getScore();
			}
		}

		if (eventToFire == null)
		{
			this.logDebug("no event???");
			return true;
		}

		yield false;
		this.m.ActiveEvent = eventToFire;
		this.m.ActiveEvent.clear();
		this.m.ActiveEvent.update();

		this.logWarning("Firing event: " + eventToFire.getID() + " with score of " + eventToFire.getScore());

		if (this.m.ActiveEvent.getScore() == 0)
		{
			this.m.ActiveEvent.clear();
			this.m.ActiveEvent = null;
			return true;
		}

		if (this.m.ActiveEvent.getScore() < 500)
		{
			local parties = this.World.getAllEntitiesAtPos(this.World.State.getPlayer().getPos(), 400.0);

			foreach( party in parties )
			{
				if (!party.isAlliedWithPlayer())
				{
					this.m.ActiveEvent.clear();
					this.m.ActiveEvent = null;
					return true;
				}
			}
		}

		if (this.m.ActiveEvent.getScore() < 2000)
		{
			this.m.LastEventTime = this.Time.getVirtualTimeF();
		}

		this.m.ActiveEvent.fire();
		this.m.IsEventShown = this.World.State.showEventScreen(this.m.ActiveEvent);
		return true;
	}

	function clear()
	{
		this.m.LastEventTime = this.Time.getVirtualTimeF();
		this.m.LastEventID = "";
		this.m.LastBattleTime = 0;
		this.m.ActiveEvent = null;
		this.m.VictoryScreen = null;
		this.m.DefeatScreen = null;
		this.m.ForceScreen = null;
		this.m.IsEventShown = false;
		this.m.Thread = null;

		foreach( i, event in this.m.Events )
		{
			event.reset();
		}
	}

	function processInput( _option )
	{
		if (this.m.ActiveEvent != null)
		{
			if (!this.m.ActiveEvent.processInput(_option) && this.m.ActiveEvent != null)
			{
				if (this.m.VictoryScreen == null && this.m.DefeatScreen == null)
				{
					this.m.LastEventID = this.m.ActiveEvent.getID();
					this.m.ActiveEvent.clear();
					this.m.ActiveEvent = null;
					this.m.ForceScreen = null;
				}

				this.m.IsEventShown = false;
				this.World.State.getMenuStack().pop(true);
			}
			else
			{
				this.World.State.getEventScreen().show(this.m.ActiveEvent);
			}
		}
	}

	function showCombatDialog( _isPlayerInitiated = true, _isCombatantsVisible = true, _allowFormationPicking = true )
	{
		if (this.m.ActiveEvent == null)
		{
			return;
		}

		this.m.LastEventID = this.m.ActiveEvent.getID();
		this.m.ActiveEvent.clear();
		this.m.ActiveEvent = null;
		this.m.ForceScreen = null;
		this.m.IsEventShown = false;
		this.World.State.getMenuStack().pop(true);
		this.World.State.showCombatDialog(_isPlayerInitiated, _isCombatantsVisible, _allowFormationPicking);
	}

	function enterLocation()
	{
		if (this.m.ActiveEvent == null)
		{
			return;
		}

		this.m.LastEventID = this.m.ActiveEvent.getID();
		this.m.ActiveEvent.clear();
		this.m.ActiveEvent = null;
		this.m.ForceScreen = null;
		this.m.IsEventShown = false;
		this.World.State.getMenuStack().pop(true);
		this.World.State.enterLocation(this.World.State.getLastLocation());
	}

	function registerToShowAfterCombat( _victoryScreen, _defeatScreen )
	{
		this.m.VictoryScreen = _victoryScreen;
		this.m.DefeatScreen = _defeatScreen;
	}

	function onActorKilled( _actor, _killer, _combatID )
	{
	}

	function onActorRetreated( _actor, _combatID )
	{
	}

	function onRetreatedFromCombat( _combatID )
	{
		if (this.m.ActiveEvent != null && this.m.DefeatScreen != null)
		{
			this.m.ForceScreen = this.m.DefeatScreen;
			this.m.VictoryScreen = null;
			this.m.DefeatScreen = null;
		}
	}

	function onCombatVictory( _combatID )
	{
		if (this.m.ActiveEvent != null && this.m.VictoryScreen != null)
		{
			this.m.ForceScreen = this.m.VictoryScreen;
			this.m.VictoryScreen = null;
			this.m.DefeatScreen = null;
		}
	}

	function onSerialize( _out )
	{
		_out.writeF32(this.m.LastEventTime);
		_out.writeU32(this.m.Events.len());

		foreach( event in this.m.Events )
		{
			_out.writeString(event.getID());
			event.onSerialize(_out);
		}

		_out.writeF32(this.m.LastBattleTime);
		_out.writeBool(true);
		_out.writeString(this.m.LastEventID);
		_out.writeBool(false);
	}

	function onDeserialize( _in )
	{
		this.clear();
		this.m.LastEventTime = _in.readF32();
		local numEvents = _in.readU32();

		for( local i = 0; i < numEvents; i = ++i )
		{
			local event = this.getEvent(_in.readString());

			if (event != null)
			{
				event.onDeserialize(_in);
			}
			else
			{
				_in.readF32();
			}
		}

		this.m.LastBattleTime = _in.readF32();
		local hasLastEvent = _in.readBool();

		if (!hasLastEvent)
		{
			return;
		}

		this.m.LastEventID = _in.readString();
		_in.readBool();
	}

};

