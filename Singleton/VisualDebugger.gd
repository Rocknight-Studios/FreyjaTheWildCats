extends CanvasLayer

var visual_debugger_is_active = false # To switch between enabled and disabled.
onready var debugger_camera = $"Camera2D" # For speed and convenience.
onready var camera_movement_speed_slider = $"CameraMovementSpeedSlider" # For speed and convenience.

func _ready():
	set_gui_visibility(false)
	debugger_camera.anchor_mode = 0

func set_gui_visibility(state):
	$"ActivityLabel".visible = state
	$"StepButton".visible = state
	$"RunButton".visible = state
	camera_movement_speed_slider.visible = state
	$"CameraMovementSpeedLabel".visible = state
	$"CameraJumpPositionX".visible = state
	$"CameraJumpPositionY".visible = state
	$"CameraJumpPositionButton".visible = state

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

func _on_JumpPositionButton_button_down():
	debugger_camera.position.x = $"CameraJumpPositionX".text.to_int()
	debugger_camera.position.y = $"CameraJumpPositionY".text.to_int()
