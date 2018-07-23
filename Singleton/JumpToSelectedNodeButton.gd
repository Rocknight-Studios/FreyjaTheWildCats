extends Button

onready var goal_position = Vector2(.0, .0) # For speed and convenience.

func _on_JumpToSelectedNodeButton_pressed():
	var node_path = "" # For speed and convenience.

	if get_parent().get_node("ShowNodeInfoButton"):
		node_path = get_parent().get_node("ShowNodeInfoButton").full_selected_path
		if node_path != "":
			var relative_position = get_node(node_path).get_global_transform().origin # For speed and convenience.
			Global.visual_debugger.set_moving_to_node(true, relative_position)
		else:
			Global.visual_debugger.warning_line.text = "There is no node selected! Please select a node, to which to jump."
	else:
		Global.visual_debugger.warning_line.text = "The selected info node path is incorrect! Maybe node is removed from node tree."
