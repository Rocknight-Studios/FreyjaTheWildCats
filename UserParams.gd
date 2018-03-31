extends Node2D

var current_health # For project to know the health of the player.
export var ice_giant_projectile_max_distance_from_parent = 700.0 # How far can enemy projectile travel from it's parent before it is destroyed.
export (NodePath) var game_over_scene_path # To easily set, which scene must be used as a game over scene.
export (NodePath) var level_won_scene_path # To easily set, which scene must be used as a game won scene.
export (NodePath) var new_game_scene_path # To easily set, which scene must be used.
export (NodePath) var menu_screen_scene_path # To easily set, which scene must be used.
