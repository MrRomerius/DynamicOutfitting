Scriptname SRScripts:MainEventBroker extends Quest
{Event broker handles custom events sent by other scripts.}
;/
AUTHOR: MrRomerius
PERMISSIONS: Feel free to reuse parts of this code you find useful so long as proper credit is given and these comments maintained
in any duplication or repurposing. Pay it forward!
NOTES: This is a centralized broker that handles custom events sent by other scripts. It can be expanded to handle more scripts and events.
/;

; GROUPS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Group Scripts
	SRScripts:PlayerLocationHandler Property LocHandler Auto Const
	SRScripts:LocalVendorScore Property VendorScore Auto Const
	SRScripts:NPCEquipSpellManager Property SpellManager Auto Const
EndGroup

; EVENTS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Event SRScripts:PlayerLocationHandler.ScoreLocalVendors(SRScripts:PlayerLocationHandler akSender, Var[] akArgs)
	VendorScore.ScoreAllVendors(akArgs[0] as WorkshopScript)
EndEvent

Event SRScripts:PlayerLocationHandler.AddNewSettlers(SRScripts:PlayerLocationHandler akSender, Var[] akArgs)
	SpellManager.ManageNPCOutfitting(akArgs[0] as WorkshopScript)
EndEvent

; FUNCTIONS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Function ActivateAllScripts()
	RegisterForCustomEvent(LocHandler, "ScoreLocalVendors")
	RegisterForCustomEvent(LocHandler, "AddNewSettlers")
	RegisterForCustomEvent(VendorScore, "LocalVendorScoresUpdated")
	SpellManager.StartEquipSpellManager()
	VendorScore.StartLocalVendorScore()
	LocHandler.StartLocHandler()
EndFunction
