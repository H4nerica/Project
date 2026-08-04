extends Node2D

#GLOBAL
var InCombat: bool = true
var ContinueCycle: bool = true
var CycleCounts: int = 2

var calvin = Calvin.new()
var TimmiesBird = Timmies_Bird.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	StartCombat()
	
	
func Action(UnitOnField: Array[Unit], FriendlyUnitCounts: int, EnemiesUnitCounts: int):
	#Count Enemy And Player units then use that as turn per cycle
	var CurrentlyAliveUnit: int = FriendlyUnitCounts + EnemiesUnitCounts
	var Total_ActionRemaining: int = CurrentlyAliveUnit
	
	for i in range(UnitOnField.size()):
		UnitOnField[i].ResetActionSpeed()
	
	#Whose turn is currently.
	var CurrentUnitsAction: Unit
	
	while ContinueCycle == true:
		#Checking currently alive unit per turn.
		var FriendlyUnit: int = CheckUnitAlive(UnitOnField, true) 
		var EnemiesUnit: int = CheckUnitAlive(UnitOnField, false)
		var highestSPD: float = 0
		
		print("-----------")
	
		#Check if this cycle is done.
		if Total_ActionRemaining == 0:
			print("End of this Cycle")
			ContinueCycle = false
			break
			
		#Check for a unit with highest speed, then give them turn.
		for i in range(UnitOnField.size()):
			if UnitOnField[i].ActionSpeed > highestSPD and UnitOnField[i].IsUnitAlive == true:
				highestSPD = UnitOnField[i].ActionSpeed
				CurrentUnitsAction = UnitOnField[i]
		
		#Set this unit to 0, because its already moved. if he has extra action remove -1 that instead of Total_ActionRemaining.
		if CurrentUnitsAction.ExtraAction > 0:
			CurrentUnitsAction.ResetActionSpeed()
			CurrentUnitsAction.ExtraAction -= 1
			print("Extra Turn: ", CurrentUnitsAction.ExtraAction)
		else:
			CurrentUnitsAction.ActionSpeed = 0
			Total_ActionRemaining -= 1
				
		print(highestSPD, " Speed")
		print(CurrentUnitsAction.Character_name, "'s Turn")
		print("Turn End")
		  
	#Check whose side wins
	#EndCombat(FriendlyUnitCounts, EnemiesUnitCounts)
	print("Alive Unit Count: ", CurrentlyAliveUnit)
	
	#Reset thier turn speed back to default
	for i in range(UnitOnField.size()):
		UnitOnField[i].ResetActionSpeed()


func CheckUnitAlive(UnitOnField: Array[Unit], IsUnitFriendly_Target: bool):
	var CurrentUnitAlive: int = 0
	
	for i in range(UnitOnField.size()):
		if UnitOnField[i].IsUnitAlive == true and UnitOnField[i].IsUnitFriendly == IsUnitFriendly_Target:
			CurrentUnitAlive += 1
			
	return CurrentUnitAlive
	
func DeathCheck(FriendlyUnit: int, EnemiesUnit: int):
	print("F: ", FriendlyUnit)
	print("E: ", EnemiesUnit)
	
	if EnemiesUnit == 0 and FriendlyUnit > 0:
		ContinueCycle = false
		print("--- Victory ---")
		
	elif FriendlyUnit == 0 and EnemiesUnit > 0:
		ContinueCycle = false
		print("--- Lost ---")
	
	else: 
		print("Next Cycle")

func StartCombat():
	#Build both team
	var UnitOnField: Array[Unit] = [calvin, TimmiesBird]
	
	#Count currently alive unit
	var FriendlyUnit: int = CheckUnitAlive(UnitOnField, true) 
	var EnemiesUnit: int = CheckUnitAlive(UnitOnField, false)
	
	for i in range(1):
		Action(UnitOnField, FriendlyUnit, EnemiesUnit)
		ContinueCycle = true
