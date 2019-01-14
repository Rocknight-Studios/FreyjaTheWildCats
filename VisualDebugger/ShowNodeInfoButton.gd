extends Button

onready var selection_info = get_parent().get_parent().get_node("SelectionInfo") # For speed and convenience
onready var current_node_info = get_parent().get_node("CurrentNodeInfo") # For speed and convenience.

func _on_ShowNodeInfoButton_pressed():
	if selection_info.text.length() > 1:
		var selected_node = selection_info.get_line(selection_info.cursor_get_line()) # For convenience.
		Global.visual_debugger.full_selected_path = Global.visual_debugger.scene_node_selector.full_paths[selection_info.cursor_get_line()]
		set_info_text(selected_node)
		Global.visual_debugger.node_is_selected = true
	else:
		Global.visual_debugger.warning_line.text = "List is empty! Use selection circle to select nodes in the scene."

func set_info_text(selected_node):
	current_node_info.text = selected_node
	current_node_info.text += ":\n"
	current_node_info.text += "Full Path: "
	current_node_info.text += Global.visual_debugger.full_selected_path
