extends Button

func _on_NewGameButton_pressed():
	Global.emit_signal("start_new_game")


func _on_NewGameButton_mouse_entered():
	get_parent().set("custom_colors/font_color", Color(0,0,0,0.3)) 


func _on_NewGameButton_mouse_exited():
	get_parent().set("custom_colors/font_color", Color(0,0,0))
