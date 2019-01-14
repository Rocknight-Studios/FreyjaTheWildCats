extends Button

func _on_RestartButton_pressed():
	Global.emit_signal("restart")
