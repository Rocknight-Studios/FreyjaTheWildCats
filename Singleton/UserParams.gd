extends Node2D

export var ice_giant_projectile_max_distance_from_parent = 700.0 # How far can enemy projectile travel from it's parent before it is destroyed.
export var ice_giant_projectile_offsets = [] # Projectile offsets from the enemy. As Godot can't different array variables exposed in Inspector.
export (NodePath) var game_over_scene_path # To easily set, which scene must be used as a game over scene.
export (NodePath) var level_won_scene_path # To easily set, which scene must be used as a game won scene.
export (NodePath) var new_game_scene_path # To easily set, which scene must be used.
export (NodePath) var menu_screen_scene_path # To easily set, which scene must be used.

onready var global_functions = get_node("GlobalFunctions") # For speed and convenience.

var current_health # For project to know the health of the player.
var total_health = 10 # How much health does the player have.
