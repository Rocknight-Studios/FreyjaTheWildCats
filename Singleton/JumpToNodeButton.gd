extends Button

onready var visual_debugger = get_parent() # For speed and convenience.
onready var goal_position = Vector2(.0, .0) # For speed and convenience.

func set_movement():
	var node_path = get_node("JumpToNodePath").text # For speed and convenience.

	if node_path != "":
		if get_node(node_path):
			var relative_position = get_node(node_path).get_global_transform().origin # For speed and convenience.
			visual_debugger.set_moving_to_node(true, relative_position)
		else:
			get_parent().get_node("WarningLine").text = "The node path is incorrect, please adjust it, to point to existing node."
	else:
		get_parent().get_node("WarningLine").text = "The node path is empty! Please provide a path to a node, to which to jump."

func _on_JumpToNodeButton_pressed():
	set_movement()
