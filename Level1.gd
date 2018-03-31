extends Node

func _ready():
	# This is how to connect another node's signal to call this node's callback.
	# In this case Global autoload signal is used (be careful not to connect from child to global multiple times that will cause an error)
	#	This Global.connect("level_lost", Global, "on_level_lost") would cause an error on level restart.
	Global.connect("level_lost", self, "on_level_lost")
	Global.connect("level_complete", self, "on_level_won")

	var player_positioner = Global.player.get_node("PlayerPositioner")
	Global.player.remove_child(player_positioner)
	self.add_child(player_positioner)
	Global.player.player_positioner = player_positioner
	player_positioner.position = Global.player.get_global_transform().origin

func on_level_lost():
	print("Level lost")

func on_level_won():
	print("Level won")
