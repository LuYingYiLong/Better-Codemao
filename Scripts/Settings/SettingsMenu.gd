extends Control

@onready var option_box_container = %OptionBoxContainer

const OPTION_BOX_SCENE = preload("res://Scenes/Settings/OptionBox.tscn")
const SEPARATOR_SCENE = preload("res://Scenes/BaseUIComponents/Separator.tscn")

var go_to: String = "root_options"

func set_data(data: Dictionary):
	if data.has("go_to"): go_to = data.get("go_to")

	for node in option_box_container.get_children():
		node.queue_free()
	var settings_options_data: Dictionary = Application.load_json_file(Application.SETTINGS_OPTIONS_DATA_PATH)
	var root_options: Array = settings_options_data.get(go_to)
	for components: Dictionary in root_options:
		var component_name: String = components.keys()[0]
		var component_data = components.get(component_name)
		match component_name:
			"option_box":
				var option_box_scene = OPTION_BOX_SCENE.instantiate()
				option_box_container.add_child(option_box_scene)
				option_box_scene.set_option_box_data(component_data)
			"separator":
				var separator_scene = SEPARATOR_SCENE.instantiate()
				option_box_container.add_child(separator_scene)
			"scene":
				var target_scene = load(component_data.get("path")).instantiate()
				option_box_container.add_child(target_scene)
