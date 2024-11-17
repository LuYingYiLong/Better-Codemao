extends Control

@onready var option_box_container = %OptionBoxContainer

const OPTION_BOX_SCENE = preload("res://Scenes/Settings/OptionBox.tscn")

var go_to: String = "root_options"

func set_data(data: Dictionary):
	if data.has("go_to"): go_to = data.get("go_to")

	for node in option_box_container.get_children():
		node.queue_free()
	var settings_options_data: Dictionary = Application.load_json_file(Application.SETTINGS_OPTIONS_DATA_PATH)
	var root_options: Array = settings_options_data.get(go_to)
	for option_data: Dictionary in root_options:
		var option_box_scene = OPTION_BOX_SCENE.instantiate()
		option_box_container.add_child(option_box_scene)
		option_box_scene.set_option_box_data(option_data)
