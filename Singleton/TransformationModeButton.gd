extends MenuButton

func _ready():
	var parent_pos = get_parent().get_global_transform().origin # For speed and convenience.
	self.get_parent().get_global_transform().origin = parent_pos
	self.get_popup().connect("id_pressed", self, "manage_id")

func manage_id(ID):
	Global.visual_debugger.transformation_mode = ID
	self.text = "Transformation mode: " + self.get_popup().get_item_text(ID)
