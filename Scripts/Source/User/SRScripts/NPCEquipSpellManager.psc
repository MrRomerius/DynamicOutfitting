Scriptname SRScripts:NPCEquipSpellManager extends Quest
{Adds/removes NPCs from WorkshopNPCs alias.}
;/
AUTHOR: MrRomerius
LICENSE: Feel free to reuse this code in whole or in part so long as proper authorship credit is given. Pay it forward!
NOTES: There have been issues with this script adding non-human NPCs. Has been taken care of, I think. Requires more monitoring just to be sure.
/;

; GROUPS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

RefCollectionAlias Property Alias_WorkshopNPCs Auto Const
{NPCs added to this alias get outfit changer spell added.}

WorkshopParentScript Property WorkshopParent Auto Const

ActorValue Property WorkshopRatingPopulation Auto Const

Race[] Property HumanRaces Auto Const

; EVENTS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Event WorkshopParentScript.WorkshopAddActor(WorkshopParentScript akSender, Var[] akArgs)
	Actor myNPC = akArgs[0] as Actor
	if bCanEquipClothes(myNPC) && myNPC.WaitFor3DLoad()
		Alias_WorkshopNPCs.AddRef(myNPC)
	endif
EndEvent

; FUNCTIONS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	; MAIN <=================================

Function ManageNPCOutfitting(WorkshopScript akWshop)
	Actor[] wshopNPCs = akWshop.GetWorkshopResourceObjects(WorkshopRatingPopulation) as Actor[]
	if wshopNPCs
		int i = 0
		int j = wshopNPCs.Length
		while i < j
			AddEquippableSettlers(wshopNPCs[i])
			i += 1
		endwhile
	endif
EndFunction

Function StartEquipSpellManager()
	RegisterForCustomEvent(WorkshopParent, "WorkshopAddActor")
EndFunction

Function AddEquippableSettlers(Actor akActor)
	if bCanEquipClothes(akActor)
		if bActorInWorkshopNPCRefCol(akActor)
			return
		endif
		Alias_WorkshopNPCs.AddRef(akActor)
	endif
EndFunction

;NOTE: Added failsafe in case ValidSettler() returns true on non-human NPCs and needs reworking.
Function ClearActorFromRefCol(Actor akActor)
	Alias_WorkshopNPCs.RemoveRef(akActor)
	Form myEquipData = Game.GetFormFromFile(0x004DEDBC, "DynamicOutfitting.esp")
	if akActor.GetItemCount(myEquipData)
		(akActor.DropObject(myEquipData) as SRScripts:NPCEquipData).DeleteEquipData()
	endif
	Debug.Trace(akActor + " cleared from WorkshopNPC refcol!")
EndFunction

bool Function bActorInWorkshopNPCRefCol(Actor akActor)
	return Alias_WorkshopNPCs.Find(akActor) > -1
EndFunction

; Returns true if actor is a person that can wear clothes.
bool Function bCanEquipClothes(Actor akActor)
	return HumanRaces.Find(akActor.GetLeveledActorBase().GetRace()) > -1 && (akActor as WorkshopNPCScript).bCountsForPopulation && !akActor is CompanionActorScript
EndFunction
