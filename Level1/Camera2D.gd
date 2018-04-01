extends Camera2D

export var start_scroll_position_y = 0 # To be able to jump to some place in the scroll.
export var stop_and_clamp_position_y = -1000 # Where to stop and clamp the level movement.
export var scroll_speed = 100 # How quickly to move the background.
onready var ui_z_index = $"UIZIndex" # For speed and convenience.

func _ready():
	Global.camera = self
	self.position.y = start_scroll_position_y

func _process(delta):
	var speed = delta * -scroll_speed
	scroll_the_camera(speed)

func set_position_of_the_background(jump_position):
	self.position.y = jump_position

func scroll_the_camera(speed):
	if self.position.y > stop_and_clamp_position_y:
		position += Vector2(0, speed)
	else:
		self.position.y = stop_and_clamp_position_y
		Global.emit_signal("level_complete_fade")
	ui_z_index.position = Vector2(0, -speed)

