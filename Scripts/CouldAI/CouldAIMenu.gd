extends Control

@onready var chat_request = %ChatRequest
@onready var add_session_request = %AddSessionRequest
@onready var query_session_request = %QuerySessionRequest

@onready var secure_text_edit = %SecureTextEdit
@onready var chat_bubble_container = %ChatBubbleContainer

@onready var sessions_container = %SessionsContainer

const MAX_SESSIONS: int = 1
const COULDAI_TEXTURE: Texture = preload("res://Resources/Textures/COLUDAI.svg")
const CHAT_BUBBLE_SCENE = preload("res://Scenes/BaseUIComponents/ChatBubble.tscn")
const BASE_BUTTON_SCENE = preload("res://Scenes/BaseUIComponents/BaseButton.tscn")

var token: String
var session_id: String
var session_name: String

func _ready():
	SessionManager.sessions_update.connect(populate_sessions)
	secure_text_edit.set_reply(0, 0, "CouldAI")
	populate_sessions(SessionManager.get_sessions())

func populate_sessions(sessions: Array) -> void:
	var current_session: Dictionary = SessionManager.get_current_session()
	for session: Dictionary in sessions:
		var base_button_scene = BASE_BUTTON_SCENE.instantiate()
		sessions_container.add_child(base_button_scene)
		base_button_scene.add_to_group("Sessions")
		base_button_scene.text = session.get("name")
		base_button_scene.group = "Sessions"
		if session.get("id") == current_session.get("id", ""):
			base_button_scene.selected = true
			query_session_request.request("https://ai.coludai.cn/api/session/query", \
					["Content-Type: Application/json"], \
					HTTPClient.METHOD_POST, \
					JSON.stringify({"sessionid": session.get("id")}))

func _on_ca_validation_button_pressed():
	Application.async_load_scene.emit("res://Scenes/CouldAI/CAValidationMenu.tscn", {})

func _on_secure_text_edit_reply(_reply_id: int, _parent_id: int, text: String) -> void:
	secure_text_edit.clear()
	secure_text_edit.set_reply(0, 0, "CouldAI")
	
	var chat_bubble_scene = CHAT_BUBBLE_SCENE.instantiate()
	chat_bubble_container.add_child(chat_bubble_scene)
	chat_bubble_scene.avatar = Application.user_avatar
	chat_bubble_scene.content = text
	
	if token.is_empty(): token = generate_token(text)
	var headers: PackedStringArray = ["Content-Type: Application/json"]
	var login_data: Dictionary = Application.load_json_file(Application.LOGIN_DATA_PATH)
	var couldai: Dictionary = login_data.get("couldai", {})
	if couldai.has("ca"): headers.append("ca: %s" %couldai.get("ca"))
	else:
		Application.async_load_scene.emit("res://Scenes/CouldAI/CAValidationMenu.tscn", {})
		return
	var request_data: Dictionary = {
		"prompt": text, 
		"token": token,
		"stream": false
	}
	# 如果当前没有会话就创建一个
	if SessionManager.get_current_session().is_empty(): add_session(text)
	else: request_data["sessionid"] = SessionManager.get_current_session().get("id")
	chat_request.request("https://ai.coludai.cn/api/chat", headers, HTTPClient.METHOD_POST, JSON.stringify(request_data))

func _on_chat_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var chat_bubble_scene = CHAT_BUBBLE_SCENE.instantiate()
	chat_bubble_container.add_child(chat_bubble_scene)
	chat_bubble_scene.who = 1
	chat_bubble_scene.avatar = COULDAI_TEXTURE
	
	var json_class: JSON = JSON.new()
	var result = json_class.parse(body.get_string_from_utf8())
	if result == OK:
		var json: Dictionary = json_class.data
		chat_bubble_scene.content = json.get("output", "")
	else:
		chat_bubble_scene.content = body.get_string_from_utf8()

# 添加新会话
func add_session(new_session_name: String) -> void:
	if SessionManager.get_sessions().size() >= MAX_SESSIONS: return
	session_name = new_session_name
	add_session_request.request("https://ai.coludai.cn/api/session/create", \
			["Content-Type: Application/json"], \
			HTTPClient.METHOD_POST, \
			JSON.stringify({"name": session_name}))

func _on_add_session_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	session_id = json.get("sessionid", "")
	if session_id.is_empty(): return
	var session_index: int = SessionManager.add_session(session_id, session_name)
	SessionManager.set_current_session(session_index)
	var base_button_scene = BASE_BUTTON_SCENE.instantiate()
	sessions_container.add_child(base_button_scene)
	base_button_scene.add_to_group("Sessions")
	base_button_scene.text = session_name
	base_button_scene.group = "Sessions"
	base_button_scene.selected = true

func _on_query_session_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var items: Array = json.get("array", [])
	for item: Dictionary in items:
		print(item)

func generate_token(text: String) -> String:
	var time_dict: Dictionary = Time.get_date_dict_from_system()
	if time_dict.get("month") < 10: time_dict["month"] = "0" + str(time_dict.get("month"))
	if time_dict.get("day") < 10: time_dict["day"] = "0" + str(time_dict.get("day"))
	var md5_current_time: String = "%s-%s-%s" %[
		time_dict.get("year"), 
		time_dict.get("month"), 
		time_dict.get("day")
	]
	md5_current_time = md5_current_time.md5_text()
	text = "%s%s%s%s%s%s%s" %[
		text, 
		md5_current_time[0],
		md5_current_time[1],
		md5_current_time[2],
		md5_current_time[3],
		md5_current_time[4],
		md5_current_time[5]
	]
	return text.md5_text()

func _on_manage_sessions_button_pressed() -> void:
	Application.async_load_scene.emit("res://Scenes/CouldAI/FlayManageSessions.tscn", {})

func _on_new_conversation_button_pressed() -> void:
	if SessionManager.get_sessions().size() >= MAX_SESSIONS:
		var content_dialog: Control = Application.get_global_node("ContentDialog")
		if !content_dialog.is_connected("callback", _content_dialog_callback): content_dialog.callback.connect(_content_dialog_callback)
		content_dialog.load_from_json({"title": "WARNING_NAME", "text": TranslationServer.translate("MAXIMUM_SESSION_WARNING").format([MAX_SESSIONS])})
		content_dialog.show_content_dialog()

func _content_dialog_callback(_index: int) -> void:
	var content_dialog = Application.get_global_node("ContentDialog")
	content_dialog.hide_content_dialog()
	content_dialog.disconnect("callback", _content_dialog_callback)
