extends HScrollBar

onready var outliner_container = get_parent().get_node("OutlinerContainer") # For speed and convenience.
onready var outliner = outliner_container.get_node("Outliner") # For speed and convenience.
const BRANCH_WIDTH_THRESHOLD = 100 # If the path to the tree item is wider than this show the horizontal scroll bar.
onready var outliner_width = outliner.rect_size.x # For speed and convenience.

const RIGHT_OFFSET_FOR_V_SCROLL_BAR = -12 # To avoid having magic numbers.

func _process(delta):
	outliner.get_node("@@34").rect_position.x = outliner_container.rect_size.x + RIGHT_OFFSET_FOR_V_SCROLL_BAR + value
	if outliner.widest_outliner_branch > BRANCH_WIDTH_THRESHOLD:
		visible = true
		max_value = outliner.widest_outliner_branch
		page = outliner.widest_outliner_branch - (outliner.widest_outliner_branch - BRANCH_WIDTH_THRESHOLD)
		outliner.rect_position.x = -value
	else:
		visible = false
