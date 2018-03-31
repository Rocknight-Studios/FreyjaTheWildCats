extends AudioStreamPlayer

onready var game_over_music = preload("res://unsorted/freyja-_not_impressed.m4a-ogg-coverted.ogg") # For speed and convenience.
onready var stream_start_time = OS.get_ticks_msec() # To know, when to stop playing the stream.
var stream_length = 0 # For speed and convenience.

func _ready():
	self.stream = game_over_music
	stream_length = self.stream.get_length() * 1000
	self.play()

func _process(delta):
	if (OS.get_ticks_msec() - stream_start_time > stream_length):
		self.stop()
