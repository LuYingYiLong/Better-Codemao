extends Node

@export_enum("Json", "Other") var connect_type: int = 0
@export_node_path() var progress_bar

@onready var http_request = %HTTPRequest

signal request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedStringArray)

@warning_ignore("int_as_enum_without_cast")
func request(url: String, custom_headers: PackedStringArray = PackedStringArray(), method: HTTPClient.Method = 0, request_data: String = ""):
	var error = http_request.request(url, custom_headers, method, request_data)
	_change_progress_bar_state(0, true)
	if error != OK:
		_change_progress_bar_state(2, true)
		return error

@warning_ignore("int_as_enum_without_cast")
func request_raw(url: String, custom_headers: PackedStringArray = PackedStringArray(), method: HTTPClient.Method = 0, request_data_raw: PackedByteArray = PackedByteArray()):
	http_request.request_raw(url, custom_headers, method, request_data_raw)

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if connect_type == 0:
		var json_class: JSON = JSON.new()
		if json_class.parse(body.get_string_from_utf8()) != OK:
			Application.emit_system_error_message("JSON parsing failed")
			_change_progress_bar_state(2, true)
			return
		var json: Dictionary = json_class.data
		if result != HTTPRequest.RESULT_SUCCESS:
			_change_progress_bar_state(2, true)
			return
		if json.has("error_code"):
			_change_progress_bar_state(2, true)
			Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
			print(json)
			return
		_change_progress_bar_state(0, false)
		request_completed.emit(result, response_code, headers, body)
		
	elif connect_type == 1: request_completed.emit(result, response_code, headers, body)

func _change_progress_bar_state(state: int, visible: bool) -> void:
	if progress_bar != null:
		var progress_bar_scene = get_node(progress_bar)
		progress_bar_scene.progress_state = state
		progress_bar_scene.visible = visible
