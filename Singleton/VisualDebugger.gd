extends CanvasLayer

var visual_debugger_is_active = false # To switch between enabled and disabled.
onready var debugger_camera = $"DebuggerCamera2D" # For speed and convenience.
onready var camera_movement_speed_slider = $"GeneralControlsContainer/CameraMovementSpeedSlider" # For speed and convenience.
onready var scene_node_selector = $"SceneNodeSelector" # For speed and convenience.
onready var mouse_is_over_visual_debugger_gui = false # To know, when it is allowed to perform scene node detection.
onready var menu_slide_pos_bounds = Vector2(-500.0, 0.0) # Where to slide menu on x.
enum VD_Slide_direction {NONE, IN, OUT}
onready var slide_direction = VD_Slide_direction.NONE # To know, when to slide in and out the menu.
onready var slide_speed = 5.0 # How quickly to slide in and out.
onready var enable_exact_follow = $"GeneralControlsContainer/EnableExactFollow" # For speed and convenience.
onready var visual_debugger_children = [] # To not loose the access to the children.
onready var menu_is_active = false # To avoid reactivating menu.
onready var warning_line = $"InfoContainer/WarningLine" # For speed and convenience.
enum VD_Transformation_modes {MOVE, ROTATE, SCALE}
onready var transformation_mode = VD_Transformation_modes.MOVE # For speed and convenience.
onready var node_is_selected = false # To save resources and know, when some node is selected in the scene.
var keyboard_movement_is_allowed = true # For the access from other behaviours.
var forbid_selection_circle_management = false # To not manage selection circle, when transformation is active.
var full_selected_path = "" # To have a convenient access from other scripts.

func _ready():
	set_gui_visibility(false)
	debugger_camera.anchor_mode = 0
	self.offset.x = menu_slide_pos_bounds.x
	for i in range(1, self.get_child_count()):
		visual_debugger_children.append(self.get_child(i))
	deactivate_menu()

func set_gui_visibility(state):
	if state:
		slide_direction = VD_Slide_direction.IN
	else:
		slide_direction = VD_Slide_direction.OUT

func activate_menu():
	menu_is_active = true
	for i in range(0, visual_debugger_children.size()):
		add_child(visual_debugger_children[i])

func deactivate_menu():
	menu_is_active = false
	for i in range(0, visual_debugger_children.size()):
		remove_child(visual_debugger_children[i])

func slide_menu(goal_pos, delta):
	if abs(abs(self.offset.x) - abs(goal_pos)) > Global.APPROXIMATION_FLOAT:
		self.offset.x = lerp(self.offset.x, goal_pos, delta * slide_speed)
	else:
		slide_direction = VD_Slide_direction.NONE

func manage_camera_movement(speed):
	var direction = Vector2() # The direction of the current movement step.
	if Input.is_action_pressed ("ui_right"):
		direction.x += 1.0
	if Input.is_action_pressed ("ui_left"):
		direction.x -= 1.0
	if Input.is_action_pressed ("ui_up"):
		direction.y -= 1.0
	if Input.is_action_pressed ("ui_down"):
		direction.y += 1.0

	debugger_camera.position += direction * speed

	if direction.length() > Global.APPROXIMATION_FLOAT:
		is_moving_to_node = false

onready var is_moving_to_node = false # To disable moving to node, when it is reached.
onready var camera_move_lerp_speed = 5.0 # How quickly to move the camera.
onready var relative_position = Vector2(.0, .0) # To calculate correct position, where to move to each node.

func set_moving_to_node(state, relative_position):
	is_moving_to_node = state
	self.relative_position = relative_position

func move_to_the_node(delta):
	var movement_speed = delta * camera_move_lerp_speed # To save resources.
	var goal_position = relative_position - OS.window_size * .5 * debugger_camera.zoom # For speed and convenience.
	if enable_exact_follow.pressed:
		debugger_camera.position = goal_position
	else:
		debugger_camera.position = Vector2(lerp(debugger_camera.position.x, goal_position.x, movement_speed), lerp(debugger_camera.position.y, goal_position.y, movement_speed))
	if goal_position.distance_to(debugger_camera.position) < Global.APPROXIMATION_FLOAT:
		is_moving_to_node = false
		debugger_camera.position = goal_position

func _on_disable_keyboard_movement():
	keyboard_movement_is_allowed = false

func _on_enable_keyboard_movement():
	keyboard_movement_is_allowed = true

onready var visual_debugger_background = $"VisualDebuggerBackground" # For speed and convenience.
onready var original_visual_debugger_background_modulate = visual_debugger_background.modulate # To know, where to reset the value.
const VISUAL_BACKGROUND_MODULATE_B_DELTA = .25 # To avoid having magic numbers.
onready var mouse_over_visual_debugger_background_modulate = Color(original_visual_debugger_background_modulate.r + VISUAL_BACKGROUND_MODULATE_B_DELTA, original_visual_debugger_background_modulate.g + VISUAL_BACKGROUND_MODULATE_B_DELTA, original_visual_debugger_background_modulate.b + VISUAL_BACKGROUND_MODULATE_B_DELTA, original_visual_debugger_background_modulate.a + VISUAL_BACKGROUND_MODULATE_B_DELTA) # When mouse is over visual debugger change the background color.
const BACKGROUND_COLOR_LERP_SPEED = 3.0 # How quickly to fade to the new state.
var mouse_over_tint_lerp_progress = .0 # To have a tight control over lerping and save resources.

func _process(delta):
	if Input.is_action_just_pressed ("visual_debugger"):
		if visual_debugger_is_active:
			visual_debugger_is_active = false
			set_gui_visibility(false)
			Global.camera.make_current()
			get_tree().paused = false
			deactivate_menu()
		else:
			if !menu_is_active:
				activate_menu()
			get_tree().paused = true
			visual_debugger_is_active = true
			set_gui_visibility(true)
			debugger_camera.make_current()

	if visual_debugger_is_active:
		if mouse_is_over_visual_debugger_gui:
			if mouse_over_tint_lerp_progress < Global.NORMALIZED_UPPER_BOUND:
				mouse_over_tint_lerp_progress = min(mouse_over_tint_lerp_progress + delta * BACKGROUND_COLOR_LERP_SPEED, 1.0)
				var array_lerp_result = Global.user_params.global_functions.lerp_array([original_visual_debugger_background_modulate.r, original_visual_debugger_background_modulate.g, original_visual_debugger_background_modulate.b, original_visual_debugger_background_modulate.a], [mouse_over_visual_debugger_background_modulate.r, mouse_over_visual_debugger_background_modulate.g, mouse_over_visual_debugger_background_modulate.b, mouse_over_visual_debugger_background_modulate.a], mouse_over_tint_lerp_progress) # For speed and convenience.
				visual_debugger_background.modulate = Color(array_lerp_result[0], array_lerp_result[1], array_lerp_result[2], array_lerp_result[3])
				keyboard_movement_is_allowed = false
				forbid_selection_circle_management = true
		else:
			if mouse_over_tint_lerp_progress > Global.APPROXIMATION_FLOAT:
				mouse_over_tint_lerp_progress = max(mouse_over_tint_lerp_progress - delta * BACKGROUND_COLOR_LERP_SPEED, .0)
				var array_lerp_result = Global.user_params.global_functions.lerp_array([original_visual_debugger_background_modulate.r, original_visual_debugger_background_modulate.g, original_visual_debugger_background_modulate.b, original_visual_debugger_background_modulate.a], [mouse_over_visual_debugger_background_modulate.r, mouse_over_visual_debugger_background_modulate.g, mouse_over_visual_debugger_background_modulate.b, mouse_over_visual_debugger_background_modulate.a], mouse_over_tint_lerp_progress) # For speed and convenience.
				visual_debugger_background.modulate = Color(array_lerp_result[0], array_lerp_result[1], array_lerp_result[2], array_lerp_result[3])
				keyboard_movement_is_allowed = true
				forbid_selection_circle_management = false

		if keyboard_movement_is_allowed:
			manage_camera_movement(camera_movement_speed_slider.value)

		if is_moving_to_node:
			move_to_the_node(delta)

	if slide_direction == VD_Slide_direction.IN:
		slide_menu(menu_slide_pos_bounds.y, delta)
	elif slide_direction == VD_Slide_direction.OUT:
		slide_menu(menu_slide_pos_bounds.x, delta)

func _on_JumpPositionButton_button_down():
	debugger_camera.position.x = $"GeneralControlsContainer/CameraJumpPositionX".text.to_int()
	debugger_camera.position.y = $"GeneralControlsContainer/CameraJumpPositionY".text.to_int()
