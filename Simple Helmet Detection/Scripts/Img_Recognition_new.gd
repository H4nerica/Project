extends Node

#UI
@export_group("UI - Stuff")
@export var picBoxAsli: TextureRect
@export var file_dialog: FileDialog
@export var picBoxParent: Node

@export_group("UI - Debug")
@export var debug_txt: Label
@export var colorBox: ColorRect
@export var FPS_Counter: Label
@export var StatusLable: Label
@export var Minpixel_info: Label
@export var objectCount_txt: Label

#IMAGE STUFF
@export_group("Color Stuff")
@export var difference_color: Vector3 = Vector3(20, 70, 20)
var loaded_IMG : Image
var output_IMG = []
var targetColor: Vector4 = SaveData.targetColor

#Take From Other Script
var segment_IMG = CutIntoSegment.new()
var color_IMG = colorDetection.new()
var avg_IMG = AvgColor.new()
var scene_Helper = sceneChange.new()
var FeatureEXT = FeatureExtract.new()
var Fillgap = fillPerObject.new()
var contrastScan = contrastSCAN.new()

func _ready() -> void:
	file_choser()
	change_UI_Color()
	update_StatusLabel()
	SaveData.debug_txt = debug_txt 
	update_MinPixelTxt(Minpixel_info)
	
func _process(_delta: float) -> void:
	FPS_Counter.text = "|FPS: " + str(Engine.get_frames_per_second())


#--- File Dialog --
func _on_asli_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Img Is Clicked")
		file_dialog.popup_centered()

func file_choser():
	file_dialog.current_dir = OS.get_environment("USERPROFILE") + "/Pictures"
	file_dialog.filters = PackedStringArray([
		"*.png ; PNG Images",
		"*.jpg ; JPG Images",
		"*.jpeg ; JPEG Images"
	])
	
	file_dialog.file_selected.connect(proses)

func proses(path):
	var img = Image.new()
	var err = img.load(path)

	if err != OK:
		print("failed")
		return
	
	print("file selected")
	
	change_texture_original(img)
	loaded_IMG = img


#--- Helper ---
func change_texture_original(img):
	var texture = ImageTexture.create_from_image(img)
	picBoxAsli.texture = texture

func Change_Seg_Picture():
	#take the image from segment_IMG.scan 
	var result = segment_IMG.Cut(loaded_IMG, 6) #6 Slices btw, dont forget to add more picture on editor
	output_IMG = result #save it to array
	
	if result == null:
		return
		
	for i in range(result.size()):
		get_node("UI - Segment/Segment" + str(i)).texture = ImageTexture.create_from_image(result[i])
		
	if result == null:
		print("Empty")
		return
	#print("Successfully Cutting")
	debug_txt.text = "Cutting The Image Into Segment.."

func Change_Seg_ColorBox(index: int, location: Color):
	get_node("UI - Segment/Color/Segment" + str(index)).color = Color(location)

func change_UI_Color():
	colorBox.color = Color(
	SaveData.targetColor.x/255, 
	SaveData.targetColor.y/255, 
	SaveData.targetColor.z/255, 
	SaveData.targetColor.w/255
	)

func UpdateLabelnDebug():
	if SaveData.isLoaded == false:
		debug_txt.text = "There is no dataset loaded!!"
		return
		
	debug_txt.text = str("Helmet identified ", "(", SaveData.matchFoond, ")")
	print("Match Found: ", SaveData.matchFoond, " Matched")
	print("Not Found: ", SaveData.matchNotF, " Times")
	#matchedScore(SaveData.matchFoond, SaveData.matchNotF, SaveData.Dataset_Target.size())

func resetMatchFound():
	SaveData.matchFoond = 0
	SaveData.matchNotF = 0
	
func resetSegmentAverage():
	color_IMG.segmentColor.clear()

func update_StatusLabel():
	if SaveData.isLoaded == false:
		StatusLable.text = "NO DATA LOADED"
		StatusLable.add_theme_color_override("font_color", Color(0.839, 0.0, 0.118, 1.0))
	if SaveData.isLoaded == true:
		StatusLable.text = "DATA IS READY"
		StatusLable.add_theme_color_override("font_color", Color(0.0, 0.827, 0.357, 1.0))

func update_MinPixelTxt(label: Label):
	label.text = "|Min Pixel: " + str(SaveData.minPixel * 100) + "%"

func proccessButtonDisabled(state: bool):
	var cut: Button = $"UI - Button2/Proses/ProsesCut"
	var Feature: Button = $"UI - Button2/Proses/ProsesFeatures"
	#var Extract: Button = $"UI - Button2/Proses/ProsesExtract"
	var OBject: Button = $"UI - Button2/Proses/ProsesObject"
	var Clear: Button = $"UI - Button2/Proses/ProsesFeatures/ProsesSecondPass"
	
	cut.disabled = state
	Feature.disabled = state
	#Extract.disabled = state
	OBject.disabled = state
	Clear.disabled = state

func resetSegmentArray():
	SaveData.objectShapeArray0.clear()
	SaveData.objectShapeArray1.clear()
	SaveData.objectShapeArray2.clear()
	SaveData.objectShapeArray3.clear()
	SaveData.objectShapeArray4.clear()
	SaveData.objectShapeArray5.clear()


#--- Input ---
func _on_proses_cut_pressed() -> void:
	Change_Seg_Picture()
	
func _on_proses_extract_pressed() -> void:
	pass
	
func extract():
	for i in range(SaveData.FeatureExt.size()):
		var result = contrastScan.convertGrayscale(SaveData.FeatureExt[i], 0)
		get_node("UI - Segment/Segment" + str(i)).texture = ImageTexture.create_from_image(result)
		await get_tree().process_frame

#-- Data Stuff --
func _on_load_dataset_pressed() -> void:
	avg_IMG.loadAverageColor(SaveData.DefaultPath)
	update_StatusLabel()
	
func _on_proses_search_pressed() -> void:
	color_IMG.IsFound = false
	color_IMG.matchMaking()
	UpdateLabelnDebug()
	resetMatchFound()
	#print(color_IMG.segmentColor) #for debuggin the array 
	
#-- Scene Changing Stuff --
func _on_change_scene_pressed() -> void:
	scene_Helper.switch_to_ModelData()

#-- Test --
func _on_proses_proto_pressed() -> void:
	print("Extract: ", SaveData.ColorExtract_IMG.size())
	print("Hsv: ", SaveData.ClearingIMG.size())
	
	resetSegmentArray()
	var array_ID: String
	
	for i in range(SaveData.ClearingIMG.size()):
		var img: Image = SaveData.ClearingIMG[i]
		var height = img.get_height()
		get_node("UI - Segment/Segment" + str(i)).texture = ImageTexture.create_from_image(ClearSecondPASS.removeNoise(img, i))
		
		array_ID = "objectShapeArray" + str(i)
		for y in range(height):
			var result = Fillgap.scanningIntoArray(SaveData.ClearingIMG[i], y, array_ID)
		
		#print("Height of segment ", i, " : ", height)
		print(SaveData[array_ID])
		countObject(SaveData[array_ID])
	changeLabelObjectCount()
	
func changeLabelObjectCount():
	print(SaveData.objectCOUNT)
	var sex1 = str(SaveData.objectCOUNT[0])
	var sex2 = str(SaveData.objectCOUNT[1])
	var sex3 = str(SaveData.objectCOUNT[2])
	var sex4 = str(SaveData.objectCOUNT[3])
	var sex5 = str(SaveData.objectCOUNT[4])
	var sex6 = str(SaveData.objectCOUNT[5])
	objectCount_txt.text = "| " + sex1 + " | " + sex2 + " | " + sex3 + " | " + sex4 + " | " + sex5 + " | " + sex6 + " |"
	
func countObject(array: Array):
	var objectsCount: int = 0
	var counter: int = 0
	var objectArrays: Array = []
	var highest: int = 0
	
	for i in range(array.size()):
		if objectsCount < array[i]: 
			if array[i] > 0:
				objectsCount += 1
	print("Object COunt highest: ", objectsCount)

	for i in range(array.size()):
		if array[i] > highest:
			highest = array[i]

	for i in range(1, highest + 1):
		counter = 0
	
		for j in range(array.size()):
			if array[j] == i:
				counter += 1
		objectArrays.append(counter)
	print("There is object: ", objectArrays)
	
	var current: int = 0
	for i in range(objectArrays.size()):
		if current < objectArrays[i]:
			current = objectArrays[i]
			
	for i in range(objectArrays.size()):
		if objectArrays[i] == current:
			current = i + 1
	if current == 0:
		current = 0
	print("Final Thought: ", current, " Object")
	SaveData.objectCOUNT.append(current)

#--- CLEARING THE IMG ---
var ClearSecondPASS = clearing2NDpass.new()

func _on_proses_second_pass_pressed() -> void:
	SecondPASSnClearing()

func SecondPASSnClearing():
	SaveData.ClearingIMG.clear()
	var inputIMG: Array = SaveData.FeatureExt
	if inputIMG.is_empty():
		debug_txt.text = "You Need To Cut Image First"
		return
		
	#IF ALREADY CUT
	debug_txt.text = "Successfuly Proccessed into HSV"
	proccessButtonDisabled(true)
	for i in range(inputIMG.size()):
		var height = inputIMG[i].get_height()
		var after_IMG: Image = inputIMG[i]
	
		for y in range(height):
			after_IMG = ClearSecondPASS.scanHorizontal(after_IMG, y)
			get_node("UI - Segment/Segment" + str(i)).texture = ImageTexture.create_from_image(after_IMG)
			await get_tree().process_frame
		SaveData.ClearingIMG.append(after_IMG)
	proccessButtonDisabled(false)


#-- Feature Extraction --
func _on_proses_features_pressed() -> void:
	GiveOutput_FeatureEXT()

func GiveOutput_FeatureEXT():
	SaveData.FeatureExt.clear()
	if output_IMG.is_empty():
		debug_txt.text = "You Need To Cut Image First"
		return
		
	#IF ALREADY CUT
	debug_txt.text = "Successfuly Proccessed into HSV"
	proccessButtonDisabled(true)
	for i in range(output_IMG.size()):
		var height = output_IMG[i].get_height()
		var after_IMG: Image = output_IMG[i]
	
		for y in range(height):
			after_IMG = FeatureEXT.scanHorizontal(after_IMG, y)
			get_node("UI - Segment/Segment" + str(i)).texture = ImageTexture.create_from_image(after_IMG)
			await get_tree().process_frame
		SaveData.FeatureExt.append(after_IMG)
	proccessButtonDisabled(false)
