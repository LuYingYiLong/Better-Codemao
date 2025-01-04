extends PanelContainer

@onready var preview_texture = %PreviewTexture
@onready var work_name_label = %WorkNameLabel
@onready var description_label = %DescriptionLabel

var id: int

func set_work_card_data(json: Dictionary) -> void:
	id = json.get("id")
	if json.has("work_name"):
		work_name_label.text = json.get("work_name")
		preview_texture.load_image(json.get("preview"), json.get("work_name"))
	elif json.has("name"):
		work_name_label.text = json.get("name")
		preview_texture.load_image(json.get("preview"), json.get("name"))
	description_label.text = json.get("description", "")

func _on_preview_texture_pressed() -> void:
	Application.append_address.emit(work_name_label.text, \
			"res://Scenes/Work/WorkMenu.tscn", \
			{"id": id})
