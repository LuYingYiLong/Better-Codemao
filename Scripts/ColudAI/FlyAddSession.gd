extends Control

@onready var add_session_request = %AddSessionRequest

@onready var line_edit = %LineEdit
@onready var ok_button = %OkButton

@onready var animation_player = %AnimationPlayer

func _on_add_session_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	ok_button.disabled = false
	ColudAIUserManager.sessions_update.emit()
	animation_player.play("Hide")

func _on_cancel_button_pressed():
	animation_player.play("Hide")

func _on_ok_button_pressed():
	ok_button.disabled = true
	add_session_request.request("https://ai.coludai.cn/api/session/create", \
			["Content-Type: Application/json", ColudAIUserManager.get_cookie()], \
			HTTPClient.METHOD_POST, \
			JSON.stringify({"name": line_edit.text}))
