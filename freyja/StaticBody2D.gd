extends Area2D

var collision_is_active = false # To know, for how long the collision is active.
export var total_health = 10 # How much health does the player have.
export var health_decrease_amount = 1 # How much to deplete the health in each depletion step.
export var health_decrease_frequency = 500 # How quickly is the health depleting.
onready var health_depletion_step_start_time = OS.get_ticks_msec() # To know when to perform new depletion.
onready var current_health = total_health # What is the current health of the player.

func _physics_process(delta):
	if collision_is_active:
		if OS.get_ticks_msec() - health_depletion_step_start_time > health_decrease_frequency:
			health_depletion_step_start_time = OS.get_ticks_msec()
			current_health -= health_decrease_amount
			if current_health < 0:
				current_health = 0
				Global.emit_signal("level_lost_fade")
			else:
				Global.user_params.current_health = current_health
				Global.emit_signal("change_health")

func manage_enemy_projectile(body):
	if body.is_in_group("EnemyProjectiles"):
		body.kill_projectile()

func _on_Area2D_body_entered(body):
	collision_is_active = true
	manage_enemy_projectile(body)

func _on_Area2D_body_exited( body ):
	collision_is_active = false
