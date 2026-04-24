extends Node
#It delays initialization until nodes are ready, usually for things like:
@onready var template = $ScrollContainer/VBoxContainer/Template
@onready var box = $ScrollContainer/VBoxContainer

@onready var debug_txt = $Debug/Label

#put var here, if this is inside func it will reset each call. So put it global to remember
var id = 10
var is_clicked

var screen_size
var scroll_height
var scroll_height_changed
var keyboard_height

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = DisplayServer.window_get_size()

	await get_tree().process_frame
	scroll_height = $ScrollContainer.size.y
	load_notes()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
var already_run = true
func _process(delta: float) -> void:
	debug_txt.text = str("KH: ", keyboard_height, " F: ", screen_size, " SCH: ", scroll_height_changed)
	keyboard_height = DisplayServer.virtual_keyboard_get_height()
	
	if already_run: #see if it false or true, if false continue. if true stop.
		return
	already_run = false #set to true so it only run once
	
	#keyboard_height = int($Debug/TextEdit.text) #set keyboard size
	scroll_height_changed = scroll_height - keyboard_height
	$ScrollContainer.size.y = scroll_height_changed
	
	if keyboard_height == 0 or keyboard_height == null:
		already_run = true #since keyboard is off change it back
	
	print(already_run)
	
	
func create_template():
	id += 1 #+1 each time this func is called
	var copy = template.duplicate() #duplicate template
	
	box.add_child(copy)
	copy.visible = true
	copy.name = "block_" + str(id)
	copy.placeholder_text = copy.name
	
	#call _on_focus func then bind the object 
	copy.focus_entered.connect(_on_focus.bind(copy)) 
	return copy #return copy to be used on load_notes

func _on_focus(copy):
	is_clicked = copy #set is_clicked to this selected node
	print(is_clicked, "is being clicked")
	already_run = false #make the delta run

func _on_button_pressed() -> void:
	create_template()

func _on_delete_button_pressed() -> void:
	if is_clicked == null:
		return	#return here means like stop the func, so it does cause error
	is_clicked.queue_free() #this delete this node AFTER it finished being used

func _on_save_button_pressed() -> void:
	save_notes()
	
func save_notes():
	var alltext = []
	for child in box.get_children(): #the "box" is in global var
		if child == template:
			continue #if the child is template, skip it when saving
			
		alltext.append(child.text) #take all the child of this box make it to an array
	print(alltext)
	
	var file = FileAccess.open("user://notes.json", FileAccess.WRITE)
	var json_string = JSON.stringify(alltext) #take alltext then change it to json string
	file.store_string(json_string)
	file.close()
	
func load_notes():
	var file = FileAccess.open("user://notes.json", FileAccess.READ)
	var json_notes = file.get_as_text() #take as text
	file.close()
	
	var alltext = JSON.parse_string(json_notes) #convert to array
	print("Reading notes...", alltext)
	
	for text in alltext: #for each array inside alltext make new block then change the text
		var new_block = create_template()
		new_block.text = text
