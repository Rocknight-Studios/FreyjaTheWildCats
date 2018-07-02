extends Button

onready var full_selected_path = "" # To have a convenient access from other scripts.
onready var selection_info = get_parent().get_node("SelectionInfo") # For speed and convenience
onready var scene_node_selector = get_parent().get_node("SceneNodeSelector") # For speed and convenience

func _on_ShowNodeInfoButton_pressed():
	if selection_info.text.length() > 1:
		var selected_node = selection_info.get_line(selection_info.cursor_get_line()) # For convenience.
		var current_node_info = get_parent().get_node("CurrentNodeInfo") # For speed and convenience.
		current_node_info.text = selected_node
		current_node_info.text += ":\n"
		current_node_info.text += "Full Path: "
		full_selected_path = scene_node_selector.full_paths[selection_info.cursor_get_line()]
		current_node_info.text += full_selected_path
	else:
		get_parent().get_node("WarningLine").text = "List is empty! Use selection circle to select nodes in the scene."
