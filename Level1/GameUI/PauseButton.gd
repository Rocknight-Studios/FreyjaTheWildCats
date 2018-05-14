extends Button

func _on_PauseButton_pressed():
	if get_tree().paused == false:
		get_tree().paused = true
	else:
		get_tree().paused = false
