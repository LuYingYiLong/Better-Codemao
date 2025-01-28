extends Control

@onready var chat_request = %ChatRequest
@onready var secure_text_edit = %SecureTextEdit
@onready var chat_bubble_container = %ChatBubbleContainer

const COULDAI_TEXTURE: Texture = preload("res://Resources/Textures/COLUDAI.svg")
const CHAT_BUBBLE_SCENE = preload("res://Scenes/BaseUIComponents/ChatBubble.tscn")

var token: String

func _ready():
	secure_text_edit.set_reply(0, 0, "CouldAI")

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
