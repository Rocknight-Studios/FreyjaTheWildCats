extends CanvasLayer

var visual_debugger_is_active = false # To switch between enabled and disabled.

func _ready():
	set_gui_visibility(false)

func set_gui_visibility(state):
	$"ActivityLabel".visible = state
	$"StepButton".visible = state

func _process(delta):
	if Input.is_action_just_pressed ("visual_debugger"):
		if visual_debugger_is_active:
			visual_debugger_is_active = false
			set_gui_visibility(false)
		else:
			visual_debugger_is_active = true
			set_gui_visibility(true)

	# if visual_debugger_is_active:
	#	print("Debugger is active")
	# else:
	#	print("Debugger is not active")
