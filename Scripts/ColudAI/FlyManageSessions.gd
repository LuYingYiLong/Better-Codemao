extends Control

@onready var sessions_request = %SessionsRequest
@onready var delete_session_request = %DeleteSessionRequest

@onready var session_id_card_container = %SessionIDCardContainer

@onready var animation_player = %AnimationPlayer

const SESSION_ID_CARD_SCENE = preload("res://Scenes/ColudAI/SessionIDCard.tscn")

var delete_sessions: Array

func _ready() -> void:
	sessions_request.request("https://ai.coludai.cn/api/user/sessions?", \
			[ColudAIUserManager.get_cookie()], \
			HTTPClient.METHOD_GET)

func _on_query_session_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	populate_sessions(json.get("array", []))

func populate_sessions(sessions: Array) -> void:
	for node in session_id_card_container.get_children():
		node.queue_free()
	for session: Dictionary in sessions:
		var session_id_card_scene = SESSION_ID_CARD_SCENE.instantiate()
		session_id_card_container.add_child(session_id_card_scene)
		session_id_card_scene.session_id = session.get("sessionid", "")
		session_id_card_scene.session_name = session.get("name", "ERROR")

func _on_delete_session_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null: return
	if json.get("message") == "ok": delete_sessions.resize(delete_sessions.size() - 1)
	if !delete_sessions.is_empty():
		delete_session_request.request("https://ai.coludai.cn/api/session/delete", \
				["Content-Type: Application/json"], \
				HTTPClient.METHOD_POST, \
				JSON.stringify({"sessionid": delete_sessions[delete_sessions.size() - 1]}))
	else:
		ColudAIUserManager.sessions_update.emit()
		animation_player.play("Hide")

func _on_cancel_button_pressed() -> void:
	animation_player.play("Hide")

func _on_ok_button_pressed() -> void:
	for node: PanelContainer in session_id_card_container.get_children():
		if node.delete: delete_sessions.append(node.session_id)
	if !delete_sessions.is_empty(): delete_session_request.request("https://ai.coludai.cn/api/session/delete", \
				["Content-Type: Application/json"], \
				HTTPClient.METHOD_POST, \
				JSON.stringify({"sessionid": delete_sessions[delete_sessions.size() - 1]}))
	else: animation_player.play("Hide")
