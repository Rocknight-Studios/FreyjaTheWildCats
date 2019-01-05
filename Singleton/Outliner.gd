extends Tree

var tree_item = null # To remember which tree item to manage under which.
onready var show_node_info_button = Global.visual_debugger.get_node("TabContainer/VisualSelect/SelectedNodeInfo/ShowNodeInfoButton") # For speed and convenience.
const TREE_ITEM_CUSTOM_MINIMUM_HEIGHT = 15.0 # To correctly calculate the height of the tree container.

func add_a_tree_item(node, parent_item):
	tree_item = create_item(parent_item)
	tree_item.set_text(0, node.name)
	tree_item.set_metadata(0, node.get_path())
	tree_item.collapsed = false if parent_item == null else true
	tree_item.custom_minimum_height = TREE_ITEM_CUSTOM_MINIMUM_HEIGHT

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
	get_all_outline_nodes(Global.cached_root, null)

func _on_Outliner_cell_selected():
	var tmp_node_path_metadata = get_selected().get_metadata(0) # For speed and convenience.
	Global.visual_debugger.full_selected_path = str(tmp_node_path_metadata)
	Global.visual_debugger.node_is_selected = true
	show_node_info_button.set_info_text(tmp_node_path_metadata.get_name(tmp_node_path_metadata.get_name_count() - 1))

var widest_outliner_branch = 0 # To determine how wide should be the h scroll bar.

func find_widest_branch(current_branch_root_item):
	while true:
		if str(current_branch_root_item.get_metadata(0)).length() > widest_outliner_branch:
			widest_outliner_branch = str(current_branch_root_item.get_metadata(0)).length()
			var current_widest_parent_item = current_branch_root_item.get_parent() # To find out whether the branch is collapsed.
			while true:
				if current_widest_parent_item == null:
					break
				if current_widest_parent_item.collapsed == true:
					widest_outliner_branch = str(current_widest_parent_item.get_metadata(0)).length()
					break
				current_widest_parent_item = current_widest_parent_item.get_parent()
		if current_branch_root_item.collapsed != true:
			var current_item_children = current_branch_root_item.get_children() # For speed and convenience.
			find_widest_branch(current_item_children)
			amount_of_expanded_items += count_this_branch_direct_children (current_item_children)
		current_branch_root_item = current_branch_root_item.get_next()
		if current_branch_root_item == null:
			break

func count_this_branch_direct_children(first_item):
	var amount_of_children = 0 # To accumulate amount and exit function gracefully.
	while first_item != null:
		first_item = first_item.get_next()
		amount_of_children += 1
	return amount_of_children

var amount_of_expanded_items = 0 # To calculate the height of the tree.
const TREE_ITEM_CUSTOM_MINIMUM_HEIGHT_COEFFICIENT = 1.7 # To compensate item height vs tree height and set correct height of the tree.
const MIN_TREE_HEIGHT = 160 # Don't allow tree to become less high than this.

func _on_Outliner_item_collapsed(item):
	widest_outliner_branch = 0
	amount_of_expanded_items = 1
	find_widest_branch(get_root())
	var current_height = max(TREE_ITEM_CUSTOM_MINIMUM_HEIGHT * amount_of_expanded_items * TREE_ITEM_CUSTOM_MINIMUM_HEIGHT_COEFFICIENT, MIN_TREE_HEIGHT) # For speed and convenience.
	get_parent().rect_min_size.y = current_height
	get_parent().get_parent().scroll_vertical_enabled = true if current_height > MIN_TREE_HEIGHT else false
