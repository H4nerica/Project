class_name Timmies_Bird
extends Unit_blueprint

func _init():
	Character_name = "Timmy's Bird"
	HP = 40
	ATK = 5
	DEF = 0
	Speed = 8
	
	IsUnitFriendly = false
	ResetCombatStat()
	ExtraAction = 2
	
#COMBAT
func basicATK(TargetUnit: Unit_blueprint):
	var FinalDMG: int = combat_ATK * combat_DMG_Multiplier
	DamageThisUnit(TargetUnit, FinalDMG)
	print("DMG Dealt ", FinalDMG)
