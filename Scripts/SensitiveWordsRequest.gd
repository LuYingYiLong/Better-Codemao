extends HTTPRequest

func _ready() -> void:
	request("https://static-games.codemao.cn/trainer/pc/res/import/98/98ebcb55-60a1-45f7-aad1-e7790639b137.1845e.json")

func _on_shielded_word_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json_class: JSON = JSON.new()
	if json_class.parse(body.get_string_from_utf8()) != OK:
		Application.emit_system_error_message("JSON parsing failed")
		return
	var json: Dictionary = json_class.data
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	SensitiveWordsManager.sensitive_words = json.get("text").split("\n")
