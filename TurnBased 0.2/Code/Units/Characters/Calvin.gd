class_name Calvin
extends Unit

func _init():
	Character_name = "Calvin"
	HP.Base = 20
	HP.Normal = 20
	
	ATK.Base = 20
	ATK.Normal = 20
	
	DEF.Base = 10
	DEF.Normal = 10
	
	Speed.Base = 6.5
	Speed.Normal = 6.5
	
	ResetCombatStat()
	
#COMBAT
func basicATK(TargetUnit: Unit):
	var FinalDMG: int = ATK.Combat
	DealDamage(TargetUnit, FinalDMG)
	print("DMG Dealt ", FinalDMG)
