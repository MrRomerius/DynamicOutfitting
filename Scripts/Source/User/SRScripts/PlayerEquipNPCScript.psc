Scriptname SRScripts:PlayerEquipNPCScript extends ReferenceAlias
{Script for adding/removing equipped items from NPC's CustomWear array.}
;/
AUTHOR: MrRomerius
LICENSE: Feel free to reuse this code in whole or in part so long as proper authorship credit is given. Pay it forward!
NOTES: Scoring relies on getting vendor objects from O(n) locations every time player enters a settlement. Could be improved...
/;

; VARS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Message Property SR_ConfirmOutfit Auto Const

SRScripts:WorkshopNPCOutfitChanger myChanger

Actor npcTemp

Form[] customwearTemp

bool bClothesAltered = false

bool bMagicEffectOff = false

; EVENTS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
	if asMenuName == "ContainerMenu"
		if abOpening
			npcTemp = myChanger.myNPC
			customwearTemp = myChanger.GetEquipData().CustomWear
			RegisterNPCMenuEvents()
			return
		endif
		EndPlayerMenuEvent()
	endif
EndEvent

Event Actor.OnItemEquipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
	if akBaseObject as Armor
		bClothesAltered = true
		if customwearTemp.Find(akBaseObject) < 0
			customwearTemp.Add(akBaseObject)
		endif
	endif
EndEvent

Event Actor.OnItemUnequipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
	if akBaseObject as Armor
		bClothesAltered = true
		int index = customwearTemp.Find(akBaseObject)
		if index > -1
			customwearTemp.Remove(index)
		endif
	endif
EndEvent

Event ActiveMagicEffect.OnEffectFinish(ActiveMagicEffect akSender, Actor akTarget, Actor akCaster)
	bMagicEffectOff = true
EndEvent

; FUNCTIONS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Function StartPlayerMenuEvent(SRScripts:WorkshopNPCOutfitChanger akChanger)
	ResetVars() ; make sure there's no previous values.
	myChanger = akChanger
	RegisterForMenuOpenCloseEvent("ContainerMenu")
EndFunction

Function RegisterNPCMenuEvents()
	RegisterForRemoteEvent(myChanger, "OnEffectFinish")
	RegisterForRemoteEvent(npcTemp, "OnItemEquipped")
	RegisterForRemoteEvent(npcTemp, "OnItemUnequipped")
EndFunction

Function EndPlayerMenuEvent()
	UnregisterForMenuOpenCloseEvent("ContainerMenu")
	UnregisterForRemoteEvent(npcTemp, "OnItemEquipped")
	UnregisterForRemoteEvent(npcTemp, "OnItemUnequipped")
	if bClothesAltered
		if SR_ConfirmOutfit.Show() == 0
			myChanger.GetEquipData().SaveEquipData(myChanger)
			myChanger.SetEquipmentVars()
			myChanger.SetClothesFromAIPackage()
			return
		endif
		customwearTemp.Clear() ; reset
	endif
	if bMagicEffectOff
		npcTemp.AddSpell(Game.GetFormFromFile(0x0040DA40, "DynamicOutfitting.esp") as Spell)
	endif
	ResetVars()
EndFunction

Function ResetVars()
	bClothesAltered = false
	bMagicEffectOff = false
	myChanger = NONE
	npcTemp = NONE
	customwearTemp = NONE
EndFunction
