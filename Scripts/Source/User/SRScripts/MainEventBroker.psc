Scriptname SRScripts:MainEventBroker extends Quest
{Event broker handles custom events sent by other scripts.}
;/
AUTHOR: MrRomerius
LICENSE: Feel free to reuse this code in whole or in part so long as proper authorship credit is given. Pay it forward!
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
