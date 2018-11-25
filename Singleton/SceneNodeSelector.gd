extends Node2D

export var node_types_to_detect = ["Node2D", "StaticBody2D"] # What type of nodes to detect.
export var selection_color = Color(0, .1, 0, .1) # What color to use for selection precision area.

onready var selection_radius = 50.0 # How precisely to detect the selectable node.
onready var relative_mouse_position = Vector2(0.0, 0.0) # To detect object relative to the debugger camera position.
onready var absolute_mouse_position = Vector2(0.0, 0.0) # For speed and convenience.
onready var selection_info = get_parent().get_node("TabContainer/VisualSelect/SelectionInfo") # For speed and convenience.

var full_paths = [] # To quickly access full path for each node.
export var reversed_node_path = [] # To have persistency through the recursion.

func _input(event):
	if !Input.is_action_pressed("left_control_down"):
		manage_customization_params(event)
	manage_selection()

func manage_customization_params(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			selection_radius += selection_radius * .1
		elif event.button_index == BUTTON_WHEEL_DOWN:
			selection_radius -= selection_radius * .1
		selection_radius = clamp(selection_radius, 5.0, 2000.0)

func _process(delta):
	absolute_mouse_position = get_viewport().get_mouse_position()
	relative_mouse_position = Global.visual_debugger.debugger_camera.position + absolute_mouse_position * Global.visual_debugger.debugger_camera.zoom
	update()

func manage_selection():
	if !Global.visual_debugger.forbid_selection_circle_management && !Global.visual_debugger.mouse_is_over_visual_debugger_gui && Input.is_action_just_pressed("mouse_left_click"):

		selection_info.text = ""
		full_paths = []

		if Global.camera:
			get_all_nodes(Global.cached_root)

		selection_info.text = selection_info.text.substr(1, selection_info.text.length() - 1)

func determine_whether_this_node_is_under_mouse(node):
	var manage_this_node = false # For convenience.
	for i in range(node_types_to_detect.size()):
		if str(node).find(node_types_to_detect [i]) > -1:
			manage_this_node = true
			break

	if manage_this_node:
		if (relative_mouse_position).distance_to(node.get_global_transform().origin) < selection_radius * Global.visual_debugger.debugger_camera.zoom_scale:
			var full_node_path = "" # To form the full node path.
			reversed_node_path = []
			selection_info.text += "\n" + node.name
			get_reversed_node_path(node)
			for i in range(reversed_node_path.size() - 1, -1, -1):
				full_node_path += "/" + reversed_node_path[i]
			full_paths.append(full_node_path)

func get_reversed_node_path(node):
	reversed_node_path.append(node.name)
	if node.get_parent():
		get_reversed_node_path(node.get_parent())

func get_all_nodes(node):
	for i in node.get_children():
		if i.get_child_count() > 0:
			determine_whether_this_node_is_under_mouse(i)
			get_all_nodes(i)
		else:
			determine_whether_this_node_is_under_mouse(i)

func _draw():
	if !Global.visual_debugger.forbid_selection_circle_management:
		draw_circle(absolute_mouse_position, selection_radius, selection_color);
	else:
		draw_circle(absolute_mouse_position, selection_radius, Color(0.0, 0.0, 0.0, 0.0));
