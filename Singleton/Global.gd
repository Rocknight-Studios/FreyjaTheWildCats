extends Node

signal restart # To know, when to reset.
signal level_complete # To know, when to set victory state.
signal level_lost # To know, when to set lost state.
signal level_complete_fade # To know, when to set victory state.
signal level_lost_fade # To know, when to set lost state.
signal change_health # To know, when to add or deplete health.
signal start_new_game # To know, when the new game button has been pressed.

const full_circle_in_degrees = 360.0 # To avoid having magic numbers.
const to_seconds_multiplier = 1000 # To avoid having magic numbers.
const approximation_float = .0001 # To avoid having magic numbers.

var player # For speed and convenience.
var camera # For speed and convenience.
var current_scene = null # Currently active scene for speed and convenience.
var user_params_scene = preload("res://Singleton/UserParams.tscn") # To let user set parameters in inspector. Do it during runtime in the UserParams scene or in Remote.
var loading_screen_scene = preload("res://LoadingScreen/LoadingScreen.tscn") # Persistent loading screen.
var visual_debugger_scene = preload("res://Singleton/VisualDebugger.tscn") # To have persistent visual game debugger.
var loading_screen = null # For speed and convenience.
var user_params = null # Instanced access point to user params. Must be a child of Global, otherwise it doesn't appear in hierarchy. It can be accessed anywhere in the code using globa.user_params
var visual_debugger = null # Instanced visual debugger.
var loader = null # This will get polled in process.
var wait_frames # To allow to show the loading screen up.
var time_max = 100 # Max time allowed for poll.
onready var visual_debugger_z_index_node2D = Node2D.new() # To be able to set the z_index.
var z_index_over_menu = 6 # To avoid having magic numbers.

func _ready():
	# Connect all the global signals before loading any scene.
	connect("restart", self, "on_restart_game")
	connect("level_lost", self, "on_level_lost")
	connect("level_complete", self, "on_level_won")
	# Instance and add user params before anything else is done.
	user_params = user_params_scene.instance()
	loading_screen = loading_screen_scene.instance()
	visual_debugger = visual_debugger_scene.instance()
	add_child(user_params)
	add_child(loading_screen)
	add_child(visual_debugger_z_index_node2D)
	visual_debugger_z_index_node2D.name = "VisualDebuggerZIndex"
	visual_debugger_z_index_node2D.z_index = z_index_over_menu
	visual_debugger_z_index_node2D.add_child(visual_debugger)
	loading_screen.visible = false
	# Get the current scene as soon as the scene tree is loaded.
	# Current scene is going to be the last one because autoloads are always loaded first.
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	# Do all the current_scene related initialization below.
	connect("start_new_game", self, "on_new_game_start")

func quick_goto_scene(path):
	# Wait until the scene doesn't do anything then free it and load the new one.
	call_deferred("_deferred_goto_scene", path)

func goto_scene(path):
	loader = ResourceLoader.load_interactive(path)
	if loader == null:
		show_error()
		return
	set_process(true)

	current_scene.queue_free()

	loading_screen.visible = true
	# Initialize any loading screen appearance params here.

	wait_frames = 1

func _process(time):
	if loader == null:
		set_process(false)
		return

	if wait_frames > 0:
		wait_frames -= 1
		return

	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			var resource = loader.get_resource()
			loader = null
			loading_screen.visible = false
			# Initialize any loading screen dissapearance params here.
			set_new_scene(resource)
			break
		elif err == OK:
			update_progress()
		else:
			show_error()
			loader = null
			break

func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	loading_screen.get_node("Label").text = str(progress * 100) + "%"
	# Manage any cool loading stuff here.
	# get_node("LoadingScreen/Progress").text = str(progress)
	# var animation_length = get_node("LoadingScreen/AnimationPlayer").get_current_animation_length()
	# get_node("LoadingScreen/AnimationPlayer").seek(progress * animation_length, true)

func set_new_scene(scene_resource):
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)

func _deferred_goto_scene(path):
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)

	# Do any Global scene specific var initialization after the scene is loaded in it's children and it's _ready functions, it allows also to avoid get_node as self can be passed for references.
	# This is better design (better decoupling), it is cleaner(less code) and more efficient (just send info to globals instead of feedback looping them back and forth)

func on_new_game_start():
	goto_scene(user_params.new_game_scene_path)

func on_level_lost():
	quick_goto_scene(user_params.game_over_scene_path)

func on_level_won():
	quick_goto_scene(user_params.level_won_scene_path)

func on_restart_game():
	quick_goto_scene(user_params.menu_screen_scene_path)
