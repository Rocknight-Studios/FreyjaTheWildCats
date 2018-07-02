extends Button

func _on_JumpToNodeButton_pressed():
	var debugger_camera = get_parent().get_node("DebuggerCamera2D") # For speed and convenience.
	var node_path = get_node("JumpToNodePath").text # For speed and convenience.

	if node_path != "":
		if get_node(node_path):
			var relative_position = get_node(node_path).get_global_transform().origin # For speed and convenience.
			debugger_camera.position = relative_position - OS.window_size * .5 * get_parent().debugger_camera.zoom
		else:
			get_parent().get_node("WarningLine").text = "The node path is incorrect, please adjust it, to point to existing node."
	else:
		get_parent().get_node("WarningLine").text = "The node path is empty! Please provide a path to a node, to which to jump."
