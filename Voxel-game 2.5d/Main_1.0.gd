extends Node2D

#TILEMAP
@onready var layer_temp = $Layer_temp
@onready var Layer = []

#TEXTURE
const atlas_id = 1
const grass_tx = Vector2i(0,0)
const stone_tx = Vector2i(3,0)

#BLOCK INFO
const stone_b = 0
const grass_b = 1

#WORLD
var world_blocks = {}
var world_size = 4


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_world()
	create_new_layer()
	update_world()
	#print(world_blocks)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# --- Layer ---
func create_new_layer():
	for layer_index in world_size:
		var new_layer = layer_temp.duplicate()
		
		new_layer.name = "Layer_" + str(layer_index)
		new_layer.tile_set = $Layer_temp.tile_set 
		set_z_index(layer_index)
		
		add_child(new_layer)
		Layer.append(new_layer)
		Layer[layer_index].z_index = layer_index

# --- World Gen ---
func generate_world():
	for x in range(world_size):
		for y in range(world_size):
			for z in range(world_size):
				var pos = Vector3i(x,y,z)
				world_blocks[pos] = "id_" + str(randi_range(1,1)) #change this for block generated
	 

# --- Rendering ---
func update_layer(id: int):
	var stack_direction = Vector2i(-1, -1)
	var total_offset = stack_direction * id
	
	for i in world_blocks:
		var coords_x = i.x
		var coords_y = i.y
		var render_pos = Vector2i(coords_x, coords_y) + total_offset
		
		if world_blocks[i] == "id_0":
			Layer[id].set_cell(render_pos, atlas_id, stone_tx)
		elif world_blocks[i] == "id_1":
			Layer[id].set_cell(render_pos, atlas_id, grass_tx)

func update_world():
	for layer_index in world_size:
		update_layer(layer_index)
	
