Scriptname SRScripts:WorkshopNPCOutfitChanger extends activemagiceffect
{This script generates equipment data on an NPC and equips them based on their AI packages.}
;/
AUTHOR: MrRomerius
LICENSE: Feel free to reuse this code in whole or in part so long as proper authorship credit is given. Pay it forward!
NOTES: Scoring relies on getting vendor objects from O(n) locations every time player enters a settlement. Could be improved...
/;

import SRScripts:DynOutfitUtilityFunctions

; VARS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Group Scripts
	WorkshopParentScript Property WorkshopParent Auto Const
	SRScripts:EquipmentBuilder Property EquipBuilder Auto Const
	SRScripts:LocalVendorScore Property VendorScores Auto Const
EndGroup

Group Packages
	Package Property WorkshopSleep0x8 Auto Const
	Package Property WorkshopSandboxDefault Auto Const
	Package Property WorkshopSandboxRelaxation20x4 Auto Const
EndGroup

Group Keywords
	Keyword Property IsSleepFurniture Auto Const
	Keyword Property WorkshopWorkObject Auto Const
EndGroup

; Used for player/NPC inventory menu events.
SRScripts:PlayerEquipNPCScript Property PlayerScript Auto Const

; Equipment data base form.
Form Property sr_EquipData Auto Const

; Stores the actor ref this magic effect is on.
Actor Property myNPC Auto

; Multi-use weapon var.
Weapon myWeapon

; Stores our NPC's equipment arrays.
SRScripts:NPCEquipData myEquipData

; Stores the highest level access to clothing this NPC has.
int Property ClothingLevel = -2 Auto

; These arrays get saved on an NPC's equip data form.
Form[] Property DefaultWear Auto
Form[] Property CustomWear Auto
Form[] Property SleepWear Auto
Form[] Property WorkWear Auto
Form[] Property CasualWear Auto

; Timer IDs.
int TimerID_FinishInitialization = 105 Const
int TimerID_ChangeWorkClothes = 106 Const
float fTimerInit = 0.2 Const
float fTimerRetry = 2.0 Const

; Job IDs.
int ID_Guard = 0 Const
int ID_Farmer = 1 Const
int ID_Scavenger = 2 Const
int ID_Provisioner = 3 Const
int ID_Vendor = 4 Const

; Store IDs.
int ID_ClothingStore = 5 Const

; Store levels.
int iStoreNone = -1 Const
int iStoreLevel1 = 0 Const
int iStoreLevel2 = 1 Const
int iStoreLevel3 = 2 Const

; Workshop assign ID.
int iWorkshopAssign = 10 Const

; EVENTS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Debug.Trace("Outfit changer spell active on " + akTarget + "!")
	myNPC = akTarget
	InitializeOutfitArrays()
	if akTarget.GetItemCount(sr_EquipData)
		InitializeNPCOutfitting(akTarget)
		return
	endif
	InitializeNewNPC(akTarget)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	UnregisterForAllEvents()
EndEvent

Event OnCommandModeGiveCommand(int aeCommandType, ObjectReference akTarget)
	GoToState("LockOn")
	if aeCommandType == iWorkshopAssign && akTarget && bLinkedToActiveWorkshop(myNPC as WorkshopNPCScript)
		if akTarget.HasKeyword(WorkshopWorkObject) && bHasVendorAccess(ClothingLevel, iStoreLevel2)
			StartTimer(fTimerRetry, TimerID_ChangeWorkClothes)
		endif
	endif
	GoToState("")
EndEvent

Event OnActivate(ObjectReference akActionRef)
	if akActionRef == Game.GetPlayer() && !myNPC.IsChild()
		PlayerScript.StartPlayerMenuEvent(self) 
	endif
EndEvent

Event OnSit(ObjectReference akFurniture)
	if akFurniture.GetActorRefOwner() == myNPC && (akFurniture.HasKeyword(IsSleepFurniture) || akFurniture.HasKeyword(WorkshopWorkObject))
		SetClothesFromAIPackage()
	endif
EndEvent

Event OnGetUp(ObjectReference akFurniture)
	if akFurniture.HasKeyword(IsSleepFurniture) && myNPC.GetCurrentPackage() != WorkshopSleep0x8
		SetClothesFromAIPackage()
	endif
EndEvent

Event OnDistanceLessThan(ObjectReference akObj1, ObjectReference akObj2, float afDistance)
	UnregisterForDistanceEvents(akObj1, akObj2)
	EquipClothes(SleepWear)
EndEvent

; Data deletion is handled here instead of OnDeath() in case player resurrects NPC.
Event OnUnload()
	DebugEquipData()
	CancelAllTimers()
	if myNPC.IsDead()
		myEquipData.DeleteEquipData()
		((VendorScores as Quest) as SRScripts:NPCEquipSpellManager).Alias_WorkshopNPCs.RemoveRef(myNPC)
		return
	endif
EndEvent

Event OnLoad()
	SetClothesFromAIPackage()
EndEvent

Event Package.OnStart(Package akSender, Actor akActor)
	if akActor == myNPC
		SetClothesFromAIPackage(akSender)
	endif
EndEvent

Event SRScripts:LocalVendorScore.BetterVendorAdded(SRScripts:LocalVendorScore akSender, Var[] akArgs)
	GoToState("LockOn")
	if bLinkedToActiveWorkshop(myNPC as WorkshopNPCScript)
		RequestVendorUpdate(akArgs[0] as int, akArgs[1] as int)
		SetClothesFromAIPackage()
		myEquipData.SaveEquipData(self)
		DebugEquipData()
	endif
	GoToState("")
EndEvent

Event SRScripts:LocalVendorScore.LocalVendorScoresUpdated(SRScripts:LocalVendorScore akSender, Var[] akArgs)
	if bLinkedToActiveWorkshop(myNPC as WorkshopNPCScript)
		RequestEquipmentUpdate(VendorScores.LocalVendorLevels)
		SetClothesFromAIPackage()
		myEquipData.SaveEquipData(self)
		DebugEquipData()
	endif
EndEvent

Event OnTimer(int aiTimerID)
	if aiTimerID == TimerID_FinishInitialization
		FinishInitialization()
	elseif aiTimerID == TimerID_ChangeWorkClothes
		RequestClothes(iStoreLevel2)
		SetClothesFromAIPackage()
		myEquipData.SaveEquipData(self)
		DebugEquipData()
	endif
EndEvent

; <STATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATE>

; lock state to handle race condition btwn these events when assigning npc to a store.
State LockOn
	
	Event OnCommandModeGiveCommand(int aeCommandType, ObjectReference akTarget)
	EndEvent
	
	Event SRScripts:LocalVendorScore.BetterVendorAdded(SRScripts:LocalVendorScore akSender, Var[] akArgs)
	EndEvent

EndState

State Uninitialized
	
	Event OnItemUnequipped(Form akBaseObject, ObjectReference akReference)
		if akBaseObject as Armor
			myNPC.EquipItem(akBaseObject)
			DefaultWear.Add(akBaseObject)
			StartTimer(fTimerInit, TimerID_FinishInitialization)
		endif
	EndEvent

EndState

; <STATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATESTATE>

; FUNCTIONS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	; MAIN <==============================================

Function InitializeNPCOutfitting(Actor akActor)
	LoadEquipData(akActor)
	if myEquipData
		VerifyEquipData(akActor, myEquipData)
		StartOutfitChanger()
		return
	endif
	Debug.Trace("ERROR: NPC has equip data, but failed to load!")
EndFunction

Function InitializeOutfitArrays()
	DefaultWear = new Form[0]
	CustomWear = new Form[0]
	SleepWear = new Form[0]
	WorkWear = new Form[0]
	CasualWear = new Form[0]
EndFunction

; Initialization of outfit changer data starts here and end with StartTimer event called by OnItemUnequipped event.
Function InitializeNewNPC(Actor akActor)
	CreateNPCEquipData(akActor)
	if myEquipData
		myEquipData.ActorType = GetActorType(akActor)
		GoToState("Uninitialized")
		akActor.UnequipAll() ; Trigger outfit sorting to finish initialization.
		return
	endif
	Debug.Trace("ERROR: Failed to create new equip data!")
EndFunction

Function FinishInitialization()
	GoToState("")
	if !DefaultWear
		DefaultWear.Add(Game.GetFormFromFile(0x00034595, "Fallout4.esm"))
	endif
	RequestEquipmentUpdate(VendorScores.LocalVendorLevels)
	myEquipData.DefaultWear = DefaultWear ; save our default clothes.
	myEquipData.SaveEquipData(self)
	StartOutfitChanger()
	Debug.Trace("SUCCESS: Outfit changer initialization finished on " + myNPC)
EndFunction

Function RequestEquipmentUpdate(int[] aiVendorLevels)
	if aiVendorLevels
		RequestVendorUpdate(ID_ClothingStore, aiVendorLevels[ID_ClothingStore])
	endif
EndFunction

Function RequestVendorUpdate(int aiVendorType, int aiVendorLevel)
	if aiVendorType == ID_ClothingStore
		while ClothingLevel < aiVendorLevel
			ClothingLevel += 1
			RequestClothes(ClothingLevel)
		endwhile
	endif
EndFunction

Function RequestClothes(int aiClothesID, int aiVendorID = -1)
	Debug.Trace("EquipBuilder val:" + EquipBuilder + " from " + myNPC)
	if aiClothesID == iStoreNone
		SleepWear = EquipBuilder.GetSleepClothes(aiClothesID, GetActorType(myNPC))
	elseif aiClothesID == iStoreLevel1
		RemoveClothes(SleepWear)
		SleepWear = EquipBuilder.GetSleepClothes(aiClothesID, GetActorType(myNPC))
	elseif !bSpecialCaseNPC(myNPC)
		if aiClothesID == iStoreLevel2
			RemoveClothes(WorkWear)
			int myJobID = GetJobID()
			if myJobID == ID_Vendor
				aiVendorID = GetVendorID()
			endif
			WorkWear = EquipBuilder.GetWorkClothes(myJobID, aiVendorID)
		elseif aiClothesID == iStoreLevel3
			CasualWear = EquipBuilder.GetCasualClothes(aiClothesID, GetActorType(myNPC))
		endif
	endif
EndFunction

int Function GetJobID()
	WorkshopNPCScript myWshopNPC = myNPC as WorkshopNPCScript
	if myWshopNPC.assignedMultiResource
		if myWshopNPC.bIsGuard
			return ID_Guard
		endif
		return ID_Farmer
	elseif myWshopNPC.bIsScavenger
		return ID_Scavenger
	elseif WorkshopParent.CaravanActorAliases.Find(myWshopNPC) > -1
		return ID_Provisioner
	endif
	return ID_Vendor
EndFunction

int Function GetVendorID()
	WorkshopObjectScript[] myStuff = WorkshopParent.GetWorkshop((myNPC as WorkshopNPCScript).GetWorkshopID()).GetWorkshopOwnedObjects(myNPC) as WorkshopObjectScript[]
	if myStuff
		int i = 0
		int j = myStuff.Length
		while i < j
			if mystuff[i].VendorType > -1
				return mystuff[i].VendorType
			endif
			i += 1
		endwhile
	endif
	return -1
EndFunction

Function StartOutfitChanger()
	RegisterMyEvents()
	SetEquipmentVars()
	DebugEquipData()
	CheckEquipLevels()
	SetClothesFromAIPackage()
	Debug.Trace("SUCCESS: Outfit changer active on " + myNPC)
	DebugEquipData()
EndFunction

Function CheckEquipLevels()
	if bLinkedToActiveWorkshop(myNPC as WorkshopNPCScript)
		int localClothingLevel = VendorScores.LocalVendorLevels[ID_ClothingStore]
		if ClothingLevel < localClothingLevel
			RequestVendorUpdate(ID_ClothingStore, localClothingLevel)
			myEquipData.SaveEquipData(self)
		endif
	endif
EndFunction

Function RegisterMyEvents()
	RegisterForRemoteEvent(WorkshopSleep0x8, "OnStart")
	RegisterForRemoteEvent(WorkshopSandboxDefault, "OnStart")
	RegisterForRemoteEvent(WorkshopSandboxRelaxation20x4, "OnStart")
	RegisterForCustomEvent(VendorScores, "BetterVendorAdded")
	RegisterForCustomEvent(VendorScores, "LocalVendorScoresUpdated")
EndFunction

ObjectReference Function FindBed()
	ObjectReference[] myStuff = WorkshopParent.GetWorkshop((myNPC as WorkshopNPCScript).GetWorkshopID()).GetWorkshopOwnedObjects(myNPC)
	if myStuff
		int i = 0
		int j = myStuff.Length
		while i < j
			if myStuff[i].HasKeyword(IsSleepFurniture)
				return myStuff[i]
			endif
			i += 1
		endwhile
	endif
	return NONE
EndFunction

	; EQUIP FUNCTIONS <==============================================

Function SetClothesFromAIPackage(Package akPackage = NONE)
	if akPackage == NONE
		akPackage = myNPC.GetCurrentPackage()
	endif
	if akPackage == WorkshopSleep0x8
		HandleBedtimeEquip()
	elseif akPackage == WorkshopSandboxDefault || akPackage == WorkshopSandboxRelaxation20x4
		TryToEquip(CasualWear)
	else
		TryToEquip(WorkWear)
	endif
EndFunction

Function HandleBedtimeEquip(int iSleepState = 3, float afDistance = 160.0)
	if myNPC.GetSleepState() == iSleepState
		TryToEquip(SleepWear)
		return
	endif
	TryToEquip(CasualWear)
	ObjectReference myBed = FindBed()
	if myBed
		RegisterForDistanceLessThanEvent(myNPC, myBed, afDistance)
	endif
EndFunction

Function TryToEquip(Form[] akForms)
	if !akForms && !CustomWear
		akForms = DefaultWear
	elseif CustomWear && akForms != SleepWear
		akForms = CustomWear
	endif
	EquipClothes(akForms)
EndFunction

Function EquipClothes(Form[] akForms, bool abUnequipAll = false)
	CheckDrawnWeapon()
	myNPC.UnequipAll()
	int i = 0
	int j = akForms.Length
	while i < j
		myNPC.EquipItem(akForms[i], true)
		i += 1
	endwhile
	RedrawWeapon()
EndFunction

Function RemoveClothes(Form[] akForms)
	if akForms
		int i = 0
		int j = akForms.Length
		while i < j
			myNPC.RemoveItem(akForms[i], -1)
			i += 1
		endwhile
	endif
EndFunction

Function CheckDrawnWeapon()
	if myNPC.IsWeaponDrawn()
		myWeapon = myNPC.GetEquippedWeapon()
	endif
EndFunction

Function RedrawWeapon()
	if myWeapon
		myNPC.EquipItem(myWeapon)
		myNPC.DrawWeapon()
		myWeapon = NONE
	endif
EndFunction

	; DATA FUNCTIONS <==============================================

Function CreateNPCEquipData(Actor akActor)
	myEquipData = akActor.PlaceAtMe(sr_EquipData, abInitiallyDisabled = true, abDeleteWhenAble = false) as SRScripts:NPCEquipData
	akActor.AddItem(myEquipData)
EndFunction

Function LoadEquipData(Actor akActor)
	myEquipData = akActor.DropObject(sr_EquipData) as SRScripts:NPCEquipData
	akActor.AddItem(myEquipData)
EndFunction

Function VerifyEquipData(Actor akActor, SRScripts:NPCEquipData akEquipData)
	int iActorType = GetActorType(akActor)
	; ActorType has to match actor to receive correct equipment.
	if akEquipData.ActorType != iActorType || !akEquipData.SleepWear
		akEquipData.ResetEquipData(iActorType)
	endif
EndFunction

	; HELPERS <==============================================

SRScripts:NPCEquipData Function GetEquipData()
	return myEquipData
EndFunction

bool Function bLinkedToActiveWorkshop(WorkshopNPCScript akWshopNPC)
	Debug.Trace("VendorScores: " + VendorScores + " from " + akWshopNPC)
	if akWshopNPC && VendorScores
		int iActiveWshopID = VendorScores.ActiveWorkshopID
		if WorkshopParent.CaravanActorAliases.Find(akWshopNPC) > -1
			return akWshopNPC.GetWorkshopID() == iActiveWshopID || akWshopNPC.GetCaravanDestinationID() == iActiveWshopID
		endif
		return akWshopNPC.GetWorkshopID() == iActiveWshopID
	endif
	return false
EndFunction

Function SetEquipmentVars()
	ClothingLevel = myEquipData.ClothingLevel
	DefaultWear = myEquipData.DefaultWear
	CustomWear = myEquipData.CustomWear
	SleepWear = myEquipData.SleepWear
	WorkWear = myEquipData.WorkWear
	CasualWear = myEquipData.CasualWear
EndFunction

Function CancelAllTimers()
	CancelTimer(TimerID_FinishInitialization)
	CancelTimer(TimerID_ChangeWorkClothes)
EndFunction

; temp debug function.
Function DebugEquipData()
	Debug.Trace(myNPC + " current stats and equipment: \n Clothing Level: " + ClothingLevel + "\n ActorType: " + myEquipData.ActorType + "\n DefaultWear: " + DefaultWear + "\n CustomWear: " \
	+ CustomWear + "\n SleepWear: " + SleepWear + "\n WorkWear: " + WorkWear + "\n CasualWear: " + CasualWear)
	Debug.Trace(myEquipData + " equip data saved: \n Clothing Level: " + myEquipData.ClothingLevel + "\n ActorType: " + myEquipData.ActorType + "\n DefaultWear: " + \
	myEquipData.DefaultWear + "\n CustomWear: " + CustomWear + "\n SleepWear: " + myEquipData.SleepWear + "\n WorkWear: " + myEquipData.WorkWear + "\n CasualWear: " + myEquipData.CasualWear)
EndFunction
