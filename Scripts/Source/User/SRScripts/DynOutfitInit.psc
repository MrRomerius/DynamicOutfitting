Scriptname SRScripts:DynOutfitInit extends Quest
{Simple controller script that activates our mod's main functions when player enters post-war worldspace.}
;/
AUTHOR: MrRomerius
PERMISSIONS: Feel free to reuse parts of this code you find useful so long as proper credit is given and these comments maintained
in any duplication or repurposing. Pay it forward!
NOTES: 
/;

; VARS ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Group Messages
	Message Property SR_DynOutInstallMsg Auto Const
	Message Property SR_DynOutUpdateMsg Auto Const
EndGroup

Actor Property PlayerRef Auto Const

; Out of Time quest.
Quest Property MQ102 Auto Const

; CURRENT VERSION: 1.0 Beta (update this note when releasing new version.)
GlobalVariable Property SR_DynOutfitVersion Auto Const

; Timer IDs.
int TimerID_RetryWorldspace = 100 Const
float fTimerLen = 2.0 Const

; Quest stages.
int StageID_Init = 10 Const
int StageID_Active = 20 Const
int StageID_V111Exit = 10 Const

; Updates to current version on fresh installs.
float iLastVersionInstalled = 0.0

; EVENTS //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Event OnQuestInit()
	RegisterForPlayerTeleport()
	RegisterForRemoteEvent(MQ102, "OnStageSet")
	TryToStartDynamicOutfitting()
EndEvent

Event OnPlayerTeleport()
	TryToStartDynamicOutfitting()
EndEvent

Event OnTimer(int aiTimerID)
	if aiTimerID == TimerID_RetryWorldspace
		TryToStartDynamicOutfitting()
	endif
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
	CheckForUpdates()
EndEvent

Event Quest.OnStageSet(Quest akSender, int auiStageID, int auiItemID)
	ShowInstallMsg(auiStageID)
EndEvent

; FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	; MAIN <=================================

Function TryToStartDynamicOutfitting()
	WorldSpace myWorldSpace = PlayerRef.GetWorldSpace()
	WorldSpace prewarWorldSpace = Game.GetFormFromFile(0x000A7FF4, "Fallout4.esm") as WorldSpace
	if IsRunning() && myWorldSpace && prewarWorldSpace
		if myWorldSpace != prewarWorldSpace
			StartDynamicOutfitting()
		endif
		return
	endif
	StartTimer(fTimerLen, TimerID_RetryWorldspace)
EndFunction

Function StartDynamicOutfitting()
	SetStage(StageID_Active)
	RegisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")
	UnregisterForPlayerTeleport()
	((self as Quest) as SRScripts:MainEventBroker).ActivateAllScripts()
	SetInstallVersion(GetModVersion())
	ShowInstallMsg(MQ102.GetCurrentStageID())
EndFunction

; Updates to latest version if global is edited.
Function CheckForUpdates()
	float myCurrentVersion = GetModVersion()
	if myCurrentVersion > iLastVersionInstalled
		SR_DynOutUpdateMsg.Show(iLastVersionInstalled, myCurrentVersion)
		SetInstallVersion(myCurrentVersion)
	endif
EndFunction

Function ShowInstallMsg(int aiStageID)
	if MQ102.IsCompleted() || (MQ102.IsRunning() && aiStageID >= StageID_V111Exit)
		UnregisterForRemoteEvent(MQ102, "OnStageSet")
		SR_DynOutInstallMsg.Show(GetModVersion())
	endif
EndFunction

	; HELPERS <=================================

float Function GetModVersion()
	return SR_DynOutfitVersion.GetValue()
EndFunction

Function SetInstallVersion(float afVersion)
	iLastVersionInstalled = afVersion
EndFunction
