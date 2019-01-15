extends Camera2D

onready var is_zoom_lerping = false # Whether the zooming to the new zoom state should be performed.
onready var is_camera_being_centered_around_mouse_cursor = false # To perform centering, only, when it is required.

var previous_mouse_drag_position = Vector2(.0, .0) # To calculate, where to move.
var camera_tab = null # For speed and convenience.
var new_zoom_value = Vector2(.0, .0) # For speed and convenience. Lerp to this zoom.
var new_zoom_position = Vector2(.0, .0) # For speed and convenience. Lerp to this zoom.
var zoom_lerp_progress = .0 # To ensure tight lerping and speed.
var lerp_to_center_progress = .0 # To have a tight control over lerping.
var current_mouse_center_position = Vector2(.0, .0) # Where to lerp, when screen has to be centered around the mouse.

const LERP_TO_CENTER_SPEED = 2.0 # How quickly to lerp center around mouse cursor.
const ZOOM_COEFFICIENT = .01 # How relatively quickly to zoom in and out.
const ZOOM_SHIFT_COEFFICIENT = .1 # If shift key is pressed zooming should happen much faster.
const MOUSE_ZOOM_GODOT_ZOOMOUT_DIRECTION_FIX = 10.0 # To keep the zoom centered.
const MIN_ZOOM_THRESHOLD = .02 # How close it is allowed to zoom in.
const ZOOM_BOUNDS = Vector2(.00001, 1500.0) # Don't let the zoom to become larger or smaller than the bounds.
const ZOOM_LERP_SPEED = 2.0 # To avoid magic numbers. How is the zoom lerping.

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

func _process(delta):
	if is_zoom_lerping:
		lerp_zoom(delta)
	elif is_camera_being_centered_around_mouse_cursor:
		lerp_to_center_around_mouse_cursor(delta)
	elif Input.is_action_just_pressed("control_m"):
		set_to_center_around_mouse_cursor()

func set_to_center_around_mouse_cursor():
	lerp_to_center_progress = .0
	var half_viewport_size = get_viewport().size * .5 # For speed and convenience.
	current_mouse_center_position = position + (get_viewport().get_mouse_position() - half_viewport_size) * zoom
	Input.warp_mouse_position(half_viewport_size)
	is_camera_being_centered_around_mouse_cursor = true

func lerp_to_center_around_mouse_cursor(delta):
	lerp_to_center_progress = min(lerp_to_center_progress + delta * LERP_TO_CENTER_SPEED, 1.0)
	position = Vector2(lerp(position.x, current_mouse_center_position.x, lerp_to_center_progress), lerp(position.y, current_mouse_center_position.y, lerp_to_center_progress))
	if lerp_to_center_progress > 1.0 - Global.APPROXIMATION_FLOAT:
		is_camera_being_centered_around_mouse_cursor = false

func lerp_zoom(delta):
	zoom_lerp_progress += delta * ZOOM_LERP_SPEED
	zoom = Vector2(lerp(zoom.x, new_zoom_value.x, zoom_lerp_progress), lerp(zoom.y, new_zoom_value.y, zoom_lerp_progress))
	position = Vector2(lerp(position.x, new_zoom_position.x, zoom_lerp_progress), lerp(position.y, new_zoom_position.y, zoom_lerp_progress))
	if zoom_lerp_progress > 1.0:
		is_zoom_lerping = false

func set_zoom_to():
	var zoom_to = camera_tab.get_node("ZoomTo") # For speed and convenience.
	var zoom_value = zoom_to.get_child(0) # For speed and convenience.
	var zoom_position = zoom_to.get_child(1) # For speed and convenience.
	is_zoom_lerping = true
	zoom_lerp_progress = .0
	new_zoom_value = Vector2(Vector2(clamp(float(zoom_value.get_child(0).text), ZOOM_BOUNDS.x, ZOOM_BOUNDS.y), clamp(float(zoom_value.get_child(1).text), ZOOM_BOUNDS.x, ZOOM_BOUNDS.y)))
	new_zoom_position = Vector2(Vector2(float(zoom_position.get_child(0).text), float(zoom_position.get_child(1).text)))
