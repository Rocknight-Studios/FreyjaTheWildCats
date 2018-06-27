extends Button

func _on_JumpToNodeButton_pressed():
	var debugger_camera = get_parent().get_node("DebuggerCamera2D") # For speed and convenience.
	var relative_position = get_node(get_node("JumpToNodePath").text).get_global_transform().origin # For speed and convenience.
	debugger_camera.position = relative_position - OS.window_size * .5 * get_parent().debugger_camera.zoom
