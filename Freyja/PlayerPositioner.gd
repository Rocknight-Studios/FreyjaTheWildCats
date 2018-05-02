extends KinematicBody2D

func manage_player_movement(speed):
	var direction = Vector2() # The direction of the current movement step.
	if Input.is_action_pressed ("ui_right"):
		direction.x += 1.0
	if Input.is_action_pressed ("ui_left"):
		direction.x -= 1.0
	if Input.is_action_pressed ("ui_up"):
		direction.y -= 1.0
	if Input.is_action_pressed ("ui_down"):
		direction.y += 1.0

	direction = direction.normalized() * speed

	position += direction
	move_and_slide(direction)
