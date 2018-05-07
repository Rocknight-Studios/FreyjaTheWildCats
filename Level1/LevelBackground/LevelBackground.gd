extends Node2D

export var block_optimization_distance = 2000.0 # Deactivate enemies at this distance.
var blocks = [] # All the enemies of this block.
onready var management_start_time = OS.get_ticks_msec() # To save resources.
var management_pause = 3.0 # How often to check for the new block activity state.
var block_positions = [] # To save resources and have an access to block positions that are removed from the scene tree.

func _ready():
	var child_amount = get_child_count() # For speed and convenience.
	for i in range(0, child_amount):
		blocks.append(get_child(i))
		block_positions.append(blocks[i].get_global_transform().origin)

	yield(get_tree(), "idle_frame")
	for i in range(0, child_amount):
		remove_child(blocks[i])
	manage_block_activity()

func _process(delta):
	if OS.get_ticks_msec() - management_start_time > management_pause:
		management_start_time = OS.get_ticks_msec()
		manage_block_activity()

func manage_block_activity():
	for i in range(0, blocks.size()):
		if Global.player.get_global_transform().origin.distance_to(block_positions[i]) > block_optimization_distance:
			if blocks[i].get_parent() != null:
				remove_child(blocks[i])
		elif blocks[i].get_parent() == null:
			add_child(blocks[i])

