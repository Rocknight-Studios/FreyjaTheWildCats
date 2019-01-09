extends Camera2D

var previous_mouse_drag_position = Vector2(.0, .0) # To calculate, where to move.

const ZOOM_COEFFICIENT = .01 # How relatively quickly to zoom in and out.
const ZOOM_SHIFT_COEFFICIENT = .1 # If shift key is pressed zooming should happen much faster.
const MOUSE_ZOOM_GODOT_ZOOMOUT_DIRECTION_FIX = 10.0 # To keep the zoom centered.
const MIN_ZOOM_THRESHOLD = .02 # How close it is allowed to zoom in.
const ZOOM_BOUNDS = Vector2(.00001, 1500.0) # Don't let the zoom to become larger or smaller than the bounds.

func _input(event):
	if Input.is_action_pressed("left_control_down"):
		manage_scene_zoom(event)
	if Input.is_action_pressed("middle_mouse_button"):
		manage_mouse_drag()
	else:
		previous_mouse_drag_position = get_viewport().get_mouse_position()

func manage_mouse_zoom_state(direction):
	var zoom_step = (ZOOM_SHIFT_COEFFICIENT if Input.is_action_pressed("shift_down") else ZOOM_COEFFICIENT) * direction # For speed and convenience.
	var previous_zoom = zoom # To calculate the relative zoom change.
	zoom = Vector2(clamp(zoom.x + zoom_step * zoom.x, ZOOM_BOUNDS.x, ZOOM_BOUNDS.y), clamp(zoom.y + zoom_step * zoom.y, ZOOM_BOUNDS.x, ZOOM_BOUNDS.y))
	var half_viewport_size = get_viewport().size * .5 # For speed and convenience.
	half_viewport_size = half_viewport_size + get_viewport().get_mouse_position() - half_viewport_size
	position += Vector2(half_viewport_size.x * (previous_zoom.x - zoom.x), half_viewport_size.y * (previous_zoom.y - zoom.y))

func manage_mouse_drag():
	var current_mouse_drag_position = get_viewport().get_mouse_position() # For speed and convenience.
	var distance_to_previous_mouse_position = current_mouse_drag_position.distance_to(previous_mouse_drag_position) # For speed and convenience.
	if distance_to_previous_mouse_position > Global.APPROXIMATION_FLOAT:
		Global.visual_debugger.is_moving_to_node = false
		position.x += (previous_mouse_drag_position.x - current_mouse_drag_position.x) * zoom.x
		position.y += (previous_mouse_drag_position.y - current_mouse_drag_position.y) * zoom.y
	previous_mouse_drag_position = get_viewport().get_mouse_position()

func manage_scene_zoom(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			manage_mouse_zoom_state(-1.0)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			manage_mouse_zoom_state(1.0)
	elif Input.is_action_pressed("control_0"):
		zoom = Vector2(1.0, 1.0)
		position = Vector2(.0, .0)
