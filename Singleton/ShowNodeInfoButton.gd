extends Button

onready var full_selected_path = "" # To have a convenient access from other scripts.
onready var selection_info = get_parent().get_node("SelectionInfo") # For speed and convenience
onready var scene_node_selector = get_parent().get_node("SceneNodeSelector") # For speed and convenience
const selection_size = Vector2(10.0, 10.0) # The relative size of the selection.

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

func _process(delta):
	update()

func draw_arrow_head(arrow_direction_vector, center_of_the_node, tip_of_the_arrow, line_color, arrow_length, thickness):
	draw_line(tip_of_the_arrow, tip_of_the_arrow + Vector2(arrow_direction_vector.y, -arrow_direction_vector.x) * arrow_length, line_color, thickness, true)
	draw_line(tip_of_the_arrow, tip_of_the_arrow - Vector2(arrow_direction_vector.y, -arrow_direction_vector.x) * arrow_length, line_color, thickness, true)
	draw_line(tip_of_the_arrow + arrow_direction_vector * arrow_length, tip_of_the_arrow + Vector2(arrow_direction_vector.y, -arrow_direction_vector.x) * arrow_length, line_color, thickness, true)
	draw_line(tip_of_the_arrow + arrow_direction_vector * arrow_length, tip_of_the_arrow - Vector2(arrow_direction_vector.y, -arrow_direction_vector.x) * arrow_length, line_color, thickness, true)

func _draw():
	if full_selected_path != "":
		var visual_debugger_camera = get_parent().debugger_camera # For speed and convenience.
		var camera_zoom = visual_debugger_camera.zoom # For speed and convenience.
		if get_parent().get_node(full_selected_path):
			var node = get_parent().get_node(full_selected_path) # For speed and convenience.
			var node_global_transform = node.get_global_transform() # For speed and convenience.
			var node_position = node_global_transform.origin # For convenience.
			var debugger_camera_position = visual_debugger_camera.get_global_transform().origin # For convenience.
			var camera_to_object_vector = node_position - debugger_camera_position # For convenience.
			var current_node_position = self.get_global_transform().origin # For convenience.
			var size = selection_size / camera_zoom # For convenience.
			var center_of_the_node = camera_to_object_vector / camera_zoom - current_node_position # For speed and convenience.
			var center_of_the_node_with_scale = center_of_the_node - size * .5 # For speed and convenience.
			var rotation_transform_y = Transform2D(node_global_transform.get_rotation(), Vector2(.0, .0)) # For speed and convenience.
			var arrow_direction_vector_y = rotation_transform_y.xform(Vector2(1, 0)) # For speed and convenience.
			var arrow_direction_vector_x = Vector2(arrow_direction_vector_y.y, -arrow_direction_vector_y.x) # For speed and convenience.
			var arrow_stem_length = 100.0 # How long are the stems for the direction arrows.
			var y_color = Color(.5, .1, .1, .5) # For speed and convenience.
			var x_color = Color(.1, .1, .5, .5) # For speed and convenience.
			var y_arrow_color = Color(.9, .1, .1, .9) # For speed and convenience.
			var x_arrow_color = Color(.1, .1, .9, .9) # For speed and convenience.
			var y_character_color = Color(.9, .1, .1, .99) # For speed and convenience.
			var x_character_color = Color(.1, .1, .9, .99) # For speed and convenience.
			var character_offset_x = 10 # For convenience.
			var character_offset_y = 10 # For convenience.
			var character_height = 10 # For convenience.
			var character_width = 10 # For convenience.
			var character_thickenss = 2.0 # For convenience.

			var y_arrow_tip_position = center_of_the_node + arrow_direction_vector_y * arrow_stem_length # For speed and convenience.
			draw_line(center_of_the_node, y_arrow_tip_position, y_color, 5.0, true)
			draw_line(Vector2(y_arrow_tip_position.x + character_offset_x, y_arrow_tip_position.y + character_offset_y), Vector2(y_arrow_tip_position.x + character_offset_x + character_width, y_arrow_tip_position.y + character_offset_y + character_width), y_character_color, character_thickenss, true)
			draw_line(Vector2(y_arrow_tip_position.x + character_offset_x + character_width, y_arrow_tip_position.y + character_offset_y), Vector2(y_arrow_tip_position.x + character_offset_x, y_arrow_tip_position.y + character_offset_y + character_width), y_character_color, character_thickenss, true)
			draw_arrow_head(arrow_direction_vector_y, center_of_the_node, y_arrow_tip_position, y_arrow_color, 10.0, 2.0)
			var x_arrow_tip_position = center_of_the_node - arrow_direction_vector_x * arrow_stem_length # For speed and convenience.
			draw_line(center_of_the_node, x_arrow_tip_position, x_color, 5.0, true)
			draw_line(Vector2(x_arrow_tip_position.x + character_offset_x, x_arrow_tip_position.y + character_offset_y), Vector2(x_arrow_tip_position.x + character_offset_x + character_width * .5, x_arrow_tip_position.y + character_offset_y + character_width * .5), x_character_color, character_thickenss, true)
			draw_line(Vector2(x_arrow_tip_position.x + character_offset_x + character_width, x_arrow_tip_position.y + character_offset_y), Vector2(x_arrow_tip_position.x + character_offset_x, x_arrow_tip_position.y + character_offset_y + character_width), x_character_color, character_thickenss, true)
			draw_arrow_head(arrow_direction_vector_x, center_of_the_node, x_arrow_tip_position, x_arrow_color, -10.0, 2.0)

			draw_rect(Rect2(center_of_the_node_with_scale, size), Color(.1, .9, .1, .9), true)
		else:
			get_parent().get_node("WarningLine").text = "Node not found! Check Godot Debugger!"
