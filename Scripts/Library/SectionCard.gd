extends PanelContainer

@onready var button = %Button

signal pressed(work_id: int, id: int)

var work_id: int
var id: int

func set_section_card_data(data: Dictionary, type: int = 0) -> void:
	button.text = data.get("title", "--")
	id = data.get("id", 0)
	match type:
		0: work_id = data.get("fanfic_id", 0)
		1: work_id = data.get("comic_id", 0)

func _on_button_pressed() -> void:
	pressed.emit(work_id, id)
