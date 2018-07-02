extends Button

func _on_JumpToSelectedNodeButton_pressed():
	var debugger_camera = get_parent().get_node("DebuggerCamera2D") # For speed and convenience.
	var node_path = "" # For speed and convenience.

	if get_parent().get_node("ShowNodeInfoButton"):
		node_path = get_parent().get_node("ShowNodeInfoButton").full_selected_path
		if node_path != "":
			var relative_position = get_node(node_path).get_global_transform().origin # For speed and convenience.
			debugger_camera.position = relative_position - OS.window_size * .5 * get_parent().debugger_camera.zoom
		else:
			get_parent().get_node("WarningLine").text = "There is no node selected! Please select a node, to which to jump."
	else:
		get_parent().get_node("WarningLine").text = "The selected info node path is incorrect! Maybe node is removed from node tree."
