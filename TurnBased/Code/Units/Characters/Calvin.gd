class_name Calvin
extends Unit_blueprint

func _init():
	Character_name = "Calvin"
	HP = 12
	ATK = 20
	DEF = 10
	Speed = 6.5
	
	ResetCombatStat()
	
#COMBAT
func basicATK(TargetUnit: Unit_blueprint):
	var FinalDMG: int = combat_ATK * combat_DMG_Multiplier
	DamageThisUnit(TargetUnit, FinalDMG)
	print("DMG Dealt ", FinalDMG)
