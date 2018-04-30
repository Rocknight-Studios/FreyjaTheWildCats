extends Node2D

func _ready():
	pass

func _process(delta):
	var move = $Path2D/PathFollow2D.get_offset() + delta * 100.0
	$Path2D/PathFollow2D.set_offset(move)
	$Path2D/Spirit.position = $Path2D/PathFollow2D.position
	$Path2D/Spirit.rotation = $Path2D/PathFollow2D.rotation + PI

