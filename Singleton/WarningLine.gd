extends LineEdit

onready var blink_time = 4000 # For how long to blink.
onready var blink_speed = .006 # How quickly to blink.
onready var blink_the_message = false # To know, when to perform the blinking.
onready var start_time = 0 # To know, when to reset the time.

func _on_WarningLine_text_changed(new_text):
	blink_the_message = true
	start_time = OS.get_ticks_msec()

func reset():
	blink_the_message = false
	start_time = 0

func _process(delta):
	if blink_the_message:
		var current_time_span = OS.get_ticks_msec() - start_time # For speed and convenience.
		self.self_modulate.a = 1.0 - clamp(sin((current_time_span) * blink_speed), 0, 1)
		if current_time_span > blink_time:
			reset()
