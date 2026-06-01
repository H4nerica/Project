extends Node

class_name sceneChange

func switch_to_ModelData():
	var target_scene = "res://Scene/TrainingData.tscn"
	var tree = Engine.get_main_loop() as SceneTree
	var error = tree.change_scene_to_file(target_scene)
	
	if error != OK:
		push_error("Failed to load scene: " + target_scene)

func switch_to_Main():
	var target_scene = "res://Scene/NewMain.tscn"
	var tree = Engine.get_main_loop() as SceneTree
	var error = tree.change_scene_to_file(target_scene)
	
	if error != OK:
		push_error("Failed to load scene: " + target_scene)
