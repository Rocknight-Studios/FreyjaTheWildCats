extends Button

func _on_JumpToSelectedNodeButton_pressed():
	if get_parent().get_node("ShowNodeInfoButton"):
		if Global.visual_debugger.full_selected_path != "":
			var relative_position = get_node(Global.visual_debugger.full_selected_path).get_global_transform().origin # For speed and convenience.
			Global.visual_debugger.set_moving_to_node(true, relative_position)
		else:
			Global.visual_debugger.warning_line.text = "There is no node selected! Please select a node, to which to jump."
	else:
		Global.visual_debugger.warning_line.text = "The selected info node path is incorrect! Maybe node is removed from node tree."
