extends HScrollBar

onready var outliner = get_parent().get_node("Outliner") # For speed and convenience.
const BRANCH_WIDTH_THRESHOLD = 100 # If the path to the tree item is wider than this show the horizontal scroll bar.
onready var outliner_width = outliner.rect_size.x # For speed and convenience.

func _process(delta):
	if outliner.widest_outliner_branch > BRANCH_WIDTH_THRESHOLD:
		visible = true
		max_value = outliner.widest_outliner_branch
		page = outliner.widest_outliner_branch - (outliner.widest_outliner_branch - BRANCH_WIDTH_THRESHOLD)
		outliner.rect_position.x = -value
	else:
		visible = false
