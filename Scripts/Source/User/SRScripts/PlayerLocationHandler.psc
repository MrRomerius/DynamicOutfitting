Scriptname SRScripts:PlayerLocationHandler extends Quest
{This script sends events based on where the player travels to.}
;/
AUTHOR: MrRomerius
LICENSE: Feel free to reuse this code in whole or in part so long as proper authorship credit is given. Pay it forward!
NOTES: Scoring relies on getting vendor objects from O(n) locations every time player enters a settlement. Could be improved...
/;

; VARS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Actor Property PlayerRef Auto Const Mandatory

WorkshopParentScript Property WorkshopParent Auto Const

Keyword Property LocTypeWorkshopSettlement Auto Const

int TimerID_LocRefresh = 102 Const
int TimerID_RetryWorkshop = 103 Const
float fTimerLen = 2.0 Const

	; CUSTOM EVENTS <=================================

; Sent when an owned workshop is in active location.
CustomEvent ScoreLocalVendors

; Sent if a workshop location has NPCs.
CustomEvent AddNewSettlers

; EVENTS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Event OnTimer(int aiTimerID)
	if aiTimerID == TimerID_LocRefresh
		GoToState("")
	elseif aiTimerID == TimerID_RetryWorkshop
		HandleWorkshop(WorkshopParent.GetWorkshopFromLocation(GetPlayerLoc()))
	endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
	HandleNewLocation(akNewLoc)
EndEvent

; <STATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATE>

State Inactive

	Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
		; DISABLED.
	EndEvent
	
EndState

; <STATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATE>

; FUNCTIONS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	; MAIN <=================================

Function HandleNewLocation(Location akLoc)
	GoToState("Inactive")
	CancelAllTimers()
	if akLoc
		if akLoc.HasKeyword(LocTypeWorkshopSettlement)
			HandleWorkshop(WorkshopParent.GetWorkshopFromLocation(akLoc))
		endif
	endif
	StartTimer(fTimerLen, TimerID_LocRefresh)
EndFunction

Function HandleWorkshop(WorkshopScript akWshop)
	if akWshop
		Var[] kargs = new Var[1]
		kargs[0] = akWshop
		SendCustomEvent("ScoreLocalVendors", kargs)
		CheckForSettlersInWorkshop(akWshop)
		return
	endif
	StartTimer(fTimerLen, TimerID_RetryWorkshop)
EndFunction

Function CheckForSettlersInWorkshop(WorkshopScript akWshop)
	if akWshop.GetBaseValue(WorkshopParent.WorkshopRatings[WorkshopParent.WorkshopRatingPopulation].resourceValue) > 0
		Var[] kargs = new Var[1]
		kargs[0] = akWshop
		SendCustomEvent("AddNewSettlers", kargs)
	endif
EndFunction

	; HELPERS <=============================

Function StartLocHandler()
	RegisterForRemoteEvent(PlayerRef, "OnLocationChange")
	; Check location upon activation in case player loads inside a settlement.
	HandleNewLocation(GetPlayerLoc())
EndFunction

Location Function GetPlayerLoc()
	return PlayerRef.GetCurrentLocation()
EndFunction

Function CancelAllTimers()
	CancelTimer(TimerID_LocRefresh)
	CancelTimer(TimerID_RetryWorkshop)
EndFunction
