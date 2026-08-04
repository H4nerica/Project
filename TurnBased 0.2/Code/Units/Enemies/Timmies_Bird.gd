class_name Timmies_Bird
extends Unit

func _init():
	Character_name = "Timmy's Bird"
	HP.Base = 12
	HP.Normal = 12
	
	ATK.Base = 12
	ATK.Normal = 12
	
	DEF.Base = 10
	DEF.Normal = 10
	
	Speed.Base = 6
	Speed.Normal = 6
	
	IsUnitFriendly = false
	ResetCombatStat()
	ExtraAction = 0
	
#COMBAT
func basicATK(TargetUnit: Unit):
	var FinalDMG: int = ATK.Combat
	DealDamage(TargetUnit, FinalDMG)
	print("DMG Dealt ", FinalDMG)
