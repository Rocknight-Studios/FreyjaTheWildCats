extends Node2D

export var default_speed = 10000 # Default movement speed of the player.
export var projectile_offset = Vector2(.1, 0) # Projectile must not be in the middle of the player.
export (PackedScene) var default_projectile # To be able to instantiate projectiles.
onready var window_size = OS.get_window_size() # What is the window size in pixels.
var projectile_shot_start_time = 0 # To know, when to do the next shot.
onready var freyja_animator = get_node("Chariot").get_node("Freyja").get_node("FreyjasHairAnimation") # To save resources.
export var freyja_attack_animation_speed = 2 # How quickly to playback animation during attack.
var freyja_idle_animation_speed = 1 # How quickly to playback animation during attack.
var player_positioner = null # For speed and convenience.
export var max_lerp_speed = 5.0 # How quickly to lerp to the goal position.
export var lerp_speed_up_speed = 10.0 # How quickly to speed up to max speed.
export var lerp_speed_drop_distance = 100.0 # How close to the goal position must visualization be, for lerp speed to drop down.
var lerp_speed = 0.0 # Current speed at which to lerp to the new positioner position.
onready var projectile_timer = $"ProjectileTimer" # For speed and convenience.
var animation_offset_qoefficient = .5 # Projectile must be launched at certain time compared to the animation.

func _ready():
	Global.player = self
	self.position = Global.camera.position + Vector2(window_size.x * .5, window_size.y * .5)

func _physics_process(delta):
	var speed = default_speed * delta # For speed and convenience.
	player_positioner.manage_player_movement(speed)
	manage_shooting()

func lerp_position_2D(from, to, self_lerp_progress):
	var return_value = Vector2(from + (to - from) * self_lerp_progress) # For safer function behaviour.
	return return_value

func interpolate_to_player_positioner_state(delta):
	if (self.get_global_transform().origin.distance_to(player_positioner.get_global_transform().origin) > lerp_speed_drop_distance):
		lerp_speed += lerp_speed_up_speed * delta
	else:
		lerp_speed -= lerp_speed_up_speed * delta
	lerp_speed = clamp(lerp_speed, 0.0, max_lerp_speed)
	self.position = lerp_position_2D(self.position, player_positioner.position, lerp_speed * delta)

func _process(delta):
	interpolate_to_player_positioner_state(delta)

func manage_shooting():
	var direction = Vector2(0, 1) # The direction of the current movement step.
	if Input.is_action_pressed ("ui_shoot"):
		# This is how to spawn instances synced with animation speed, when animation tree player is not used.
		if OS.get_ticks_msec() - projectile_shot_start_time > freyja_animator.current_animation_length * 1000 / freyja_attack_animation_speed:
			freyja_animator.seek(0.0, true)
			freyja_animator.current_animation = "SpearThrowingFlipHair"
			freyja_animator.play()
			freyja_animator.playback_speed = freyja_attack_animation_speed
			projectile_shot_start_time = OS.get_ticks_msec()
			projectile_timer.wait_time = freyja_animator.current_animation_length / freyja_attack_animation_speed * animation_offset_qoefficient
			projectile_timer.start()
	else:
		if abs(abs(freyja_animator.playback_speed) - abs(freyja_idle_animation_speed)) > Global.approximation_float:
			projectile_timer.stop() # Don't do a redundant throw.
			freyja_animator.seek(2.0, true) # Set to the position, where there is no spear in the hand.
			freyja_animator.current_animation = "Idle"
			freyja_animator.playback_speed = freyja_idle_animation_speed
			freyja_animator.play()

func on_launch_a_projectile():
	var instanced_projectile = default_projectile.instance()
	Global.current_scene.add_child(instanced_projectile)
	instanced_projectile.position = self.position + projectile_offset
