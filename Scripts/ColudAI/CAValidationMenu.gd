extends Control

@onready var ca_validation_request = %CAValidationRequest

@onready var auto_suggest_box = %AutoSuggestBox
@onready var verification_info_label = %VerificationInfoLabel
@onready var cancel_button = %CancelButton
@onready var verification_button = %VerificationButton
@onready var continue_button = %ContinueButton

@onready var animation_player = %AnimationPlayer

func _on_auto_suggest_box_search_pressed(text: String) -> void:
	ca_validation(text)

func ca_validation(ca: String) -> void:
	var request_data: Dictionary = {
		"ca": ca
	}
	ca_validation_request.request("https://ai.coludai.cn/api/ca/verify", \
			["Content-Type: application/json"], \
			HTTPClient.METHOD_POST, \
			JSON.stringify(request_data))
	auto_suggest_box.disabled = true
	verification_button.disabled = true

func _on_ca_validation_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	
	auto_suggest_box.disabled = false
	verification_button.disabled = false
	if json.get("success"):
		verification_info_label.add_theme_color_override("font_color", Color.html(GlobalTheme.system_ok_message_color))
		verification_info_label.text = TranslationServer.translate("VERIFICATION_SUCCEEDED_NAME")
		var login_data: Dictionary = Application.load_json_file(Application.LOGIN_DATA_PATH)
		var couldai: Dictionary = login_data.get("couldai", {})
		couldai["ca"] = auto_suggest_box.text
		login_data["couldai"] = couldai
		Application.save_json_file(Application.LOGIN_DATA_PATH, login_data)
	else:
		verification_info_label.add_theme_color_override("font_color", Color.html(GlobalTheme.system_error_message_color))
		verification_info_label.text = TranslationServer.translate("VERIFICATION_FAILED_NAME")
	verification_info_label.show()
	
	cancel_button.visible = !json.get("success")
	verification_button.visible = !json.get("success")
	continue_button.visible = json.get("success")

func _on_cancel_button_pressed() -> void:
	animation_player.play("Hide")

func _on_verification_button_pressed() -> void:
	ca_validation(auto_suggest_box.text)

func _on_continue_button_pressed() -> void:
	animation_player.play("Hide")
