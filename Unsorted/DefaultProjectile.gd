extends KinematicBody2D

export var projectile_speed = 10000 # The speed of this projectile.
var player_node # For speed and convenience.
var damage_amount = 1 # To inform damage receiver, how much damage to inflict.

func _ready():
	player_node = get_parent().get_node("Player")

func _physics_process(delta):
	var speed = delta * (-projectile_speed - player_node.default_speed) # For speed and convenience.
	move_and_slide(Vector2(0, speed))
	position.y += speed

	if get_slide_count() > 0:
		var kinematic_collision_2D = get_slide_collision(0) # For speed and convenience.
		if kinematic_collision_2D:
			var colliding_node = kinematic_collision_2D.collider.get_parent() # For speed and convenience.
			if colliding_node.is_in_group("Enemies"):
				kinematic_collision_2D.collider.get_parent().receive_damage(damage_amount)
			self.queue_free()
