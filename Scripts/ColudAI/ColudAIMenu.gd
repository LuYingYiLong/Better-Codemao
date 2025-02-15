extends Control

@onready var sessions_request = %SessionsRequest
@onready var query_session_request = %QuerySessionRequest

@onready var combo_box = %ComboBox
@onready var login_button = %LoginButton
@onready var open_in_new_window_button = %OpenInNewWindowButton
@onready var pin_button = %PinButton
@onready var unpin_button = %UnpinButton
@onready var secure_text_edit = %SecureTextEdit
@onready var chat_bubble_container = %ChatBubbleContainer

@onready var default_session_button = %DefaultSessionButton
@onready var sessions_container = %SessionsContainer

@onready var timer = %Timer

const MAX_SESSIONS: int = 10
const COLUDAI_AVATAR: Texture = preload("res://Resources/Textures/COLUDAI.svg")
const CHAT_BUBBLE_SCENE = preload("res://Scenes/BaseUIComponents/ChatBubble.tscn")
const BASE_BUTTON_SCENE = preload("res://Scenes/BaseUIComponents/BaseButton.tscn")

signal pin
signal unpin

var chat_client: HTTPClient = HTTPClient.new()
var honst: String
var url: String
var headers: PackedStringArray
var request_data: Dictionary
var streaming: bool
var is_reasoner: bool
var elapsed_time: int
var body_chunk: String
var chat_bubble_index: int

var logged_in: bool
var session_id: String:
	set(value):
		session_id = value
		if session_id.is_empty():
			for node in chat_bubble_container.get_children():
				node.queue_free()
		else:
			query_session_request.request("https://ai.coludai.cn/api/session/query", \
				["Content-Type: Application/json"], \
				HTTPClient.METHOD_POST, \
				JSON.stringify({"sessionid": session_id}))
var session_name: String

func _ready():
	ColudAIUserManager.user_data_update.connect(_on_user_data_update)
	ColudAIUserManager.sessions_update.connect(_on_sessions_update)
	ColudAIUserManager.sign_status_update.connect(_on_sign_status_update)
	secure_text_edit.set_ai_chat("ColudAI")
	default_session_button.metadata = ""
	var user_data: Dictionary = ColudAIUserManager.get_user_data()
	logged_in = !user_data.is_empty()
	if logged_in:
		login_button.text = user_data.get("data").get("fields").get("用户名")
		sessions_request.request("https://ai.coludai.cn/api/user/sessions?", \
				[ColudAIUserManager.get_cookie()], \
				HTTPClient.METHOD_GET)

func set_data(data: Dictionary) -> void:
	open_in_new_window_button.visible = !data.get("in_new_window", false)
	pin_button.visible = data.get("in_new_window", false)

func _on_user_data_update(new_user_data: Dictionary) -> void:
	logged_in = !new_user_data.is_empty()
	if logged_in:
		login_button.text = new_user_data.get("data").get("fields").get("用户名")
		sessions_request.request("https://ai.coludai.cn/api/user/sessions?", \
					[ColudAIUserManager.get_cookie()], \
					HTTPClient.METHOD_GET)
	else:
		login_button.text = "LOGIN_NAME"

func _on_sessions_update() -> void:
	sessions_request.request("https://ai.coludai.cn/api/user/sessions?", \
			[ColudAIUserManager.get_cookie()], \
			HTTPClient.METHOD_GET)

func _on_sign_status_update() -> void:
	logged_in = false
	login_button.text = "LOGIN_NAME"

func _on_login_button_pressed() -> void:
	if logged_in: Application.async_load_scene.emit("res://Scenes/ColudAI/FlyUserDetails.tscn", {})
	else: Application.async_load_scene.emit("res://Scenes/ColudAI/LoginMenu.tscn", {})

func _on_ca_validation_button_pressed() -> void:
	Application.async_load_scene.emit("res://Scenes/ColudAI/CAValidationMenu.tscn", {})

func _on_open_in_new_window_button_pressed() -> void:
	Application.async_load_scene.emit("res://Scenes/ColudAI/ColudAIWindow.tscn", {"size": size})

func _on_pin_button_pressed() -> void:
	pin_button.hide()
	unpin_button.show()
	pin.emit()

func _on_unpin_button_pressed() -> void:
	pin_button.show()
	unpin_button.hide()
	unpin.emit()

func _on_secure_text_edit_ai_chat(text: String) -> void:
	if streaming: return
	
	secure_text_edit.clear()
	secure_text_edit.set_ai_chat("ColudAI")
	
	var chat_bubble_scene = CHAT_BUBBLE_SCENE.instantiate()
	chat_bubble_container.add_child(chat_bubble_scene)
	chat_bubble_scene.avatar = Application.user_avatar
	chat_bubble_scene.content = text
	
	match combo_box.selected:
		0:
			honst = "https://ai.coludai.cn"
			url = "/api/chat"
		1:
			honst = "https://ai.coludai.cn"
			url = "/api/chat/coder"
		2:
			honst = "https://reasoner.coludai.cn"
			url = "/api/illation"
	is_reasoner = combo_box.selected == 2
	
	headers.clear()
	headers.append("Content-Type: application/json")
	headers.append("ca: %s" %ColudAIUserManager.get_ca())
	
	request_data = {
		"prompt": text, 
		"token": generate_token(text),
		"sessionid": session_id,
		"stream": true
	}
	
	body_chunk = ""
	elapsed_time = 0
	
	var error = chat_client.connect_to_host(honst, 443)
	if error != OK:
		Application.emit_system_error_message("Failed to connect to host")
		return
	chat_bubble_index = add_chat_bubble(1, COLUDAI_AVATAR, "Connecting to the host")
	streaming = true

func _process(_delta: float) -> void:
	if streaming:
		chat_client.poll()
		var chat_bubble = chat_bubble_container.get_child(chat_bubble_index)
		match chat_client.get_status():
			HTTPClient.STATUS_CONNECTED:
				if request_data.is_empty():
					streaming = false
					if is_reasoner: timer.stop()
					chat_bubble.reasoning_time = elapsed_time
					elapsed_time = 0
				else:
					chat_client.request_raw(HTTPClient.METHOD_POST, url, headers, JSON.stringify(request_data).to_utf8_buffer())
					chat_bubble.content = "Requesting"
					request_data.clear()
					if is_reasoner: timer.start()
			HTTPClient.STATUS_BODY:
				var chunk = chat_client.read_response_body_chunk()
				if chunk.size() > 0:
					body_chunk += chunk.get_string_from_utf8()
					var string_array: PackedStringArray = body_chunk.split("\n")
					if string_array[string_array.size() - 1].is_empty(): string_array.remove_at(string_array.size() - 1)
					var output: String = string_array[string_array.size() - 1]
					var json_class: JSON = JSON.new()
					var result = json_class.parse(output)
					if result == OK:
						var json: Dictionary = json_class.data
						chat_bubble.content = Application.decode_unicode(json.get("output", ""))
						chat_bubble.think = Application.decode_unicode(json.get("Thinking", ""))
						if json.has("error"): chat_bubble.content = "Error: %s" %json.get("error")
			HTTPClient.STATUS_DISCONNECTED:
				chat_bubble.content = "Disconnected from server"
				streaming = false
			HTTPClient.STATUS_CANT_CONNECT, HTTPClient.STATUS_CANT_RESOLVE:
				chat_bubble.content = "Failed to connect to server"
				streaming = false

# 添加新气泡
func add_chat_bubble(who: int, avatar: Texture, content: String) -> int:
	var chat_bubble_scene = CHAT_BUBBLE_SCENE.instantiate()
	chat_bubble_container.add_child(chat_bubble_scene)
	chat_bubble_scene.who = who
	chat_bubble_scene.avatar = avatar
	chat_bubble_scene.content = content
	return chat_bubble_scene.get_index()

func _on_sessions_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json_class = JSON.new()
	var result = json_class.parse(body.get_string_from_utf8())
	if result == OK:
		var json: Dictionary = JSON.parse_string('{"array":%s}'  %body.get_string_from_utf8())
		if not json.get("array") is Array: return
		var items: Array = json.get("array", [])
		var count: int = 0
		for node in sessions_container.get_children():
			if count > 0: node.queue_free()
			count += 1
		for item: Dictionary in items:
			var base_button_scene = BASE_BUTTON_SCENE.instantiate()
			sessions_container.add_child(base_button_scene)
			base_button_scene.add_to_group("Sessions")
			base_button_scene.text = item.get("name", "ERROR")
			base_button_scene.metadata = item.get("sessionid", "")
			base_button_scene.group = "Sessions"
			base_button_scene.last_tab = default_session_button.get_index()
			base_button_scene.last_tab_scene = default_session_button
			base_button_scene.metadata_output.connect(_on_session_button_metadata_output)
	else:
		ColudAIUserManager.sign_out()

func _on_session_button_metadata_output(metadata: String) -> void:
	session_id = metadata

func _on_query_session_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var items: Array = json.get("array", [])
	for node in chat_bubble_container.get_children():
		node.queue_free()
	for item: Dictionary in items:
		if item.get("role", "") == "user": add_chat_bubble(0, Application.user_avatar, str(item.get("content")))
		elif item.get("role", "") == "assistant": add_chat_bubble(1, COLUDAI_AVATAR, str(item.get("content")))

# 构建token
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
	Application.async_load_scene.emit("res://Scenes/ColudAI/FlyManageSessions.tscn", {})

func _on_new_conversation_button_pressed() -> void:
	if sessions_container.get_child_count() - 1 >= MAX_SESSIONS:
		var content_dialog: Control = Application.get_global_node("ContentDialog")
		if !content_dialog.is_connected("callback", _content_dialog_callback): content_dialog.callback.connect(_content_dialog_callback)
		content_dialog.load_from_json({"title": "WARNING_NAME", "text": TranslationServer.translate("MAXIMUM_SESSION_WARNING").format([MAX_SESSIONS])})
		content_dialog.show_content_dialog()
	else:
		Application.async_load_scene.emit("res://Scenes/ColudAI/FlyAddSession.tscn", {})

func _content_dialog_callback(_index: int) -> void:
	var content_dialog = Application.get_global_node("ContentDialog")
	content_dialog.hide_content_dialog()
	content_dialog.disconnect("callback", _content_dialog_callback)

func _on_timer_timeout() -> void:
	elapsed_time += 1
