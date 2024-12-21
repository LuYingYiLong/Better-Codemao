extends HTTPRequest

func _ready():
	request("https://static-games.codemao.cn/trainer/pc/res/import/98/98ebcb55-60a1-45f7-aad1-e7790639b137.1845e.json")

func _on_shielded_word_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	SensitiveWordsManager.sensitive_words = json.get("text").split("\n")
