@tool
extends PanelContainer

@export_enum("Acrylic") var style: int = 0:
	set(value):
		style = value

@export_group("Corner Radius")
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var top_left: int = 8:
	set(value):
		top_left = value
		_set_corner_radius_top_left(top_left)
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var top_right: int = 8:
	set(value):
		top_right = value
		_set_corner_radius_top_right(top_right)
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var bottom_right: int = 8:
	set(value):
		bottom_right = value
		_set_corner_radius_bottom_right(bottom_right)
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var bottom_left: int = 8:
	set(value):
		bottom_left = value
		_set_corner_radius_bottom_left(bottom_left)

@export_group("")
@export_node_path("PanelContainer") var blur

func update_style() -> void:
	_set_corner_radius_top_left(top_left)
	_set_corner_radius_top_right(top_right)
	_set_corner_radius_bottom_right(bottom_right)
	_set_corner_radius_bottom_left(bottom_left)

func _set_corner_radius_top_left(_top_left: int) -> void:
	var stylebox: StyleBoxFlat = get_theme_stylebox("panel")
	var blur_node := get_node(blur)
	var blur_stylebox: StyleBoxFlat = blur_node.get_theme_stylebox("panel")
	stylebox.corner_radius_top_left = _top_left
	blur_stylebox.corner_radius_top_left = _top_left
	add_theme_stylebox_override("panel", stylebox)

func _set_corner_radius_top_right(_top_right: int) -> void:
	var stylebox: StyleBoxFlat = get_theme_stylebox("panel")
	var blur_node := get_node(blur)
	var blur_stylebox: StyleBoxFlat = blur_node.get_theme_stylebox("panel")
	stylebox.corner_radius_top_right = _top_right
	blur_stylebox.corner_radius_top_right = _top_right
	add_theme_stylebox_override("panel", stylebox)

func _set_corner_radius_bottom_right(_bottom_right: int) -> void:
	var stylebox: StyleBoxFlat = get_theme_stylebox("panel")
	var blur_node := get_node(blur)
	var blur_stylebox: StyleBoxFlat = blur_node.get_theme_stylebox("panel")
	stylebox.corner_radius_bottom_right = _bottom_right
	blur_stylebox.corner_radius_bottom_right = _bottom_right
	add_theme_stylebox_override("panel", stylebox)

func _set_corner_radius_bottom_left(_bottom_left: int) -> void:
	var stylebox: StyleBoxFlat = get_theme_stylebox("panel")
	var blur_node := get_node(blur)
	var blur_stylebox: StyleBoxFlat = blur_node.get_theme_stylebox("panel")
	stylebox.corner_radius_bottom_left = _bottom_left
	blur_stylebox.corner_radius_bottom_left = _bottom_left
	add_theme_stylebox_override("panel", stylebox)

func _on_tree_entered():
	update_style()
