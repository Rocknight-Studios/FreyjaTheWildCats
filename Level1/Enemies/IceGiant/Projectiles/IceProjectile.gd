extends KinematicBody2D

export var projectile_speed = .5 # The speed of this projectile.
export var rotation_speed = 10.0 # How quickly to rotate the projectile.
export var rotate_projectile_constantly = false # Whether to rorate the projectile constantly.
var damage_amount = 1 # To inform damage receiver, how much damage to inflict.
var direction # Fly into this direction.
var constant_rotation_direction = 1.0 # To which side to rotate the projectiles.
var parent_enemy # For speed and convenience.
var velocity_multiplier = 500.0 # To turn the normalized velocity into realistic speed.
var velocity = Vector2 (0.0, 0.0) # To save resources.

func kill_projectile():
	self.queue_free()

func _physics_process(delta):
	var speed = delta * projectile_speed # For speed and convenience.
	velocity = direction * speed * velocity_multiplier
	move_and_slide(velocity)
	if !rotate_projectile_constantly:
		self.rotation = atan2(velocity.y, velocity.x) * (Global.full_circle_in_degrees * .5) / PI
	position += velocity

	if get_slide_count() > 0:
		var kinematic_collision_2D = get_slide_collision(0) # For speed and convenience.
		if kinematic_collision_2D:
			self.queue_free()

	if parent_enemy.get_global_transform().origin.distance_to(self.get_global_transform().origin) > Global.user_params.ice_giant_projectile_max_distance_from_parent:
		self.queue_free()

func _process(delta):
	if rotate_projectile_constantly:
		if self.rotation > Global.full_circle_in_degrees:
			self.rotation -= Global.full_circle_in_degrees
		elif self.rotation < 0.0:
			self.rotation += Global.full_circle_in_degrees
		self.rotation += rotation_speed * delta * constant_rotation_direction
