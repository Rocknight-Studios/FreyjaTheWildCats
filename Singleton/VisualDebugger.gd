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
	if abs(abs(self.offset.x) - abs(goal_pos)) > Global.approximation_float:
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

	if direction.length() > Global.approximation_float:
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
	if goal_position.distance_to(debugger_camera.position) < Global.approximation_float:
		is_moving_to_node = false
		debugger_camera.position = goal_position

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
