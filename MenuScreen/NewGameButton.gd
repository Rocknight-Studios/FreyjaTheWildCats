extends Button

func _on_NewGameButton_pressed():
	Global.emit_signal("start_new_game")
