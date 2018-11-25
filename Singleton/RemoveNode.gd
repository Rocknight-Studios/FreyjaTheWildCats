extends Button

func _on_RemoveNode_pressed():
	Global.visual_debugger.node_is_selected = false
	get_node(Global.visual_debugger.full_selected_path).queue_free();
