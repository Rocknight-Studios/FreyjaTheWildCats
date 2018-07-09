extends Button

onready var visual_debugger = get_parent() # For speed and convenience.
onready var goal_position = Vector2(.0, .0) # For speed and convenience.

func _on_JumpToSelectedNodeButton_pressed():
	var node_path = "" # For speed and convenience.

	if get_parent().get_node("ShowNodeInfoButton"):
		node_path = get_parent().get_node("ShowNodeInfoButton").full_selected_path
		if node_path != "":
			var relative_position = get_node(node_path).get_global_transform().origin # For speed and convenience.
			visual_debugger.set_moving_to_node(true, relative_position)
		else:
			get_parent().get_node("WarningLine").text = "There is no node selected! Please select a node, to which to jump."
	else:
		get_parent().get_node("WarningLine").text = "The selected info node path is incorrect! Maybe node is removed from node tree."
