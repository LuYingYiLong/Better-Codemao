extends Button

@export_multiline var hyperlink: String

func parse_hyperlink():
	if hyperlink.begins_with("ContentDialog:"):
		var json_class: JSON = JSON.new()
		var err = json_class.parse(hyperlink.trim_prefix("ContentDialog:"))
		if err == OK:
			var json: Dictionary = json_class.data
			var content_dialog = Application.get_global_node("ContentDialog")
			if !content_dialog.is_connected("callback", _content_dialog_callback): content_dialog.callback.connect(_content_dialog_callback)
			content_dialog.load_from_json(json)
			content_dialog.show_content_dialog()
	else: OS.shell_open(hyperlink)

func _content_dialog_callback(_index: int) -> void:
	var content_dialog = Application.get_global_node("ContentDialog")
	content_dialog.hide_content_dialog()
	content_dialog.disconnect("callback", _content_dialog_callback)
