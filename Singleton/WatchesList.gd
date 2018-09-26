extends ItemList

onready var watch_name = get_parent().get_node("WatchName") # For speed and convenience.

func add_a_node():
	if watch_name.text != "Type watch name":
		add_item(watch_name.text, null, true)

func _on_AddNode_button_down():
	add_a_node()
