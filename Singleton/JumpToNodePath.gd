extends LineEdit

func _input(event):
	if Input.is_action_pressed("paste_text"):
		self.text = OS.get_clipboard()
