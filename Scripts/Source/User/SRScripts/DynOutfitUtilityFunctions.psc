Scriptname SRScripts:DynOutfitUtilityFunctions Hidden Const
;/
AUTHOR: MrRomerius
LICENSE: Feel free to reuse this code in whole or in part so long as proper authorship credit is given. Pay it forward!
NOTES: Scoring relies on getting vendor objects from O(n) locations every time player enters a settlement. Could be improved...
/;

int Function GetActorType(Actor akActor, int aiChild = 2) global
	if akActor.IsChild()
		return aiChild
	endif
	return akActor.GetLeveledActorBase().GetSex()
EndFunction

Form[] Function ConvertFormListToFormArray(FormList akFormList) global
	Form[] myFormArray = new Form[0]
	if akFormList
		int i = 0
		int j = akFormList.GetSize()
		while i < j
			myFormArray.Add(akFormList.GetAt(i))
			i += 1
		endwhile
	endif
	return myFormArray
EndFunction

bool Function RollChance(int aiPercentChance, int aiRangeStart = 1, int aiRangeEnd = 100) global
	return Utility.RandomInt(aiRangeStart, aiRangeEnd) <= aiPercentChance
EndFunction

Form Function PickRandomForm(FormList akFormList) global
	if akFormList
		return akFormList.GetAt(Utility.RandomInt(0, akFormList.GetSize() - 1))
	endif
	return NONE
EndFunction

FormList Function PickRandomOutfit(FormList[] akOutfitList) global
	if akOutfitList
		return akOutfitList[Utility.RandomInt(0, akOutfitList.Length - 1)]
	endif
	return NONE
EndFunction

bool Function bSpecialCaseNPC(Actor akActor) global
	if akActor
		return akActor.GetLeveledActorBase().IsUnique() || akActor.IsChild() || akActor is CompanionActorScript
	endif
	return false
EndFunction

bool Function bHasVendorAccess(int aiNPCLevel, int aiVendorLevel) global
	return aiNPCLevel >= aiVendorLevel
EndFunction
