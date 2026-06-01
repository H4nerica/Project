extends Control

#FILE DIALOG
@export_group("UI - FileDialog")
@export var file_dialog: FileDialog
@export var picBoxAsli: TextureRect

#AVERAGE
@export_group("UI - Average")
@export var Avg_txt: LineEdit
@export var colorBox: ColorRect

#COLOR TARGET STUFF
@export_group("UI - TargetColor")
@export var Target_r: LineEdit
@export var Target_g: LineEdit
@export var Target_b: LineEdit
@export var Target_a: LineEdit
@export var colorBox2: ColorRect
@export var msg_status: Label

#PIXEL STUFF
@export_group("UI - Pixel Stuff")
@export var MinPixel_Txt: LineEdit

#IMAGE STUFF
var loaded_IMG : Image

#COLOR
var coloring: Color

#CLASS
var avg_IMG = AvgColor.new()
var scene_Helper = sceneChange.new()

#FILE
var current_mode = "img"
var defaultPath = "user://dataset_helmet.json"

func _ready() -> void:
	msg_status.text = ""
	file_dialog.file_selected.connect(_on_file_selected)
	update_to_currentColor(SaveData.targetColor)
	update_minpixel_txt()



#--- File Dialog--
func _on_file_selected(path):
	if current_mode == "img":
		proses_IMG(path)

	elif current_mode == "json":
		proses_FILE(path)

#--- Image ---
func fileChoose_IMG():
	current_mode = "img"
	file_dialog.current_dir = OS.get_environment("USERPROFILE") + "/Pictures"
	file_dialog.filters = PackedStringArray([
		"*.png ; PNG Images",
		"*.jpg ; JPG Images",
		"*.jpeg ; JPEG Images"
	])
	file_dialog.popup_centered()
	
func proses_IMG(path):
	var img = Image.new()
	var err = img.load(path)

	if err != OK:
		print("failed")
		return
	
	print("file selected")
	
	change_texture_original(img)
	loaded_IMG = img

#--- File ---
func fileChoose_FILE():
	current_mode = "json"
	file_dialog.current_dir = ProjectSettings.globalize_path("user://DatasetJSON/")
	file_dialog.filters = PackedStringArray([
		"*.json ; JSON Files",
	])
	file_dialog.popup_centered()
	
func proses_FILE(path):
	avg_IMG.loadAverageColor(path)
	SaveData.DefaultPath = path


#--- Helper ---
func change_texture_original(img):
	var texture = ImageTexture.create_from_image(img)
	picBoxAsli.texture = texture

func get_text_as_color():
	var r: float = 0
	var g: float = 0
	var b: float = 0
	var a: float = 255
	
	#Check if it numeric or not
	if Target_r.text.is_valid_float():
		r = float(Target_r.text)
	if Target_g.text.is_valid_float():
		g = float(Target_g.text)
	if Target_b.text.is_valid_float():
		b = float(Target_b.text)
	if Target_a.text.is_valid_float():
		a = float(Target_a.text)
	
	var color: Vector4 = Vector4(r,g,b,a)
	msg_status.text = "Target Color Changed"
	return color

func change_target_color(targetColorHere: Vector4):
	var colorMine = Color(
	targetColorHere.x / 255.0,
	targetColorHere.y / 255.0,
	targetColorHere.z / 255.0,
	targetColorHere.w / 255.0
	)
	colorBox2.color = colorMine
	SaveData.targetColor = targetColorHere

func update_to_currentColor(colorCurrent: Vector4):
	#CHange colorBox to current target
	change_target_color(colorCurrent)
	#Change textbox's text to current color
	Target_r.text = str(colorCurrent.x)
	Target_g.text = str(colorCurrent.y)
	Target_b.text = str(colorCurrent.z)
	Target_a.text = str(colorCurrent.w)

func get_text_as_minpixel():
	if not MinPixel_Txt.text.is_valid_float():
		SaveData.minPixel = float(SaveData.Default_MinPixel) #Reset it
		print("wrong")
	else:
		if float(MinPixel_Txt.text) > 1:
			SaveData.minPixel = 1
		else:
			SaveData.minPixel = float(MinPixel_Txt.text) #save it
		print("run")

func update_minpixel_txt():
	MinPixel_Txt.text = str(SaveData.minPixel)

#--- Input ---
func _on_asli_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Img Is Clicked")
		fileChoose_IMG()

func _on_choose_file_pressed() -> void:
	fileChoose_FILE()

#-- Average --
func _on_proses_avg_color_pressed() -> void:
	avg_IMG.getColorAvg(loaded_IMG, Avg_txt, colorBox)

#-- Save and Load --
func _on_save_pressed() -> void:
	avg_IMG.saveAverageColor()

func _on_load_pressed() -> void:
	avg_IMG.loadAverageColor(SaveData.DefaultPath)

#-- Minimum pixel --
func _on_back_pressed() -> void:
	scene_Helper.switch_to_Main()

#-- Color target --
func _on_choose_target_c_pressed() -> void:
	change_target_color(get_text_as_color())

func _on_reset_pressed() -> void:
	update_to_currentColor(SaveData.Defaulttargetcolor)
	msg_status.text = "Reset Target Color"

#-- Minimum pixel --
func _on_choose_min_pressed() -> void:
	get_text_as_minpixel()
	msg_status.text = "Minimum Pixel Changed"

func _on_reset_min_pressed() -> void:
	SaveData.minPixel = SaveData.Default_MinPixel
	MinPixel_Txt.text = str(SaveData.Default_MinPixel)
	msg_status.text = "Reset Minimum Pixel"
