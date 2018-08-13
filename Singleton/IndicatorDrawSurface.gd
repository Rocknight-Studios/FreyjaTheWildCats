extends Node2D

onready var show_node_info = get_parent().get_node("TabContainer/NodeSelection/SelectedNodeInfo/ShowNodeInfoButton") # For speed and convenience.
const selection_size = Vector2(10.0, 10.0) # The relative size of the selection.
var old_mouse_position = Vector2(.0, .0) # To detect and measure mouse position changes.
var mouse_is_over_rotation_circle = false # For speed and convenience.
var absolute_mouse_position = Vector2(.0, .0) # For speed and convenience.
const min_distance_to_rotation_circle_middle = 10.0 # To prevent ugly rotations. For speed and convenience.
onready var min_sqr_distance_to_rotation_circle_middle = min_distance_to_rotation_circle_middle * min_distance_to_rotation_circle_middle # To prevent ugly rotations.
var sqr_distance_to_mouse = .0 # For speed and convenience.
var mouse_was_pressed = false # To know, when to initialize mouse click behavior.
var move_distance_from_center_of_node_to_cursor = .0 # Initialized distance.

func _process(delta):
	update()

func _input(event):
	absolute_mouse_position = Global.visual_debugger.scene_node_selector.absolute_mouse_position
	sqr_distance_to_mouse = absolute_mouse_position.distance_squared_to(center_of_the_node)
	if sqr_distance_to_mouse < circle_size * circle_size:
		mouse_is_over_rotation_circle = true
	else:
		mouse_is_over_rotation_circle = false

	if Input.is_action_pressed("mouse_left_click"):
		if Global.visual_debugger.transformation_mode == Global.visual_debugger.VD_Transformation_modes.MOVE:
			if !mouse_was_pressed:
				move_distance_from_center_of_node_to_cursor = sqr_distance_to_mouse
			move_on_axis()
		elif Global.visual_debugger.transformation_mode == Global.visual_debugger.VD_Transformation_modes.ROTATE:
			rotate_on_axis()

		if mouse_is_over_rotation_circle:
			rotate_on_axis_is_enabled = true

		mouse_was_pressed = true
	else:
		mouse_was_pressed = false
		mouse_is_over_arrow = VD_Mouse_is_over_arrow.NONE
		rotate_on_axis_is_enabled = false
	old_mouse_position = absolute_mouse_position

func move_on_axis():
	if mouse_is_over_arrow == VD_Mouse_is_over_arrow.X_ARROW:
		node.global_position.x += (absolute_mouse_position.x - old_mouse_position.x) * camera_zoom.x
	elif mouse_is_over_arrow == VD_Mouse_is_over_arrow.Y_ARROW:
		node.global_position.y += (absolute_mouse_position.y - old_mouse_position.y) * camera_zoom.y
	elif mouse_is_over_arrow == VD_Mouse_is_over_arrow.MIDDLE:
		node.global_position.x += (absolute_mouse_position.x - old_mouse_position.x) * camera_zoom.x
		node.global_position.y += (absolute_mouse_position.y - old_mouse_position.y) * camera_zoom.y

onready var rotate_on_axis_is_enabled = false # For speed and convenience.
const rotation_coefficient = -.1 # How quickly to rotate node on mouse drag.
const movement_coefficient = 1.0 # How quickly to rotate node on mouse drag.

func rotate_on_axis():
	if rotate_on_axis_is_enabled && sqr_distance_to_mouse > min_sqr_distance_to_rotation_circle_middle:
		var rotation_coefficient_with_distance_coefficient = zoomed_size.x * (rotation_coefficient / clamp(absolute_mouse_position.distance_to(center_of_the_node_with_scale), Global.approximation_float, OS.window_size.x)) # For speed and convenience.
		if absolute_mouse_position.y > center_of_the_node_with_scale.y:
			if absolute_mouse_position.x > old_mouse_position.x:
				node.global_rotation += (absolute_mouse_position.x - old_mouse_position.x) * rotation_coefficient_with_distance_coefficient
			else:
				node.global_rotation -= (old_mouse_position.x - absolute_mouse_position.x) * rotation_coefficient_with_distance_coefficient
		else:
			if absolute_mouse_position.x > old_mouse_position.x:
				node.global_rotation -= (absolute_mouse_position.x - old_mouse_position.x) * rotation_coefficient_with_distance_coefficient
			else:
				node.global_rotation += (old_mouse_position.x - absolute_mouse_position.x) * rotation_coefficient_with_distance_coefficient

		if absolute_mouse_position.x < center_of_the_node_with_scale.x:
			if absolute_mouse_position.y > old_mouse_position.y:
				node.global_rotation += (absolute_mouse_position.y - old_mouse_position.y) * rotation_coefficient_with_distance_coefficient
			else:
				node.global_rotation -= (old_mouse_position.y - absolute_mouse_position.y) * rotation_coefficient_with_distance_coefficient
		else:
			if absolute_mouse_position.y > old_mouse_position.y:
				node.global_rotation -= (absolute_mouse_position.y - old_mouse_position.y) * rotation_coefficient_with_distance_coefficient
			else:
				node.global_rotation += (old_mouse_position.y - absolute_mouse_position.y) * rotation_coefficient_with_distance_coefficient

func draw_arrow_head(arrow_direction_vector, center_of_the_node, tip_of_the_arrow, line_color, arrow_length, thickness):
	draw_line(tip_of_the_arrow, tip_of_the_arrow + Vector2(arrow_direction_vector.y, -arrow_direction_vector.x) * arrow_length, line_color, thickness, true)
	draw_line(tip_of_the_arrow, tip_of_the_arrow - Vector2(arrow_direction_vector.y, -arrow_direction_vector.x) * arrow_length, line_color, thickness, true)
	draw_line(tip_of_the_arrow + arrow_direction_vector * arrow_length, tip_of_the_arrow + Vector2(arrow_direction_vector.y, -arrow_direction_vector.x) * arrow_length, line_color, thickness, true)
	draw_line(tip_of_the_arrow + arrow_direction_vector * arrow_length, tip_of_the_arrow - Vector2(arrow_direction_vector.y, -arrow_direction_vector.x) * arrow_length, line_color, thickness, true)

enum VD_Mouse_is_over_arrow {NONE, X_ARROW, Y_ARROW, MIDDLE}
onready var mouse_is_over_arrow = VD_Mouse_is_over_arrow.NONE # Act only on one axis.
var node = null # For speed and convenience.
var arrow_direction_vector_y = Vector2(.0, .0) # For speed and convenience.
var arrow_direction_vector_x = Vector2(.0, .0) # For speed and convenience.
const arrow_stem_length = 100.0 # How long are the stems for the direction arrows.
var node_global_transform = Vector2(.0, .0) # For a wider scope.
var node_position = Vector2(.0, .0) # For a wider scope.
var debugger_camera_position = Vector2(.0, .0) # For a wider scope.
var camera_to_object_vector = Vector2(.0, .0) # For a wider scope.
var current_node_position = Vector2(.0, .0) # For a wider scope.
var zoomed_size = Vector2(.0, .0) # For a wider scope.
var center_of_the_node = Vector2(.0, .0) # For a wider scope.
var center_of_the_node_with_scale = Vector2(.0, .0) # For a wider scope.
var visual_debugger_camera = null # For speed and convenience.
var camera_zoom = null # For speed and convenience.
var rotation_transform_y = null # For speed and convenience.
var y_arrow_tip_position = Vector2(.0, .0) # For a wider scope.
var x_arrow_tip_position = Vector2(.0, .0) # For a wider scope.

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

func calculate_node_draw_center():
	visual_debugger_camera = Global.visual_debugger.debugger_camera # For speed and convenience.
	camera_zoom = visual_debugger_camera.zoom # For speed and convenience.
	node = show_node_info.get_parent().get_node(show_node_info.full_selected_path)
	if Global.visual_debugger.node_is_selected:
		node_global_transform = node.get_global_transform() # For speed and convenience.
		node_position = node_global_transform.origin # For convenience.
		debugger_camera_position = visual_debugger_camera.get_global_transform().origin # For convenience.
		camera_to_object_vector = node_position - debugger_camera_position # For convenience.
		current_node_position = self.get_global_transform().origin # For convenience.
		zoomed_size = selection_size / camera_zoom # For convenience.
		center_of_the_node = camera_to_object_vector / camera_zoom - current_node_position # For speed and convenience.
		center_of_the_node_with_scale = center_of_the_node - zoomed_size * .5 # For speed and convenience.
		rotation_transform_y = Transform2D(node_global_transform.get_rotation(), Vector2(.0, .0)) # For speed and convenience.
		arrow_direction_vector_y = rotation_transform_y.xform(Vector2(0, 1))
		arrow_direction_vector_x = Vector2(arrow_direction_vector_y.y, -arrow_direction_vector_y.x)
		y_arrow_tip_position = center_of_the_node_with_scale + arrow_direction_vector_y * arrow_stem_length # For speed and convenience.
		x_arrow_tip_position = center_of_the_node_with_scale - arrow_direction_vector_x * arrow_stem_length # For speed and convenience.

func draw_arrows_and_axis_characters():
	draw_line(Vector2(y_arrow_tip_position.x + character_offset_x, y_arrow_tip_position.y + character_offset_y), Vector2(y_arrow_tip_position.x + character_offset_x + character_width * .5, y_arrow_tip_position.y + character_offset_y + character_width * .5), y_character_color, character_thickenss, true)
	draw_line(Vector2(y_arrow_tip_position.x + character_offset_x + character_width, y_arrow_tip_position.y + character_offset_y), Vector2(y_arrow_tip_position.x + character_offset_x, y_arrow_tip_position.y + character_offset_y + character_width), y_character_color, character_thickenss, true)
	draw_arrow_head(arrow_direction_vector_y, center_of_the_node, y_arrow_tip_position, y_arrow_color, 10.0, 2.0)

	draw_line(Vector2(x_arrow_tip_position.x + character_offset_x, x_arrow_tip_position.y + character_offset_y), Vector2(x_arrow_tip_position.x + character_offset_x + character_width, x_arrow_tip_position.y + character_offset_y + character_width), x_character_color, character_thickenss, true)
	draw_line(Vector2(x_arrow_tip_position.x + character_offset_x + character_width, x_arrow_tip_position.y + character_offset_y), Vector2(x_arrow_tip_position.x + character_offset_x, x_arrow_tip_position.y + character_offset_y + character_width), x_character_color, character_thickenss, true)
	draw_arrow_head(arrow_direction_vector_x, center_of_the_node, x_arrow_tip_position, x_arrow_color, -10.0, 2.0)

func draw_local_axis_arrows():
	if show_node_info.full_selected_path != "":
		calculate_node_draw_center()
		if Global.visual_debugger.node_is_selected:
			var arrow_stem_selection_error = 20.0 # How close must the mouse cursor get to the arrow stem for it to be considered selected.

			if absolute_mouse_position.distance_to(current_node_position + center_of_the_node_with_scale) < move_rectangle_size.x:
				mouse_is_over_arrow = VD_Mouse_is_over_arrow.MIDDLE
			if mouse_is_over_arrow == VD_Mouse_is_over_arrow.NONE:
				if absolute_mouse_position.x - current_node_position.x > (center_of_the_node_with_scale.x if center_of_the_node_with_scale.x < y_arrow_tip_position.x else y_arrow_tip_position.x) - arrow_stem_selection_error:
					if absolute_mouse_position.y - current_node_position.y > (center_of_the_node_with_scale.y if center_of_the_node_with_scale.y < y_arrow_tip_position.y else y_arrow_tip_position.y) - arrow_stem_selection_error:
						if absolute_mouse_position.x - current_node_position.x < (center_of_the_node_with_scale.x if center_of_the_node_with_scale.x > y_arrow_tip_position.x else y_arrow_tip_position.x) + arrow_stem_selection_error:
							if absolute_mouse_position.y - current_node_position.y < (center_of_the_node_with_scale.y if center_of_the_node_with_scale.y > y_arrow_tip_position.y else y_arrow_tip_position.y) + arrow_stem_selection_error:
								mouse_is_over_arrow = VD_Mouse_is_over_arrow.Y_ARROW
			if mouse_is_over_arrow == VD_Mouse_is_over_arrow.NONE:
				if absolute_mouse_position.x - current_node_position.x > (center_of_the_node_with_scale.x if center_of_the_node_with_scale.x < x_arrow_tip_position.x else x_arrow_tip_position.x) - arrow_stem_selection_error:
					if absolute_mouse_position.y - current_node_position.y > (center_of_the_node_with_scale.y if center_of_the_node_with_scale.y < x_arrow_tip_position.y else x_arrow_tip_position.y) - arrow_stem_selection_error:
						if absolute_mouse_position.x - current_node_position.x < (center_of_the_node_with_scale.x if center_of_the_node_with_scale.x > x_arrow_tip_position.x else x_arrow_tip_position.x) + arrow_stem_selection_error:
							if absolute_mouse_position.y - current_node_position.y < (center_of_the_node_with_scale.y if center_of_the_node_with_scale.y > x_arrow_tip_position.y else x_arrow_tip_position.y) + arrow_stem_selection_error:
								mouse_is_over_arrow = VD_Mouse_is_over_arrow.X_ARROW

			draw_line(center_of_the_node_with_scale, y_arrow_tip_position, Color (y_color.r, y_color.g, y_color.b, 1.0 if mouse_is_over_arrow == VD_Mouse_is_over_arrow.Y_ARROW else y_color.a), 5.0, true)
			draw_line(center_of_the_node_with_scale, x_arrow_tip_position, Color (x_color.r, x_color.g, x_color.b, 1.0 if mouse_is_over_arrow == VD_Mouse_is_over_arrow.X_ARROW else x_color.a), 5.0, true)
			draw_arrows_and_axis_characters()

			if mouse_is_over_arrow != VD_Mouse_is_over_arrow.MIDDLE:
				draw_rect(Rect2(center_of_the_node_with_scale - move_rectangle_size * .5, move_rectangle_size), Color(.1, .9, .1, .7), true)
			else:
				draw_rect(Rect2(center_of_the_node_with_scale - move_rectangle_size * .5, move_rectangle_size), Color(.1, .9, .1, .9), true)
		else:
			Global.visual_debugger.warning_line.text = "Node not found! Check Godot Debugger!"

onready var move_rectangle_size = Vector2(10.0, 10.0) # To have an convenient handle.

func draw_circle_arc(center, radius, angle_from, angle_to, color, thickness, detail):
	var points_arc = PoolVector2Array()

	for i in range(detail + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / detail - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(detail):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color, thickness)

var circle_size = .0 # For speed and convenience.

func draw_rotation_circle(): # !!!DRAW ALSO ARROW FOR DIRECTION!!!
	calculate_node_draw_center()
	if Global.visual_debugger.node_is_selected:
		circle_size = center_of_the_node_with_scale.distance_to(y_arrow_tip_position)
		draw_circle_arc(center_of_the_node_with_scale, circle_size, .0, 360.0, Color(1.0, .0, .0, .5), 3.0, 32)
		draw_circle_arc(center_of_the_node_with_scale, circle_size - 3.0, .0, 360.0, Color(.0, 1.0, .0, .5), 3.0, 32)

		draw_line(center_of_the_node_with_scale, y_arrow_tip_position, y_color, 5.0, true)
		draw_line(center_of_the_node_with_scale, x_arrow_tip_position, x_color, 5.0, true)
		draw_arrows_and_axis_characters()

		if mouse_is_over_rotation_circle || rotate_on_axis_is_enabled:
			draw_circle(center_of_the_node_with_scale, circle_size - 6.0, Color(.0, .0, 1.0, .35))
		else:
			draw_circle(center_of_the_node_with_scale, circle_size - 6.0, Color(.0, .0, 1.0, .2))

		draw_circle(center_of_the_node_with_scale, min_distance_to_rotation_circle_middle, Color(.0, .0, 1.0, .9))

func draw_scale_handles():
	print("manage scaling")

func _draw():
	if show_node_info != null:
		if Global.visual_debugger.transformation_mode == Global.visual_debugger.VD_Transformation_modes.MOVE:
			draw_local_axis_arrows()
		elif Global.visual_debugger.transformation_mode == Global.visual_debugger.VD_Transformation_modes.ROTATE:
			draw_rotation_circle()
		elif Global.visual_debugger.transformation_mode == Global.visual_debugger.VD_Transformation_modes.SCALE:
			draw_scale_handles()
