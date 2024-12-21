extends Node

@export_node_path() var progress_bar

@onready var http_request = %HTTPRequest

signal request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray)

@warning_ignore("int_as_enum_without_cast")
func request(url: String, custom_headers: PackedStringArray = PackedStringArray(), method: HTTPClient.Method = 0, request_data: String = ""):
	var error = http_request.request(url, custom_headers, method, request_data)
	_change_progress_bar_state(0, true)
	if error != OK:
		_change_progress_bar_state(2, true)
		return error

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	request_completed.emit(result, response_code, headers, body)
	var json = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		_change_progress_bar_state(2, true)
		return
	if json is Dictionary:
		if json.has("error_code"):
			#Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
			_change_progress_bar_state(2, true)
			return
	_change_progress_bar_state(0, false)

func _change_progress_bar_state(state: int, visible: bool) -> void:
	var progress_bar_scene = get_node(progress_bar)
	if progress_bar_scene != null:
		progress_bar_scene.progress_state = state
		progress_bar_scene.visible = visible
