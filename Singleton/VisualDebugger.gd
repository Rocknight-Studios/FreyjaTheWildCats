extends CanvasLayer

var visual_debugger_is_active = false # To switch between enabled and disabled.
onready var debugger_camera = $"DebuggerCamera2D" # For speed and convenience.
onready var camera_movement_speed_slider = $"CameraMovementSpeedSlider" # For speed and convenience.
onready var scene_node_selector = $"SceneNodeSelector" # For speed and convenience.
onready var mouse_is_over_visual_debugger_gui = false # To know, when it is allowed to perform scene node detection.
onready var menu_slide_pos_bounds = Vector2(-500.0, 0.0) # Where to slide menu on x.
enum Slide_direction {NONE, IN, OUT}
onready var slide_direction = Slide_direction.NONE # To know, when to slide in and out the menu.
onready var slide_speed = 5.0 # How quickly to slide in and out.

func _ready():
	set_gui_visibility(false)
	debugger_camera.anchor_mode = 0
	self.offset.x = menu_slide_pos_bounds.x

func set_gui_visibility(state):
	if state:
		slide_direction = Slide_direction.IN
	else:
		slide_direction = Slide_direction.OUT

func slide_menu(goal_pos, delta):
	if abs(abs(self.offset.x) - abs(goal_pos)) > Global.approximation_float:
		self.offset.x = lerp(self.offset.x, goal_pos, delta * slide_speed)
	else:
		slide_direction = Slide_direction.NONE

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

func _process(delta):
	if Input.is_action_just_pressed ("visual_debugger"):
		if visual_debugger_is_active:
			visual_debugger_is_active = false
			set_gui_visibility(false)
			Global.camera.make_current()
			get_tree().paused = false
		else:
			get_tree().paused = true
			visual_debugger_is_active = true
			set_gui_visibility(true)
			debugger_camera.make_current()

	if visual_debugger_is_active:
		manage_camera_movement(camera_movement_speed_slider.value)

	if slide_direction == Slide_direction.IN:
		slide_menu(menu_slide_pos_bounds.y, delta)
	elif slide_direction == Slide_direction.OUT:
		slide_menu(menu_slide_pos_bounds.x, delta)

func _on_JumpPositionButton_button_down():
	debugger_camera.position.x = $"CameraJumpPositionX".text.to_int()
	debugger_camera.position.y = $"CameraJumpPositionY".text.to_int()
