extends Tree

onready var show_node_info_button = Global.visual_debugger.get_node("TabContainer/VisualSelect/SelectedNodeInfo/ShowNodeInfoButton") # For speed and convenience.
onready var indent_width = get_constant("item_margin") # For speed and convenience.
onready var one_character_width = get_font("font").size * FONT_ASPECT_RATIO # To calculate correctly the column 0 width.
onready var relative_indent_coefficient = indent_width / one_character_width # What is the factor between ONE_CHARACTER_WIDTH and indent_width.

var tree_item = null # To remember which tree item to manage under which.
var deepest_branch_width = 0 # To determine how wide should be the h scroll bar.
var dont_find_the_widest_branch_while_building_the_tree = false # To avoid performing redundant (called by on_collapse signal) work and make management easier.
var current_deepest_item = null # To widen the scope and make management easier.
var icon_dictionary = {} # All the icons for the classes should be assigned here.
var absolute_widest_branch_width = 0 # Which is the widest branch regardless of indentation level and including node type. Width seperately for performance.
var absolute_widest_branch = null # Which is the widest branch regardless of indentation level and including node type.
var absolute_widest_type_text = "" # To correctly calculate the width of the whole branch.

const SPACE_BETWEEN_COLUMNS = 5.0 # How many characters between columns.
const FONT_ASPECT_RATIO = .5 # How much wider is font than it is high.

func load_textures(var dir_path):
	var dir = Directory.new()
	dir.open(dir_path)
	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if !dir.current_is_dir():
			icon_dictionary[file_name.replace("icon_", "").replace(".svg", "").replace("_", "")] = load(dir_path + "/" + file_name)
		file_name = dir.get_next()

func _ready():
	load_textures("res://VisualDebugger/icons/")
	Global.visual_debugger.outliner = self
	_on_form_the_outliner()

func add_a_tree_item(node, parent_item):
	tree_item = create_item(parent_item)
	var this_node_class = node.get_class() # For speed and convenience.
	tree_item.set_icon(0, icon_dictionary[this_node_class.to_lower()])
	tree_item.set_text(0, node.name)
	tree_item.set_text(1, this_node_class)
	tree_item.set_metadata(0, node.get_path())
	tree_item.collapsed = false if parent_item == null else true

	if this_node_class == "Camera2D":
		Global.visual_debugger.game_camera = node

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

func find_widest_and_deepest_branches(current_branch_root_item):
	while true:
		if str(current_branch_root_item.get_metadata(0)).length() > deepest_branch_width:
			current_deepest_item = current_branch_root_item
			var path_name_count = current_branch_root_item.get_metadata(0).get_name_count() # For speed and convenience.
			deepest_branch_width = path_name_count * relative_indent_coefficient + current_branch_root_item.get_metadata(0).get_name(path_name_count - 1).length()
			if absolute_widest_type_text.length() < current_branch_root_item.get_text(1).length():
				absolute_widest_type_text = current_branch_root_item.get_text(1)
			if absolute_widest_branch_width == 0 || deepest_branch_width > absolute_widest_branch_width:
				absolute_widest_branch_width = deepest_branch_width
				absolute_widest_branch = current_deepest_item
			var current_widest_parent_item = current_branch_root_item.get_parent() # To find out whether the branch is collapsed.
			while true:
				if current_widest_parent_item == null:
					break
				if current_widest_parent_item.collapsed == true:
					path_name_count = current_widest_parent_item.get_metadata(0).get_name_count()
					deepest_branch_width = path_name_count * relative_indent_coefficient + current_widest_parent_item.get_metadata(0).get_name(path_name_count - 1).length()
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
		absolute_widest_type_text = ""
		find_widest_and_deepest_branches(get_root())
		absolute_widest_branch_width = (absolute_widest_branch_width + SPACE_BETWEEN_COLUMNS) * one_character_width
		set_column_expand(1, true)
		set_column_expand(0, false)
		set_column_min_width(0, absolute_widest_branch_width)
		absolute_widest_branch_width += absolute_widest_type_text.length() * one_character_width
