extends Node2D

export var movement_speed = 400.0
export var spirit_node_names = []
var spirit_items = []
onready var spirit_path = $Path2D/PathFollow2D

func _ready():
	for i in range(0, spirit_node_names.size()):
		spirit_items.append(get_node(spirit_node_names[i]))

func _process(delta):
	var move = spirit_path.get_offset() + delta * movement_speed
	for i in range(0, spirit_items.size()):
		spirit_path.set_offset(move + spirit_items[i].movement_offset)
		spirit_items[i].position = spirit_path.position
		spirit_items[i].rotation = spirit_path.rotation + PI
		spirit_path.set_offset(move)







