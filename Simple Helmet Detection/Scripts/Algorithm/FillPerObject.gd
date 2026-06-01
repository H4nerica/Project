extends Node
class_name fillPerObject


func scanningIntoArray(ImgORI: Image, start_Y: int, targetArray:String):
	#ImgStuff
	var imgSize: Vector2 = ImgORI.get_size()
	
	#Grouping
	var imgOri_Array: Array = []
	var allPixelInOrder: Array = []
	var allGroup: Array = []
	
	#Counter
	var counter0: int = 0
	var counter1: int = 0
	
	#Scanning for pixel then cahnge it into array
	for x in range(imgSize.x):
		var currentPX: Color = ImgORI.get_pixel(x, start_Y)
		if currentPX.a != 0:
			imgOri_Array.append(1)
		else:
			imgOri_Array.append(0)
	#print("Array: ", imgOri_Array)
	
	#Change pixel i
	for x in range(imgOri_Array.size()):
		var current_value: int = imgOri_Array[x]
		
		#Count and store object
		if current_value == 1:
			counter1 += 1
		else:
			if counter1 != 0:
				allPixelInOrder.append(1)
				allGroup.append(counter1)
			counter1 = 0
		
		#Count and store gap
		if current_value == 0:
			counter0 += 1
		else:
			if counter0 != 0:
				allPixelInOrder.append(0)
				allGroup.append(counter0)
			counter0 = 0
			
	#IF the counter has leftover save that too. 
	if counter0 != 0:
		allGroup.append(counter0)
		allPixelInOrder.append(0)
	if counter1 != 0:
		allGroup.append(counter1)
		allPixelInOrder.append(1)
		
	#print("All pixel in order: ", allPixelInOrder)
	#print("All group: ", allGroup)
	fillFromArray(allGroup, allPixelInOrder, targetArray)

func fillFromArray(allGroup: Array, allPixelInOrder: Array, targetArray:String):
	var Counter: int = 0
	var total: int = 0
	var average: int
	var objectArray: Array = allPixelInOrder.duplicate()
	
	for i in range(objectArray.size()):
		if objectArray[i] == 0:
			total += allGroup[i]
			Counter += 1
	average = total / Counter
	
	#start counting from 1 until max - 1.
	for i in range(1, objectArray.size() - 1):
		if objectArray[i] == 0:
			if allGroup[i] >= average:
				#print("Gap")
				objectArray[i] = 0
			else: 
				#print("Holes")
				objectArray[i] = 1
	#print(objectArray)
	
	var howManyObjectArray: int = 0
	Counter = 0 # Reset countere to be used again
	for i in range(objectArray.size()):
		if objectArray[i] == 1:
			Counter += 1
		else: 
			if Counter > 0:
				howManyObjectArray += 1
				Counter = 0
	SaveData[targetArray].append(howManyObjectArray)
	
	
