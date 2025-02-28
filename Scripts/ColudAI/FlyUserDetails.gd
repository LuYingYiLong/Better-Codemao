extends Control

@onready var query_prompt_request = %QueryPromptRequest
@onready var set_prompt_request = %SetPromptRequest

@onready var user_nmae_label = %UserNmaeLabel
@onready var email_edit = %EmailEdit
@onready var ca_edit = %CAEdit
@onready var ca_validation_button = %CAValidationButton
@onready var copy_button = %CopyButton
@onready var show_button = %ShowButton
@onready var hide_button = %HideButton
@onready var prompt_words_edit = %PromptWordsEdit
@onready var change_prompt_words_button = %ChangePromptWordsButton

@onready var animation_player = %AnimationPlayer

var last_prompt_words: String

func _ready() -> void:
	ColudAIUserManager.ca_update.connect(_on_ca_update)
	var user_data: Dictionary = ColudAIUserManager.get_user_data()
	var data: Dictionary = user_data.get("data", {})
	var fields: Dictionary = data.get("fields", {})
	user_nmae_label.text = fields.get("用户名", "ERROR")
	email_edit.text = fields.get("邮箱", "https://example.com")
	ca_edit.text = ColudAIUserManager.get_ca()
	ca_edit.visible = !ColudAIUserManager.get_ca().is_empty()
	ca_validation_button.visible = ColudAIUserManager.get_ca().is_empty()
	copy_button.visible = !ColudAIUserManager.get_ca().is_empty()
	show_button.visible = !ColudAIUserManager.get_ca().is_empty()
	last_prompt_words = prompt_words_edit.text
	query_prompt_request.request("https://ai.coludai.cn/api/ca/query?", \
			[ColudAIUserManager.get_cookie()], \
			HTTPClient.METHOD_GET)

func _on_ca_validation_button_pressed() -> void:
	Application.async_load_scene.emit("res://Scenes/ColudAI/FlyUserDetails.tscn", {})

func _on_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(ca_edit.text)

func _on_show_button_pressed() -> void:
	ca_edit.secret = false
	show_button.hide()
	hide_button.show()

func _on_hide_button_pressed() -> void:
	ca_edit.secret = true
	show_button.show()
	hide_button.hide()

func _on_ca_update(new_ca: String) -> void:
	ca_edit.text = new_ca

func _on_prompt_words_edit_text_changed() -> void:
	change_prompt_words_button.disabled = prompt_words_edit.text == last_prompt_words

func _on_change_prompt_words_button_pressed() -> void:
	set_prompt_request.request("https://ai.coludai.cn/api/ca/setprompt", \
			[ColudAIUserManager.get_cookie()], \
			HTTPClient.METHOD_POST, \
			JSON.stringify({"prompt": prompt_words_edit.text}))
	prompt_words_edit.editable = false
	change_prompt_words_button.disabled = true

func _on_query_prompt_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	last_prompt_words = json.get("prompt", "")
	prompt_words_edit.text = json.get("prompt", "")
	prompt_words_edit.editable = true

func _on_set_prompt_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	prompt_words_edit.editable = true
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if json.has("prompt"): last_prompt_words = json.get("prompt")
	else: change_prompt_words_button.disabled = false

func _on_cancel_button_pressed():
	animation_player.play("Hide")

func _on_sign_out_button_pressed() -> void:
	ColudAIUserManager.sign_out()
	animation_player.play("Hide")

func _on_ok_button_pressed() -> void:
	animation_player.play("Hide")
