extends Camera2D

var zoom_scale = 1.0 # What is the current scale of the scene.
var hit_the_zoom_bound = false # To know, when to act accordingly, when zoom has hit threshold.
var previous_mouse_drag_position = Vector2(.0, .0) # To calculate, where to move.

const MIN_CLAMP_BOUND_LIMIT = -5.0 # To avoid using magic numbers.
const MAX_CLAMP_BOUND_LIMIT = 5.0 # To avoid using magic numbers.
const ZOOM_COEFFICIENT = .01 # How relatively quickly to zoom in and out.
const ZOOM_LIMITS = Vector2(.1, 10.0) # Zoom cannot become larger or smaller than this.
const MOUSE_ZOOM_GODOT_ZOOMOUT_DIRECTION_FIX = 10.0 # To keep the zoom centered.
const MOUSE_ZOOM_DIRECTION_HITBACK = 3.0 # To center the mouse zoom.

func _input(event):
	if Input.is_action_pressed("left_control_down"):
		manage_scene_zoom(event)
	if Input.is_action_pressed("middle_mouse_button"):
		manage_mouse_drag()
	else:
		previous_mouse_drag_position = get_viewport().get_mouse_position()

func manage_mouse_zoom_state(direction):
	var previous_zoom_scale = zoom_scale # To know where to reset the zoom_scale.
	hit_the_zoom_bound = false
	zoom_scale += (zoom_scale * ZOOM_COEFFICIENT) * direction
	if zoom_scale < ZOOM_LIMITS.x || zoom_scale > ZOOM_LIMITS.y:
		hit_the_zoom_bound = true
		zoom_scale = previous_zoom_scale
	else:
		var current_mouse_position = get_viewport().get_mouse_position() # For speed and convenience.
		var direction_step = OS.window_size * .5 - current_mouse_position # To know, where to move the view.
		var clamp_bound = Vector2(MIN_CLAMP_BOUND_LIMIT * zoom_scale, MAX_CLAMP_BOUND_LIMIT * zoom_scale) # For speed and convenience. To make zoom sensitivity dependant on the zoom level.
		direction_step = Vector2(clamp(direction_step.x, clamp_bound.x, clamp_bound.y), clamp(direction_step.y, clamp_bound.x, clamp_bound.y))
		if direction < .0:
			position -= Vector2(direction_step.x * MOUSE_ZOOM_DIRECTION_HITBACK if direction_step.x < .0 else direction_step.x, direction_step.y * MOUSE_ZOOM_DIRECTION_HITBACK if direction_step.y < .0 else direction_step.y)
		elif direction > .0:
			position -= Vector2(zoom_scale * MOUSE_ZOOM_GODOT_ZOOMOUT_DIRECTION_FIX, zoom_scale * MOUSE_ZOOM_GODOT_ZOOMOUT_DIRECTION_FIX)
		zoom = Vector2(zoom_scale, zoom_scale)

func manage_mouse_drag():
	var current_mouse_drag_position = get_viewport().get_mouse_position() # For speed and convenience.
	var distance_to_previous_mouse_position = current_mouse_drag_position.distance_to(previous_mouse_drag_position) # For speed and convenience.
	if distance_to_previous_mouse_position > Global.APPROXIMATION_FLOAT:
		Global.visual_debugger.is_moving_to_node = false
		position.x += previous_mouse_drag_position.x - current_mouse_drag_position.x
		position.y += previous_mouse_drag_position.y - current_mouse_drag_position.y
	previous_mouse_drag_position = get_viewport().get_mouse_position()

func manage_scene_zoom(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			manage_mouse_zoom_state(-1.0)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			manage_mouse_zoom_state(1.0)
	elif Input.is_action_pressed("control_0"):
		zoom_scale = 1.0
		zoom = Vector2(zoom_scale, zoom_scale)
		position = Vector2(.0, .0)
