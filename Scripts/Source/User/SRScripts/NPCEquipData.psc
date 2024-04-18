Scriptname SRScripts:NPCEquipData extends ObjectReference
{NPCs equipment data variables are stored here.}
;/
AUTHOR: MrRomerius
LICENSE: Feel free to reuse this code in whole or in part so long as proper authorship credit is given. Pay it forward!
NOTES: N/A
/;

import SRScripts:DynOutfitUtilityFunctions

int Property ActorType = -1 Auto
int Property ClothingLevel = -2 Auto

Form[] Property DefaultWear Auto
Form[] Property CustomWear Auto
Form[] Property SleepWear Auto
Form[] Property WorkWear Auto
Form[] Property CasualWear Auto

; FUNCTIONS <==============================================

Function InitializeEquipData(int aiActorType)
	ActorType = aiActorType
	DefaultWear = new Form[0]
	CustomWear = new Form[0]
	SleepWear = new Form[0]
	WorkWear = new Form[0]
	CasualWear = new Form[0]
	Debug.Trace("SUCCESS: EquipData created! Initialization done!")
EndFunction

Function ResetEquipData(int aiActorType)
	ActorType = aiActorType
	ClothingLevel = -2
	SleepWear.Clear()
	WorkWear.Clear()
	CasualWear.Clear()
	Debug.Trace("SUCCESS: EquipData reset!")
EndFunction

Function SaveEquipData(SRScripts:WorkshopNPCOutfitChanger akChanger)
	ClothingLevel = akChanger.ClothingLevel
	CustomWear = akChanger.CustomWear
	SleepWear = akChanger.SleepWear
	WorkWear = akChanger.WorkWear
	CasualWear = akChanger.CasualWear
	Debug.Trace("SUCCESS: EquipData saved on: " + akChanger.myNPC)
EndFunction

Function DeleteEquipData()
	ActorType = 0
	ClothingLevel = 0
	DefaultWear = NONE
	CustomWear = NONE
	SleepWear = NONE
	WorkWear = NONE
	CasualWear = NONE
	Delete()
EndFunction
