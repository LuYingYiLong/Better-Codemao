extends PanelContainer

@onready var cover_texture = %CoverTexture
@onready var title_label = %TitleLabel
@onready var view_times = %ViewTimes
@onready var type_label = %TypeLabel

signal pressed(id: int)

var id: int

func set_fanfic_card_data(json: Dictionary) -> void:
	id = json.get("id")
	cover_texture.load_image(json.get("cover_pic"), json.get("title"))
	title_label.text = json.get("title")
	view_times.text = str(json.get("view_times"))
	type_label.text = json.get("fanfic_type_name")

func _on_gui_input(event) -> void:
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		pressed.emit(id)

func _on_cover_texture_pressed() -> void:
	pressed.emit(id)
