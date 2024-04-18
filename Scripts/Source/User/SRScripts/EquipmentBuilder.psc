Scriptname SRScripts:EquipmentBuilder extends Quest
{Creates equipment objects for NPCs.}
;/
AUTHOR: MrRomerius
LICENSE: Feel free to reuse this code in whole or in part so long as proper authorship credit is given. Pay it forward!
NOTES: Scoring relies on getting vendor objects from O(n) locations every time player enters a settlement. Could be improved...
/;

import SRScripts:DynOutfitDataStructures
import SRScripts:DynOutfitUtilityFunctions

; VARS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

WorkshopParentScript Property WorkshopParent Auto Const

Group SleepOutfitLists
	; Default clothes items for npcs without access to clothing vendors.
	Armor[] Property SR_DefaultSleepClothesList Auto Const
	{Index for SR_DefaultSleepClothesList[]
	[0] = sr_DirtySleepwear_01 (Adult men and women get different outfit models from same armor form.)
	[1] = sr_DirtySleepwear_01 (Adult men and women get different outfit models from same armor form.)
	[2] = ClothesKids04 (For child NPCs.)}
	; Expanded lists of clean sleep clothes for npcs with access to clothing vendors.
	FormList[] Property SR_SleepClothesLists Auto Const
	{Index for SR_SleepClothesLists[]
	[0] = SR_SleepWearM (Casual clothes for men.)
	[1] = SR_SleepWearF (Casual clothes for women.)
	[2] = SR_SleepWearC (Casual clothes for kids.)}
EndGroup

; Prebuilt outfits for different jobs.
Group WorkClothesLists
	; Guard clothes can be supplemented by armor sets if armor store is available.
	FormList[] Property sr_GuardClothes Auto Const
	FormList[] Property sr_FarmerClothes Auto Const
	FormList[] Property sr_ScavengerClothes Auto Const
	FormList[] Property sr_ProvisionerClothes Auto Const
	; Each vendor type gets their own formlist array.
	FormList[] Property sr_VendorMiscClothes Auto Const
	FormList[] Property sr_VendorArmorClothes Auto Const
	FormList[] Property sr_VendorWeaponsClothes Auto Const
	FormList[] Property sr_VendorBarClothes Auto Const
	FormList[] Property sr_VendorClinicClothes Auto Const
	FormList[] Property sr_VendorClothingClothes Auto Const
EndGroup

; Women's fashion list will have the same items as men's but with feminine options.
Group CasualClothesLists
	FormList[] Property SR_CasualClothesLists Auto Const
	{Index for SR_CasualClothesLists[]
	[0] = SR_CasualWearM (Casual clothes for men.)
	[1] = SR_CasualWearF (Casual clothes for women.)}
	; Casual accessories.
	FormList Property SR_CasualEyewear Auto Const
	FormList Property SR_CasualHeadwear Auto Const
EndGroup

; IDs for formlists.
int property ClothesTypeDefault = -1 autoreadonly hidden
int property ClothesTypeSleep = 0 autoreadonly hidden
int property ClothesTypeWork = 1 autoreadonly hidden
int property ClothesTypeCasual = 2 autoreadonly hidden

; Values for job types.
int ID_Guard = 0 Const
int ID_Farmer = 1 Const
int ID_Scavenger = 2 Const
int ID_Provisioner = 3 Const
int ID_Vendor = 4 Const

; Values for store types.
int StoreTypeMisc = 0 Const
int StoreTypeArmor = 1 Const
int StoreTypeWeapons = 2 Const
int StoreTypeBar = 3 Const
int StoreTypeClinic = 4 Const
int StoreTypeClothing = 5 Const
int StoreTypeChems = 6 Const

; FUNCTIONS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	; MAIN <=================================

Form[] Function GetSleepClothes(int aiOutfitID, int aiActorType)
	if aiOutfitID == ClothesTypeDefault
		return BuildOutfit(SR_DefaultSleepClothesList[aiActorType])
	endif
	return BuildOutfit(PickRandomForm(SR_SleepClothesLists[aiActorType]))
EndFunction

Form[] Function GetWorkClothes(int aiJobID, int aiVendorID = -1)
	if aiJobID == ID_Guard
		return ConvertFormListToFormArray(PickRandomOutfit(sr_GuardClothes))
	elseif aiJobID == ID_Farmer
		return ConvertFormListToFormArray(PickRandomOutfit(sr_FarmerClothes))
	elseif aiJobID == ID_Scavenger
		return ConvertFormListToFormArray(PickRandomOutfit(sr_ScavengerClothes))
	elseif aiJobID == ID_Provisioner
		return ConvertFormListToFormArray(PickRandomOutfit(sr_ProvisionerClothes))
	elseif aiJobID == ID_Vendor
		if aiVendorID > -1
			return ConvertFormListToFormArray(PickRandomOutfit(GetVendorOutfitFLArray(aiVendorID)))
		endif
		return ConvertFormListToFormArray(Game.GetFormFromFile(0x00440E12, "DynamicOutfitting.esp") as FormList)
	endif
	Debug.Trace("ERROR: Work clothes not built!")
	return NONE
EndFunction

FormList[] Function GetVendorOutfitFLArray(int aiIndex)
	if aiIndex == StoreTypeMisc
		return sr_VendorMiscClothes
	elseif aiIndex == StoreTypeArmor
		return sr_VendorArmorClothes
	elseif aiIndex == StoreTypeWeapons
		return sr_VendorWeaponsClothes
	elseif aiIndex == StoreTypeBar
		return sr_VendorBarClothes
	elseif aiIndex == StoreTypeClinic
		return sr_VendorClinicClothes
	elseif aiIndex == StoreTypeClothing
		return sr_VendorClothingClothes
	endif
	Debug.Trace("ERROR: Vendor not found!")
	return NONE
EndFunction

Form[] Function GetCasualClothes(int aiOutfitID, int aiActorType)
	return BuildOutfit(SR_CasualClothesLists[aiActorType], aiOutfitID)
EndFunction
	
	; OUTFIT CREATION <=================================
	
Form[] Function BuildOutfit(Form akForm, int aiOutfitID = -1)
	Form[] myClothes = new Form[0]
	myClothes.Add(akForm)
	if aiOutfitID > -1
		AddAccessories(myClothes, aiOutfitID)
	endif
	return myClothes
EndFunction

Function AddAccessories(Form[] akForms, int aiOutfitID)
	if aiOutfitID == ClothesTypeCasual
		RollAddOn(akForms, SR_CasualEyewear, RollChance(30))
		RollAddOn(akForms, SR_CasualHeadwear, RollChance(20))
	endif
EndFunction

Function RollAddOn(Form[] akOutfit, Formlist akFormList, bool bRollSuccess)
	if bRollSuccess
		Form myAccessory = PickRandomForm(akFormList)
		if myAccessory
			akOutfit.Add(myAccessory)
		endif
	endif
EndFunction
