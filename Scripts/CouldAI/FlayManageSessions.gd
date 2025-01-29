extends Control

@onready var delete_session_request = %DeleteSessionRequest

@onready var session_id_card_container = %SessionIDCardContainer

@onready var animation_player = %AnimationPlayer

const SESSION_ID_CARD_SCENE = preload("res://Scenes/CouldAI/SessionIDCard.tscn")

var delete_sessions: Array

func _ready() -> void:
	populate_sessions()

func populate_sessions() -> void:
	var sessions: Array = SessionManager.get_sessions()
	for node in session_id_card_container.get_children():
		node.queue_free()
	for session: Dictionary in sessions:
		var session_id_card_scene = SESSION_ID_CARD_SCENE.instantiate()
		session_id_card_container.add_child(session_id_card_scene)
		session_id_card_scene.session_id = session.get("id", "")
		session_id_card_scene.session_name = session.get("name", "")

func _on_delete_session_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	print(body.get_string_from_utf8())
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null: return
	if json.get("message") == "ok": SessionManager.remove_session(delete_sessions.pop_back())
	if !delete_sessions.is_empty():
		delete_session_request.request("https://ai.coludai.cn/api/session/delete", \
				["Content-Type: Application/json"], \
				HTTPClient.METHOD_POST, \
				JSON.stringify({"sessionid": delete_sessions[delete_sessions.size() - 1]}))
		populate_sessions()
	else: animation_player.play("Hide")

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
