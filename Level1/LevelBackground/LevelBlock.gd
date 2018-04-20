extends Sprite

export var enemy_optimization_distance = 3000.0 # Deactivate enemies at this distance.
var enemies = [] # All the enemies of this block.
enum ActivityState {none, activated, deactivated}
onready var activity_state = ActivityState.none # To save resources.
onready var management_start_time = OS.get_ticks_msec() # To save resources.
var management_pause = 1.0 # How often to check for the new block activity state.

func _ready():
	for i in range(0, get_child_count()):
		if get_child(i).is_in_group("Enemies"):
			enemies.append(get_child(i))

	yield(get_tree(), "idle_frame")
	deactivate_block()

func _process(delta):
	if OS.get_ticks_msec() - management_start_time > management_pause:
		management_start_time = OS.get_ticks_msec()
		manage_block_activity()

func manage_block_activity():
	if Global.player.get_global_transform().origin.distance_to(self.get_global_transform().origin) > enemy_optimization_distance:
		deactivate_block()
	else:
		activate_block()

func activate_block():
	if activity_state != ActivityState.activated:
		for i in range(0, enemies.size()):
			enemies[i].initialized = true
			add_child(enemies[i])
		activity_state = ActivityState.activated

func deactivate_block():
	if activity_state != ActivityState.deactivated:
		for i in range(0, enemies.size()):
			remove_child(enemies[i])
		activity_state = ActivityState.deactivated
