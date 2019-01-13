extends Button

func _on_StepButton_button_down():
	get_tree().paused = false
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	get_tree().paused = true

