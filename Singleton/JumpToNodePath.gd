extends LineEdit

func _on_JumpToNodePath_mouse_exited():
	release_focus()

func _on_JumpToNodePath_mouse_entered():
	grab_focus()
