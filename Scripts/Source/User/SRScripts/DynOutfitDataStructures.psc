Scriptname SRScripts:DynOutfitDataStructures Hidden Const

; STRUCTS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

; Only workshopID is set at a fixed value by LocalVendorScore script. Other values change depending on available vendors.
struct LocalVendorScores

	int storeMisc = -1
	int storeArmor = -1
	int storeWeapons = -1
	int storeBar = -1
	int storeClinic = -1
	int storeClothing = -1
	int storeChems = -1

endstruct

; Key-value pair for equipment data retrieval.
struct WorkshopNPCEquipData

	Actor WorkshopNPC = NONE
	{Our settler.}
	
	SRScripts:NPCEquipData EquipData = NONE
	{Our settler's equipment data.}
	
endstruct
