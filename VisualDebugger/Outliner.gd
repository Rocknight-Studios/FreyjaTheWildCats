extends Tree

onready var show_node_info_button = Global.visual_debugger.get_node("TabContainer/VisualSelect/SelectedNodeInfo/ShowNodeInfoButton") # For speed and convenience.

var tree_item = null # To remember which tree item to manage under which.
var deepest_branch_width = 0 # To determine how wide should be the h scroll bar.
var dont_find_the_widest_branch_while_building_the_tree = false # To avoid performing redundant (called by on_collapse signal) work and make management easier.
var current_deepest_item = null # To widen the scope and make management easier.

const INDENT_WIDTH = 1.0 # How much deeper to push each indent. (Expand triangle characters and icons)
const SPACE_BETWEEN_COLUMNS = 1.0 # How many characters between columns.
const ONE_CHARACTER_WIDTH = 10.0 # To calculate correctly the column 0 width.

func add_a_tree_item(node, parent_item):
	tree_item = create_item(parent_item)
	tree_item.set_text(0, node.name)
	tree_item.set_text(1, "Control")
	tree_item.set_metadata(0, node.get_path())
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
	dont_find_the_widest_branch_while_building_the_tree = true
	get_all_outline_nodes(Global.cached_root, null)
	dont_find_the_widest_branch_while_building_the_tree = false
	_on_Outliner_item_collapsed(null)

func _on_Outliner_cell_selected():
	var tmp_node_path_metadata = get_selected().get_metadata(0) # For speed and convenience.
	Global.visual_debugger.full_selected_path = str(tmp_node_path_metadata)
	Global.visual_debugger.node_is_selected = true
	show_node_info_button.set_info_text(tmp_node_path_metadata.get_name(tmp_node_path_metadata.get_name_count() - 1))

var absolute_widest_branch_width = 0 # Which is the widest branch regardless of indentation level and including node type. Width seperately for performance.
var absolute_widest_branch = null # Which is the widest branch regardless of indentation level and including node type.

func find_widest_and_deepest_branches(current_branch_root_item):
	while true:
		if str(current_branch_root_item.get_metadata(0)).length() > deepest_branch_width:
			current_deepest_item = current_branch_root_item
			var path_name_count = current_branch_root_item.get_metadata(0).get_name_count() # For speed and convenience.
			deepest_branch_width = (path_name_count - 1) * INDENT_WIDTH + current_branch_root_item.get_metadata(0).get_name(path_name_count - 1).length()
			if absolute_widest_branch == null || deepest_branch_width + current_branch_root_item.get_text(1).length() > absolute_widest_branch_width + absolute_widest_branch.get_text(1).length():
				absolute_widest_branch_width = deepest_branch_width
				absolute_widest_branch = current_deepest_item
			var current_widest_parent_item = current_branch_root_item.get_parent() # To find out whether the branch is collapsed.
			while true:
				if current_widest_parent_item == null:
					break
				if current_widest_parent_item.collapsed == true:
					deepest_branch_width = str(current_widest_parent_item.get_metadata(0)).length()
					break
				current_widest_parent_item = current_widest_parent_item.get_parent()
		if current_branch_root_item.collapsed != true:
			find_widest_and_deepest_branches(current_branch_root_item.get_children())
		current_branch_root_item = current_branch_root_item.get_next()
		if current_branch_root_item == null:
			break

func _on_Outliner_item_collapsed(item):
	if !dont_find_the_widest_branch_while_building_the_tree:
		absolute_widest_branch_width = 0
		deepest_branch_width = 0
		find_widest_and_deepest_branches(get_root())
		print(absolute_widest_branch_width)
		#set_column_min_width(0, ONE_CHARACTER_WIDTH * (absolute_widest_branch_width + SPACE_BETWEEN_COLUMNS))
		set_column_min_width(0, ONE_CHARACTER_WIDTH * (absolute_widest_branch_width))
		absolute_widest_branch_width += absolute_widest_branch.get_text(1).length()
		print(absolute_widest_branch.get_text(0))
		set_column_expand(1, true)
		set_column_expand(0, false)
