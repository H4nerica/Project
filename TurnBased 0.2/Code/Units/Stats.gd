class_name Stats

var Base: float = 0
var Normal: float = 0
var Combat: float = 0
var CombatMax: float = 0

var MultiplierBonus: float = 1.0
var FlatBonus: int = 0


#-- RESET --
func ResetCombatStat():
	Combat = Normal
	CombatMax = Normal
	
func ResetMultiplierBonus():
	MultiplierBonus = 1

func ResetFlatBonus():
	FlatBonus = 0

func Calculate_Stat():
	CombatMax = Normal * MultiplierBonus + FlatBonus
	
	if CombatMax < Combat:
		Combat = CombatMax
	
