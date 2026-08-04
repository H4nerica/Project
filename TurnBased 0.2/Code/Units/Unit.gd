class_name Unit

#Stats
var Character_name: String = "Unnamed"
var HP: Stats = Stats.new()
var ATK: Stats = Stats.new()
var DEF: Stats = Stats.new()
var Speed: Stats = Stats.new()

#Turn stuff
var ActionSpeed: float = 0
var ExtraAction: int = 0

#Unit Status
var IsUnitAlive: bool = true
var IsUnitFriendly: bool = true


#--Reset Function--
func ResetCombatStat():
	HP.ResetCombatStat()
	ATK.ResetCombatStat()
	DEF.ResetCombatStat()
	Speed.ResetCombatStat()
	ActionSpeed = Speed.Combat
	ExtraAction = 0


#--Combat--
func DealDamage(TargetUnit: Unit, Dmg: int):
	var FinalDmg: int = Dmg - TargetUnit.DEF.Combat * 0.5
	if FinalDmg <= 0:
		FinalDmg = 10
		
	var UnitFinalHP: int = TargetUnit.HP.Combat - FinalDmg
	
	if  UnitFinalHP <= 0:
		TargetUnit.IsUnitAlive = false
		TargetUnit.HP.Combat = 0
	else:
		TargetUnit.HP.Combat = UnitFinalHP


#--Action/Speed stuff--
func MoveFirst(TargetUnit: Unit):
	TargetUnit.ActionSpeed = 20

func MoveLast(TargetUnit: Unit):
	TargetUnit.ActionSpeed = 0.1

func ResetExtraAction():
	ExtraAction = 0

func ResetActionSpeed():
	ActionSpeed = Speed.Combat
