extends TextEdit

var focus_was_outside = true # To only select all the first time.

func _on_WatchName_gui_input(ev):
	if Input.is_action_just_pressed("mouse_left_click") && focus_was_outside:
		focus_was_outside = false
		select_all()

func _on_WatchName_focus_exited():
	focus_was_outside = true
