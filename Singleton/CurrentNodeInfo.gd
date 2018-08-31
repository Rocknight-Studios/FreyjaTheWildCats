extends TextEdit

var copy_key_was_pressed = false # To forbid multiple copy actions.

func _input(event):
	if !copy_key_was_pressed && Input.is_action_pressed("copy_text"):
		copy_key_was_pressed = true
		OS.clipboard = get_selection_text()
	elif Input.is_action_just_released("copy_text"):
		copy_key_was_pressed = false
