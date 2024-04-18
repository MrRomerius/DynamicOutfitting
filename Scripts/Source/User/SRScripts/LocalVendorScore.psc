Scriptname SRScripts:LocalVendorScore extends Quest
{This script scores the vendor levels in a settlement.}
;/
AUTHOR: MrRomerius
LICENSE: Feel free to reuse this code in whole or in part so long as proper authorship credit is given. Pay it forward!
NOTES: Scoring relies on getting vendor objects from O(n) locations every time player enters a settlement. Could be improved...
/;

import SRScripts:DynOutfitDataStructures

; VARS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

WorkshopParentScript Property WorkshopParent Auto Const

ActorValue Property vendorIncome Auto Const

Group Keywords
	Keyword Property WorkshopLinkCenter Auto Const
	Keyword Property WorkshopLinkCaravanStart Auto Const
	Keyword Property WorkshopLinkCaravanEnd Auto Const
EndGroup

int[] Property LocalVendorLevels Auto
{	Index:
	0 = Misc(General) vendor
	1 = Armor vendor
	2 = Weapons vendor
	3 = Bar vendor
	4 = Clinic vendor
	5 = Clothing vendor
	6 = Chems vendor
}

int property StoreMisc = 0 autoreadonly hidden
int property StoreArmor = 1 autoreadonly hidden
int property StoreWeapons = 2 autoreadonly hidden
int property StoreBar = 3 autoreadonly hidden
int property StoreClinic = 4 autoreadonly hidden
int property StoreClothing = 5 autoreadonly hidden
int property StoreChems = 6 autoreadonly hidden

; Array of vendor score data for each settlement workshop.
LocalVendorScores[] Property WorkshopVendorScores Auto

; Workshop ID of currently loaded workshop.
int property ActiveWorkshopID = -1 auto

; Set to true if a vendor with a higher level is detected.
bool property bBetterVendorsAvailable = false auto

; Set to true when vendor scoring is done.
bool property bLocalScoresDone = false auto

int MAXARRAYLENGTH = 128 Const

	; CUSTOM EVENTS <=================================

; Send when a better vendor is added to a location.
CustomEvent BetterVendorAdded

; Sent if better vendors are available at a workshop.
CustomEvent LocalVendorScoresUpdated

; EVENTS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Event WorkshopParentScript.WorkshopActorAssignedToWork(WorkshopParentScript akSender, Var[] akArgs)
	WorkshopObjectScript myObj = akArgs[0] as WorkshopObjectScript
	if myObj.VendorType > -1
		if myObj.VendorLevel > LocalVendorLevels[myObj.VendorType]
			LocalVendorLevels[myObj.VendorType] = myObj.VendorLevel
			UpdateVendorScoreEntry()
			Var[] kargs = new Var[2]
			kargs[0] = myObj.VendorType
			kargs[1] = myObj.VendorLevel
			SendCustomEvent("BetterVendorAdded", kargs)
		endif
	endif
EndEvent

Event WorkshopParentScript.WorkshopActorCaravanAssign(WorkshopParentScript akSender, Var[] akArgs)
	WorkshopNPCScript myNPC = akArgs[0] as WorkshopNPCScript
	int idToScore = FindWshopIDFromCaravan(myNPC.GetWorkshopID(), myNPC.GetCaravanDestinationID())
	if idToScore > -1
		WorkshopScript myWshop = WorkshopParent.GetWorkshop(idToScore)
		ScoreWorkshopVendors(GetVendors(myWshop))
		if bBetterVendorsAvailable
			SendScoreUpdateEvent(myWshop)
		endif
	endif
EndEvent

; FUNCTIONS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	; MAIN <==============================================

Function ScoreAllVendors(WorkshopScript akWshop)
	ResetLocalWshopVars(akWshop.GetWorkshopID())
	WorkshopScript[] allWshops = GetAllWorkshops(InitializeWorkshopIDArray(akWshop), akWshop.GetLinkedRef(WorkshopLinkCenter))
	int i = 0
	int j = allWshops.Length
	while i < j
		ScoreWorkshopVendors(GetVendors(allWshops[i]))
		i += 1
	endwhile
	if bBetterVendorsAvailable
		Debug.Trace("Better vendors available!")
		SendScoreUpdateEvent(akWshop)
	endif
	SetbLocalScoresDone(true)
	Debug.Trace(akWshop.myLocation + " LocalVendorLevels: " + LocalVendorLevels)
EndFunction

WorkshopScript[] Function InitializeWorkshopIDArray(WorkshopScript akWshop)
	WorkshopScript[] myWshops = new WorkshopScript[0]
	myWshops.Add(akWshop)
	return myWshops
EndFunction

Function GetWorkshopVendorScores(int aiWshopID)
	if WorkshopVendorScores[aiWshopID] == NONE
		CreateVendorScoreEntry(aiWshopID)
	endif
	ReadVendorScoreEntry(aiWshopID)
EndFunction

Function ScoreWorkshopVendors(WorkshopObjectScript[] akVendors)
	if akVendors
		int i = 0
		int j = akVendors.Length
		while i < j
			if akVendors[i].VendorLevel > LocalVendorLevels[akVendors[i].VendorType]
				LocalVendorLevels[akVendors[i].VendorType] = akVendors[i].VendorLevel
				SetbBetterVendorsAvailable(true)
			endif
			i += 1
		endwhile
	endif
EndFunction

WorkshopScript[] Function GetAllWorkshops(WorkshopScript[] akWshopArray, ObjectReference akMarker)
	if akMarker
		WorkshopNPCScript[] localProvisioner = GetCaravans(akMarker, WorkshopLinkCaravanStart)
		WorkshopNPCScript[] remoteProvisioners = GetCaravans(akMarker, WorkshopLinkCaravanEnd)
		if localProvisioner
			WorkshopScript myWshop = WorkshopParent.GetWorkshop(localProvisioner[0].GetCaravanDestinationID())
			akWshopArray.Add(myWshop)
			Debug.Trace(myWshop.myLocation + " has " + localProvisioner[0] + " as caravan!")
		endif
		if remoteProvisioners
			int i = 0
			int j = remoteProvisioners.Length
			while i < j
				akWshopArray.Add(WorkshopParent.GetWorkshop(remoteProvisioners[i].GetWorkshopID()))
				i += 1
			endwhile
			;Debug.Trace("Settlement has " + j + " caravans incoming!")
		endif
	endif
	return akWshopArray
EndFunction

Function SendScoreUpdateEvent(WorkshopScript akWshop)
	SetbBetterVendorsAvailable()
	UpdateVendorScoreEntry()
	Var[] kargs = new Var[1]
	kargs[0] = akWshop
	SendCustomEvent("LocalVendorScoresUpdated", kargs)
EndFunction

	; VENDOR SCORE FUNCTIONS <=================================

Function CreateVendorScoreEntry(int aiWshopID)
	LocalVendorScores myScores = new LocalVendorScores
	WorkshopVendorScores[aiWshopID] = myScores
EndFunction

int[] Function ReadVendorScoreEntry(int aiWshopID)
	LocalVendorScores myScores = WorkshopVendorScores[aiWshopID]
	LocalVendorLevels[StoreMisc] = myScores.storeMisc
	LocalVendorLevels[StoreArmor] = myScores.storeArmor
	LocalVendorLevels[StoreWeapons] = myScores.storeWeapons
	LocalVendorLevels[StoreBar] = myScores.storeBar
	LocalVendorLevels[StoreClinic] = myScores.storeClinic
	LocalVendorLevels[StoreClothing] = myScores.storeClothing
	LocalVendorLevels[StoreChems] = myScores.storeChems
EndFunction

Function UpdateVendorScoreEntry()
	LocalVendorScores myScores = WorkshopVendorScores[ActiveWorkshopID]
	myScores.storeMisc = LocalVendorLevels[StoreMisc]
	myScores.storeArmor = LocalVendorLevels[StoreArmor]
	myScores.storeWeapons = LocalVendorLevels[StoreWeapons]
	myScores.storeBar = LocalVendorLevels[StoreBar]
	myScores.storeClinic = LocalVendorLevels[StoreClinic]
	myScores.storeClothing = LocalVendorLevels[StoreClothing]
	myScores.storeChems = LocalVendorLevels[StoreChems]
EndFunction

	; HELPERS <=================================

Function StartLocalVendorScore()
	WorkshopVendorScores = new LocalVendorScores[MAXARRAYLENGTH]
	RegisterForCustomEvent(WorkshopParent, "WorkshopActorAssignedToWork")
	RegisterForCustomEvent(WorkshopParent, "WorkshopActorCaravanAssign")
EndFunction

Function SetActiveWorkshopID(int aiWshopID)
	ActiveWorkshopID = aiWshopID
EndFunction

Function ResetLocalWshopVars(int akWshopID)
	SetbBetterVendorsAvailable()
	SetbLocalScoresDone()
	SetActiveWorkshopID(akWshopID)
	GetWorkshopVendorScores(akWshopID)
EndFunction

Function SetbLocalScoresDone(bool abFlag = false)
	bLocalScoresDone = abFlag
EndFunction

Function SetbBetterVendorsAvailable(bool abFlag = false)
	bBetterVendorsAvailable = abFlag
EndFunction
	
WorkshopNPCScript[] Function GetCaravans(ObjectReference akMarker, Keyword akKeyword)
	return akMarker.GetActorsLinkedToMe(akKeyword) as WorkshopNPCScript[]
EndFunction

WorkshopObjectScript[] Function GetVendors(WorkshopScript akWshop, int undamagedStores = 2)
	return akWshop.GetWorkshopResourceObjects(vendorIncome, undamagedStores) as WorkshopObjectScript[]
EndFunction

int Function FindWshopIDFromCaravan(int aiNPCWshopID, int aiNPCDestID)
	if aiNPCWshopID == ActiveWorkshopID
		return aiNPCDestID
	elseif aiNPCDestID == ActiveWorkshopID
		return aiNPCWshopID
	endif
	return -1
EndFunction
