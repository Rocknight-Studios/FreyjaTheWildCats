extends KinematicBody2D

export var projectile_speed = .5 # The speed of this projectile.
var damage_amount = 1 # To inform damage receiver, how much damage to inflict.
var direction # Fly into this direction.

func kill_projectile():
	self.queue_free()

func _physics_process(delta):
	var speed = delta * projectile_speed # For speed and convenience.
	move_and_slide(direction * speed)
	self.rotation = atan2(direction.y, direction.x) * 180 / PI
	position += direction * speed

	if get_slide_count() > 0:
		var kinematic_collision_2D = get_slide_collision(0) # For speed and convenience.
		if kinematic_collision_2D:
			self.queue_free()

	if get_parent().get_global_transform().origin.distance_to(self.get_global_transform().origin) > Global.user_params.ice_giant_projectile_max_distance_from_parent:
		self.queue_free()
