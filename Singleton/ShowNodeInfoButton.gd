extends Button

onready var full_selected_path = "" # To have a convenient access from other scripts.
onready var selection_info = get_parent().get_node("SelectionInfo") # For speed and convenience
onready var scene_node_selector = get_parent().get_node("SceneNodeSelector") # For speed and convenience
const selection_size = Vector2(10.0, 10.0) # The relative size of the selection.
var old_mouse_position = Vector2(.0, .0) # To detect and measure mouse position changes.

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

func _input(event):
	if Input.is_action_pressed("mouse_left_click"):
		move_on_axis()
	else:
		mouse_is_over_arrow = Mouse_is_over_arrow.NONE
	old_mouse_position = scene_node_selector.relative_mouse_position

func move_on_axis():
	if mouse_is_over_arrow == Mouse_is_over_arrow.X_ARROW:
		node.global_position += old_mouse_position.distance_to(scene_node_selector.relative_mouse_position) * -arrow_direction_vector_x * (1.0 if node.global_position.distance_squared_to(old_mouse_position) < node.global_position.distance_squared_to(scene_node_selector.relative_mouse_position) else -1.0)
	elif mouse_is_over_arrow == Mouse_is_over_arrow.Y_ARROW:
		node.global_position += old_mouse_position.distance_to(scene_node_selector.relative_mouse_position) * arrow_direction_vector_y * (1.0 if node.global_position.distance_squared_to(old_mouse_position) < node.global_position.distance_squared_to(scene_node_selector.relative_mouse_position) else -1.0)

func draw_arrow_head(arrow_direction_vector, center_of_the_node, tip_of_the_arrow, line_color, arrow_length, thickness):
	draw_line(tip_of_the_arrow, tip_of_the_arrow + Vector2(arrow_direction_vector.y, -arrow_direction_vector.x) * arrow_length, line_color, thickness, true)
	draw_line(tip_of_the_arrow, tip_of_the_arrow - Vector2(arrow_direction_vector.y, -arrow_direction_vector.x) * arrow_length, line_color, thickness, true)
	draw_line(tip_of_the_arrow + arrow_direction_vector * arrow_length, tip_of_the_arrow + Vector2(arrow_direction_vector.y, -arrow_direction_vector.x) * arrow_length, line_color, thickness, true)
	draw_line(tip_of_the_arrow + arrow_direction_vector * arrow_length, tip_of_the_arrow - Vector2(arrow_direction_vector.y, -arrow_direction_vector.x) * arrow_length, line_color, thickness, true)

enum Mouse_is_over_arrow {NONE, X_ARROW, Y_ARROW}
onready var mouse_is_over_arrow = Mouse_is_over_arrow.NONE # Act only on one axis.
var node = null # For speed and convenience.
var arrow_direction_vector_y = Vector2(.0, .0) # For speed and convenience.
var arrow_direction_vector_x = Vector2(.0, .0) # For speed and convenience.
const arrow_stem_length = 100.0 # How long are the stems for the direction arrows.

func draw_local_axis_arrows():
	if full_selected_path != "":
		var visual_debugger_camera = get_parent().debugger_camera # For speed and convenience.
		var camera_zoom = visual_debugger_camera.zoom # For speed and convenience.
		if get_parent().get_node(full_selected_path):
			node = get_parent().get_node(full_selected_path)
			var node_global_transform = node.get_global_transform() # For speed and convenience.
			var node_position = node_global_transform.origin # For convenience.
			var debugger_camera_position = visual_debugger_camera.get_global_transform().origin # For convenience.
			var camera_to_object_vector = node_position - debugger_camera_position # For convenience.
			var current_node_position = self.get_global_transform().origin # For convenience.
			var size = selection_size / camera_zoom # For convenience.
			var center_of_the_node = camera_to_object_vector / camera_zoom - current_node_position # For speed and convenience.
			var center_of_the_node_with_scale = center_of_the_node - size * .5 # For speed and convenience.
			var rotation_transform_y = Transform2D(node_global_transform.get_rotation(), Vector2(.0, .0)) # For speed and convenience.
			arrow_direction_vector_y = rotation_transform_y.xform(Vector2(0, 1))
			arrow_direction_vector_x = Vector2(arrow_direction_vector_y.y, -arrow_direction_vector_y.x)
			var x_color = Color(.5, .1, .1, .5) # For speed and convenience.
			var y_color = Color(.1, .1, .5, .5) # For speed and convenience.
			var x_arrow_color = Color(.9, .1, .1, .9) # For speed and convenience.
			var y_arrow_color = Color(.1, .1, .9, .9) # For speed and convenience.
			var x_character_color = Color(.9, .1, .1, .99) # For speed and convenience.
			var y_character_color = Color(.1, .1, .9, .99) # For speed and convenience.
			var character_offset_x = 10 # For convenience.
			var character_offset_y = 10 # For convenience.
			var character_height = 10 # For convenience.
			var character_width = 10 # For convenience.
			var character_thickenss = 2.0 # For convenience.
			var y_arrow_tip_position = center_of_the_node + arrow_direction_vector_y * arrow_stem_length # For speed and convenience.
			var x_arrow_tip_position = center_of_the_node - arrow_direction_vector_x * arrow_stem_length # For speed and convenience.
			var arrow_stem_selection_error = 20.0 # How close must the mouse cursor get to the arrow stem for it to be considered selected.

			if mouse_is_over_arrow == Mouse_is_over_arrow.NONE:
				if scene_node_selector.absolute_mouse_position.x - current_node_position.x > (center_of_the_node.x if center_of_the_node.x < y_arrow_tip_position.x else y_arrow_tip_position.x) - arrow_stem_selection_error:
					if scene_node_selector.absolute_mouse_position.y - current_node_position.y > (center_of_the_node.y if center_of_the_node.y < y_arrow_tip_position.y else y_arrow_tip_position.y) - arrow_stem_selection_error:
						if scene_node_selector.absolute_mouse_position.x - current_node_position.x < (center_of_the_node.x if center_of_the_node.x > y_arrow_tip_position.x else y_arrow_tip_position.x) + arrow_stem_selection_error:
							if scene_node_selector.absolute_mouse_position.y - current_node_position.y < (center_of_the_node.y if center_of_the_node.y > y_arrow_tip_position.y else y_arrow_tip_position.y) + arrow_stem_selection_error:
								mouse_is_over_arrow = Mouse_is_over_arrow.Y_ARROW
			if mouse_is_over_arrow == Mouse_is_over_arrow.NONE:
				if scene_node_selector.absolute_mouse_position.x - current_node_position.x > (center_of_the_node.x if center_of_the_node.x < x_arrow_tip_position.x else x_arrow_tip_position.x) - arrow_stem_selection_error:
					if scene_node_selector.absolute_mouse_position.y - current_node_position.y > (center_of_the_node.y if center_of_the_node.y < x_arrow_tip_position.y else x_arrow_tip_position.y) - arrow_stem_selection_error:
						if scene_node_selector.absolute_mouse_position.x - current_node_position.x < (center_of_the_node.x if center_of_the_node.x > x_arrow_tip_position.x else x_arrow_tip_position.x) + arrow_stem_selection_error:
							if scene_node_selector.absolute_mouse_position.y - current_node_position.y < (center_of_the_node.y if center_of_the_node.y > x_arrow_tip_position.y else x_arrow_tip_position.y) + arrow_stem_selection_error:
								mouse_is_over_arrow = Mouse_is_over_arrow.X_ARROW

			draw_line(center_of_the_node, y_arrow_tip_position, Color (y_color.r, y_color.g, y_color.b, 1.0 if mouse_is_over_arrow == Mouse_is_over_arrow.Y_ARROW else y_color.a), 5.0, true)
			draw_line(Vector2(y_arrow_tip_position.x + character_offset_x, y_arrow_tip_position.y + character_offset_y), Vector2(y_arrow_tip_position.x + character_offset_x + character_width * .5, y_arrow_tip_position.y + character_offset_y + character_width * .5), y_character_color, character_thickenss, true)
			draw_line(Vector2(y_arrow_tip_position.x + character_offset_x + character_width, y_arrow_tip_position.y + character_offset_y), Vector2(y_arrow_tip_position.x + character_offset_x, y_arrow_tip_position.y + character_offset_y + character_width), y_character_color, character_thickenss, true)
			draw_arrow_head(arrow_direction_vector_y, center_of_the_node, y_arrow_tip_position, y_arrow_color, 10.0, 2.0)

			draw_line(center_of_the_node, x_arrow_tip_position, Color (x_color.r, x_color.g, x_color.b, 1.0 if mouse_is_over_arrow == Mouse_is_over_arrow.X_ARROW else x_color.a), 5.0, true)
			draw_line(Vector2(x_arrow_tip_position.x + character_offset_x, x_arrow_tip_position.y + character_offset_y), Vector2(x_arrow_tip_position.x + character_offset_x + character_width, x_arrow_tip_position.y + character_offset_y + character_width), x_character_color, character_thickenss, true)
			draw_line(Vector2(x_arrow_tip_position.x + character_offset_x + character_width, x_arrow_tip_position.y + character_offset_y), Vector2(x_arrow_tip_position.x + character_offset_x, x_arrow_tip_position.y + character_offset_y + character_width), x_character_color, character_thickenss, true)
			draw_arrow_head(arrow_direction_vector_x, center_of_the_node, x_arrow_tip_position, x_arrow_color, -10.0, 2.0)

			draw_rect(Rect2(center_of_the_node_with_scale, size), Color(.1, .9, .1, .9), true)
		else:
			get_parent().get_node("WarningLine").text = "Node not found! Check Godot Debugger!"

func _draw():
	draw_local_axis_arrows()
