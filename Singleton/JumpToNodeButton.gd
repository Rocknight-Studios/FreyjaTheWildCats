extends Button

onready var goal_position = Vector2(.0, .0) # For speed and convenience.

func set_movement():
	var node_path = get_parent().get_node("JumpToNodePath").text # For speed and convenience.

	if node_path != "":
		if get_node(node_path):
			var relative_position = get_node(node_path).get_global_transform().origin # For speed and convenience.
			Global.visual_debugger.set_moving_to_node(true, relative_position)
		else:
			Global.visual_debugger.warning_line.text = "The node path is incorrect, please adjust it, to point to existing node."
	else:
		Global.visual_debugger.warning_line.text = "The node path is empty! Please provide a path to a node, to which to jump."

func _on_JumpToNodeButton_pressed():
	set_movement()
