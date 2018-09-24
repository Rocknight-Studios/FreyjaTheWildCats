extends Tree

var tree_item = null # To remember which tree item to manage under which.
onready var root_node = Global.visual_debugger.get_tree().get_root() # For speed and convenience.

func add_a_tree_item(node, parent_item):
	tree_item = create_item(parent_item)
	tree_item.set_text(0, node.name)
	tree_item.collapsed = false if parent_item == null else true

func get_all_outline_nodes(node, parent_item):
	add_a_tree_item(node, parent_item)
	var last_parent_tree_item = tree_item
	for i in node.get_children():
		if i.get_child_count() > 0:
			get_all_outline_nodes(i, last_parent_tree_item)
		else:
			add_a_tree_item(i, last_parent_tree_item)

func _on_form_the_outliner():
	clear()
	get_all_outline_nodes(root_node, null)
