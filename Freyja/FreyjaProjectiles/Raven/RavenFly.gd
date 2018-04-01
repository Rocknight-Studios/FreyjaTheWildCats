extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func _process(delta):
	var move = $Path2D/PathFollow2D.get_offset() + delta * 100
	$Path2D/PathFollow2D.set_offset(move)
	$Path2D/Spirit.position = $Path2D/PathFollow2D.position
	$Path2D/Spirit.rotation = $Path2D/PathFollow2D.rotation + PI

