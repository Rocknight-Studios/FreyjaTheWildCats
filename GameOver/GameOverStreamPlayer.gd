extends AudioStreamPlayer

onready var game_over_music = preload("res://Unsorted/FreyjaNotImpressed.ogg") # For speed and convenience.
onready var stream_start_time = OS.get_ticks_msec() # To know, when to stop playing the stream.
var stream_length = 0.0 # For speed and convenience.

func _ready():
	self.stream = game_over_music
	stream_length = self.stream.get_length() * Global.to_seconds_multiplier
	self.play()

func _process(delta):
	if (OS.get_ticks_msec() - stream_start_time > stream_length):
		self.stop()
