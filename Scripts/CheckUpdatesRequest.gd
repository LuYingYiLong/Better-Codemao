extends HTTPRequest

func _ready() -> void:
	request("https://api.github.com/repos/LuYingYiLong/Better-Codemao/issues/1")

func _on_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json_class: JSON = JSON.new()
	if json_class.parse(body.get_string_from_utf8()) != OK:
		Application.emit_system_error_message("JSON parsing failed")
		return
	var json: Dictionary = json_class.data
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	var current_version: String = ProjectSettings.get_setting("application/config/version")
	Application.latest_version = json.get("body")
	var current_version_array: PackedStringArray = current_version.split(".")
	var latest_version_array: PackedStringArray = Application.latest_version.split(".")
	if latest_version_array.size() > current_version_array.size():
		Application.has_lastest_version = true
	else:
		var index: int = 0
		for i: String in latest_version_array:
			if i.to_int() > current_version_array[index].to_int():
				Application.has_lastest_version = true
				break
			index += 1
	if !Application.has_lastest_version: return
	var content_dialog = Application.get_content_dialog()
	if !content_dialog.is_connected("callback", _content_dialog_callback): content_dialog.callback.connect(_content_dialog_callback)
	content_dialog.title = TranslationServer.translate("A_NEW_VERSION_IS_AVAILABLE_TITLE")
	content_dialog.text = TranslationServer.translate("A_NEW_VERSION_IS_AVAILABLE_DESCRIPTION").format([Application.latest_version, current_version])
	content_dialog.popup_item.clear()
	var get_updates_item: PopupItem = PopupItem.new()
	get_updates_item.text = "GET_UPDATES_NAME"
	get_updates_item.flat = true
	content_dialog.popup_item.append(get_updates_item)
	var cancel_item: PopupItem = PopupItem.new()
	cancel_item.text = "CANCEL_NAME"
	content_dialog.popup_item.append(cancel_item)
	content_dialog.show_content_dialog()

func _content_dialog_callback(index: int) -> void:
	if index == 0: Application.append_address.emit("CHECK_FOR_UPDATES_NAME", \
			"res://Scenes/Settings/SettingsMenu.tscn", \
			{"go_to": "check_for_updates"})
	var content_dialog = Application.get_content_dialog()
	content_dialog.hide_content_dialog()
	content_dialog.disconnect("callback", _content_dialog_callback)
