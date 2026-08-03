class_name Unit_blueprint

#CURRENT STATS
var Base_Character_name: String = "Unnamed_Default"
var Base_HP: int = 0
var Base_ATK: int = 0
var Base_DEF: int = 0
var Base_INT: int = 0
var Base_Speed: float = 0

var Base_DMG_ReceiveMultiplier: float = 1
var Base_DMG_Multiplier: float = 1

#CURRENT STATS
var Character_name: String = "Unnamed"
var HP: int = 0
var ATK: int = 0
var DEF: int = 0
var INT: int = 0
var Speed: float = 0

var DMG_ReceiveMultiplier: float = 1
var DMG_Multiplier: float = 1

#IN COMBAT
var combat_HP: int = 0
var combar_MaxHP: int = 0
var combat_ATK: int = 0
var combat_DEF: int = 0
var combat_Speed: float = 0
var ActionSpeed: float = 0
var ExtraAction: int = 0

#DAMAGE STUFF
var combat_DMG_ReceiveMultiplier: float = 1
var combat_DMG_Multiplier: float = 1

var IsUnitAlive: bool = true
var IsUnitFriendly: bool = true


#--Reset Function--
func ResetCombatStat():
	combar_MaxHP = HP
	combat_HP = combar_MaxHP
	combat_ATK = ATK
	combat_DEF = DEF
	combat_Speed = Speed
	ActionSpeed = combat_Speed
	ExtraAction = 0

func ResetExtraAction():
	ExtraAction = 0

func ResetActionSpeed():
	ActionSpeed = combat_Speed

func ResetCombatDmgMultiplier():
	combat_DMG_Multiplier = DMG_Multiplier

func ResetCombatDmgRecieveMultiplier():
	combat_DMG_ReceiveMultiplier = DMG_ReceiveMultiplier


func DamageThisUnit(TargetUnit: Unit_blueprint, DMG: int):
	var FinalDMG: int = (DMG - TargetUnit.combat_DEF * 0.5) * TargetUnit.combat_DMG_ReceiveMultiplier
	var UnitFinalHP: int = TargetUnit.combat_HP - FinalDMG
	
	if  UnitFinalHP <= 0:
		TargetUnit.IsUnitAlive = false
		TargetUnit.combat_HP = 0
	else:
		TargetUnit.combat_HP = UnitFinalHP

func MoveFirst(TargetUnit: Unit_blueprint):
	TargetUnit.ActionSpeed = 20

func MoveLast(TargetUnit: Unit_blueprint):
	TargetUnit.ActionSpeed = 0.1
