extends Node

const MARKER_PATH := "user://.initialized"
const TARGET_DIR := "user://DatasetJSON/"

func _ready():
	if FileAccess.file_exists(MARKER_PATH):
		return  # already ran once

	run_first_time_setup()
	writeFirstRun()

func run_first_time_setup():
	var dir = DirAccess.open("user://")
	#if savedata folder is not found make new folder
	if dir:
		if not dir.dir_exists("DatasetJSON"):
			dir.make_dir("DatasetJSON")

	# Example: copy from res:// to user://
	copyFILE("res://Assets/DatasetJSON/dataset.json", TARGET_DIR + "dataset.json")


func copyFILE(src: String, dst: String):
	if not FileAccess.file_exists(src):
		return

	var data = FileAccess.get_file_as_bytes(src)
	var file = FileAccess.open(dst, FileAccess.WRITE)
	file.store_buffer(data)
	file.close()


func writeFirstRun():
	var file = FileAccess.open(MARKER_PATH, FileAccess.WRITE)
	file.store_string("done")
	file.close()
