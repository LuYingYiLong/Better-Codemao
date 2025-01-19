extends PanelContainer

@onready var button = %Button

signal pressed(fanfic_id: int, id: int)

var fanfic_id: int
var id: int

func set_section_card_data(data: Dictionary) -> void:
	button.text = data.get("title", "--")
	fanfic_id = data.get("fanfic_id", 0)
	id = data.get("id", 0)

func _on_button_pressed() -> void:
	pressed.emit(fanfic_id, id)
