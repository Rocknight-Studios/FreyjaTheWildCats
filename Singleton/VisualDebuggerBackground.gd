extends Panel

func _process(delta):
	var mouse_viewport_position = get_viewport().get_mouse_position() # For speed and convenience.
	if mouse_viewport_position.x < get_rect().size.x && mouse_viewport_position.y < get_rect().size.y:
		get_parent().mouse_is_over_visual_debugger_gui = true
	else:
		get_parent().mouse_is_over_visual_debugger_gui = false
