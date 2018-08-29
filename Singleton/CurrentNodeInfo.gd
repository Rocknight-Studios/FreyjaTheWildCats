extends TextEdit

func _input(event):
	if Input.is_action_pressed("copy_text"):
		OS.set_clipboard(get_selection_text())
