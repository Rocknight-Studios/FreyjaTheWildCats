extends Button

func _ready():
	pass
	
func _on_RestartButton_pressed():
	Global.emit_signal("restart")
