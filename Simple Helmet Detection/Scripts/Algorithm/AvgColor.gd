extends Node
class_name AvgColor

#DATA
var data_AVG = {}
var data_AVG_Array = []

#COLOR STUFF
var averageColor: Color
var totalColor = []
var sumColor: Color = Color(0,0,0,0)

func getColorAvg(loaded_IMG: Image, Avg_txt: LineEdit, colorBox: ColorRect):
	if loaded_IMG == null:
		return
	
	var width = loaded_IMG.get_width()
	var height = loaded_IMG.get_height()
	var color
	
	for x in range(width):
		for y in range(height):
			color = loaded_IMG.get_pixel(x,y)
			
			if color.a != 0:
				totalColor.append(color)
				sumColor += color
	averageColor = sumColor / totalColor.size()
	#Saved it to array
	data_AVG_Array.append(averageColor)
	
	print("Average RBGA: ", averageColor * 255)
	print("Average: ", averageColor)
	
	#Change UI color stuff
	Avg_txt.text = str(averageColor)
	Avg_txt.add_theme_color_override("font_color", Color(averageColor))
	colorBox.color = averageColor


#--- Helper ---
func saveAverageColor():
	for index in range(data_AVG_Array.size()):
		data_AVG["Dataset_" + str(index)] = data_AVG_Array[index]
	
	#Saved it to json
	var file = FileAccess.open("user://DatasetJSON/dataset.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data_AVG))
	file.close()
	
func loadAverageColor(path):
	#print(path)
	SaveData.isLoaded = true
	SaveData.Dataset_Target.clear()
	
	var file = FileAccess.open(path, FileAccess.READ)
	var raw_text = file.get_as_text()
	file.close()
	
	raw_text = raw_text.replace("(", "")
	raw_text = raw_text.replace(")", "")
	var data = JSON.parse_string(raw_text)

	for i in range(data.size()):
		var value = data["Dataset_" + str(i)]
		var perPart = value.split(",")
		
		var colorData = Color(
		float(perPart[0]),
		float(perPart[1]),
		float(perPart[2]),
		float(perPart[3])
		)
		
		SaveData.Dataset_Target.append(colorData)
	#print(SaveData.Dataset_Target)
	print("Dataset Loaded!")
	
	if is_instance_valid(SaveData.debug_txt):
		SaveData.debug_txt.text = "DataSet LOADED"
	
	
	
