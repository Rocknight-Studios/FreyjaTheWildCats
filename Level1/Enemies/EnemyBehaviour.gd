extends Node2D

export var total_health = 10 # How many time must this enemy be hit before it dies.
export var fade_out_speed = 5 # How quickly to fade enemy out on death.
var middle_of_the_screen_y = 0.0 # To be fair and not start launching projectiles, when the player is at the top of the screen.
onready var projectile_launch_start_time = OS.get_ticks_msec() # To know when to launch each projectile.
onready var current_health = total_health # How much health does this enemy still have.
onready var death_particles # For speed and convenience.
onready var death_soul_particles # For speed and convenience.
onready var death_timer # For speed and convenience.
onready var blood_splat_start_time = OS.get_ticks_msec() # To know, when to do the next blood splatter.
onready var sprite_body # For speed and convenience.
onready var	enemy_must_fade_out = false # To know, when to perform enemy fade out.
export (PackedScene) var projectile_template # For speed and convenience.
var disable_layer_id = 1024 # To avoid magic numbers.
onready var enemy_animator = $"AnimationPlayer" # For speed and convenience.
onready var enemy_animation_tree_player = $"AnimationTreePlayer"
export var attack_animation_speed = .25 # To avoid use of magic numbers.
export var idle_animation_speed = 1.0 # To avoid use of magic numbers.
export var animation_blend_speed = 1.0 # How quickly to blend between animations.
var animation_blend_value = 0.0 # What is the current blending between idle and attack.
export var projectile_type = "ice_giant_projectile_offsets" # To know, which array to use for the projectiles.
var reference_to_profectile_offsets = null # For speed and convenience.
var current_projectile_offset_index = 0 # To change which offset is being used.
var animation_offset = .3 # Projectile must be launched at certain time compared to the animation.

func _ready():
	self.add_to_group("Enemies")
	death_particles = get_node("DeathParticles")
	death_soul_particles = get_node("DeathSoulParticles")
	death_timer = get_node("DeathTimer")
	sprite_body = get_node("Body")
	enemy_animation_tree_player.active = true

	reference_to_profectile_offsets = Global.user_params.get(projectile_type)

func receive_damage(damage_amount):
	if current_health >= 0:
		death_particles.emitting = true
		if OS.get_ticks_msec() - blood_splat_start_time > death_particles.lifetime * 1000.0 * .8:
			death_particles.restart()
			blood_splat_start_time = OS.get_ticks_msec()
		current_health -= damage_amount
		if current_health < 0:
			death_timer.wait_time = death_soul_particles.lifetime
			death_soul_particles.emitting = true
			death_soul_particles.restart()
			enemy_must_fade_out = true
			death_particles.emitting = false
			death_particles.modulate.a = 0.0
			get_node("EnemyCollider").set_collision_layer(disable_layer_id)
			death_timer.start()

func _on_DeathTimer_timeout():
	self.queue_free()

func _process(delta):
	manage_projectile(delta)
	if enemy_must_fade_out:
		sprite_body.modulate.a -= fade_out_speed * delta

func manage_projectile(delta):
	if Global.player.get_global_transform().origin.distance_to(self.get_global_transform().origin) < Global.user_params.ice_giant_projectile_max_distance_from_parent:
		if abs(abs(enemy_animator.playback_speed) - abs(attack_animation_speed)) > Global.approximation_float:
			enemy_animator.playback_speed = attack_animation_speed
		animation_blend_value += animation_blend_speed * delta
		animation_blend_value = clamp(animation_blend_value, 0.0, 1.0)
		enemy_animation_tree_player.blend2_node_set_amount("blend2", animation_blend_value)
		var ticks_compensation = 1000.0 # For convenience.
		var specific_animation_compensator = .5 # Each animation can have situation, where some events are be repeated multiple times during the animation.
		if !enemy_must_fade_out && OS.get_ticks_msec() - projectile_launch_start_time > animation_offset + enemy_animator.get_animation("Attack").length * enemy_animator.playback_speed * ticks_compensation * specific_animation_compensator / attack_animation_speed:
			projectile_launch_start_time = OS.get_ticks_msec()
			if projectile_template:
				var instanced_projectile = projectile_template.instance()
				get_parent().add_child(instanced_projectile)
				instanced_projectile.position = self.position + reference_to_profectile_offsets[current_projectile_offset_index]
				instanced_projectile.direction = Global.player.get_global_transform().origin - self.get_global_transform().origin
				current_projectile_offset_index += 1
				if current_projectile_offset_index > reference_to_profectile_offsets.size() - 1: # Perhaps Sin function would be better here (have to investigate resource consumption).
					current_projectile_offset_index = 0
	else:
		if abs(abs(enemy_animator.playback_speed) - abs(idle_animation_speed)) > Global.approximation_float:
			enemy_animator.playback_speed = idle_animation_speed
		animation_blend_value -= animation_blend_speed * delta
		animation_blend_value = clamp(animation_blend_value, 0.0, 1.0)
		enemy_animation_tree_player.blend2_node_set_amount("blend2", animation_blend_value)
