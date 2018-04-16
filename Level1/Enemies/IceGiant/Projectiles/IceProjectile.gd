extends KinematicBody2D

export var projectile_speed = .5 # The speed of this projectile.
export var rotation_speed = 10.0 # How quickly to rotate the projectile.
export var rotate_projectile_constantly = false # Whether to rorate the projectile constantly.
var damage_amount = 1 # To inform damage receiver, how much damage to inflict.
var direction # Fly into this direction.
var constant_rotation_direction = 1 # To which side to rotate the projectiles.
var parent_enemy # For speed and convenience.

func kill_projectile():
	self.queue_free()

func _physics_process(delta):
	var speed = delta * projectile_speed # For speed and convenience.
	move_and_slide(direction * speed)
	if !rotate_projectile_constantly:
		self.rotation = atan2(direction.y, direction.x) * 180 / PI
	position += direction * speed

	if get_slide_count() > 0:
		var kinematic_collision_2D = get_slide_collision(0) # For speed and convenience.
		if kinematic_collision_2D:
			self.queue_free()

	if parent_enemy.get_global_transform().origin.distance_to(self.get_global_transform().origin) > Global.user_params.ice_giant_projectile_max_distance_from_parent:
		self.queue_free()

func _process(delta):
	if rotate_projectile_constantly:
		if self.rotation > 360.0:
			self.rotation -= 360.0
		elif self.rotation < 0.0:
			self.rotation += 360.0
		self.rotation += rotation_speed * delta * constant_rotation_direction
