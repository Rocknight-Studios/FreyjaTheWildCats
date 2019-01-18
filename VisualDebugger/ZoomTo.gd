extends Button

func _on_ZoomTo_pressed():
	Global.visual_debugger.debugger_camera.set_zoom_to()

func _process(delta):
	if Input.is_action_just_pressed("alt_m"):
		_on_ZoomTo_pressed()
