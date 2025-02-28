extends PanelContainer

@onready var icon_texture = %IconTexture
@onready var name_label = %NameLabel
@onready var description_label = %DescriptionLabel

var _data: Dictionary

func new_instantiate(parent: Node, data: Dictionary) -> void:
	_data = data
	parent.add_child(self)
	icon_texture.texture = ImageTexture.create_from_image(data.get("icon", null))
	name_label.text = data.get("name")
	description_label.text = data.get("description")

func _on_details_button_pressed() -> void:
	Application.async_load_scene.emit("res://Scenes/BaseUIComponents/ContentDialog.tscn", {"title": "DETAILS_NAME", "text": _data.get("description", "--"), "awaly_exit": true})
