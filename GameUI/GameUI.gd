extends Control

export var fade_duration = 2 # How long should fade be.
enum LevelFades{none, level_complete, game_over}
var level_fade = LevelFades.none # For convenience.
var fade_progress = 0 # How faded out is the scene right now.
onready var level_complete_fade_node = $"LevelCompleteFade" # For speed and convenience.
onready var game_over_fade_node = $"GameOverFade" # For speed and convenience.

func _ready():
	Global.connect("level_complete_fade", self, "on_level_complete_fade")
	Global.connect("level_lost_fade", self, "on_level_lost_fade")
	Global.connect("change_health", self, "on_health_change")
	game_over_fade_node.modulate.a = 0
	level_complete_fade_node.modulate.a = 0

func _process(delta):
	if level_fade == LevelFades.level_complete:
		fade_progress += delta * fade_duration
		level_complete_fade_node.modulate.a = fade_progress
		if fade_progress > 1 - .0001:
			Global.emit_signal("level_complete")
	elif level_fade == LevelFades.game_over:
		fade_progress += delta * fade_duration
		game_over_fade_node.modulate.a = fade_progress
		if fade_progress > 1 - .0001:
			Global.emit_signal("level_lost")


func on_level_complete_fade():
	if (level_fade == LevelFades.none):
		fade_progress = 0
		level_fade = LevelFades.level_complete

func on_level_lost_fade():
	if (level_fade == LevelFades.none):
		fade_progress = 0
		level_fade = LevelFades.game_over

func on_health_change():
	$"Label".text = str(Global.user_params.current_health)
