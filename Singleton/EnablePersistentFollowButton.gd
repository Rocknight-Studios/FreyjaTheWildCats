extends CheckButton

onready var jump_to_node_button = get_parent().get_node("JumpToNodeButton") # For speed and convenience.

func _process(delta):
	if self.pressed:
		jump_to_node_button._on_JumpToNodeButton_pressed()

