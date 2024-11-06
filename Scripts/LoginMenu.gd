extends Control

@onready var login_request = %LoginRequest
@onready var avatar_request = %AvatarRequest

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var description_label = %DescriptionLabel

@onready var identity_edit = %IdentityEdit
@onready var password_edit = %PasswordEdit
@onready var automatic_login_check = %AutomaticLoginCheck

@onready var animation_player = %AnimationPlayer

const LOGIN_DATA_JSON_PATH: String = "user://LoginData.json"

var login_data = {"pid": "65edCTyg",
	"identity": "",
	"password": ""}

var user_headers: PackedStringArray

func _ready():
	login_request.timeout = 5.0
	login_request.request_completed.connect(on_login_received)
	avatar_request.request_completed.connect(on_avatar_received)

	automatic_login_check.button_pressed = Settings.automatic_login
	if FileAccess.file_exists(LOGIN_DATA_JSON_PATH):
		login_data = Application.load_json_file(LOGIN_DATA_JSON_PATH)
		identity_edit.text = login_data.get("identity", "")
		password_edit.text = login_data.get("password", "")
	if Settings.automatic_login:
		_on_login_button_pressed()
	else:
		animation_player.play("Show")

func on_login_received(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS: push_error("Could not get data")
	if response_code == 200:
		Application.save_json_file(LOGIN_DATA_JSON_PATH, login_data)
		user_headers = headers
		Application.login_data = login_data
		var response_headers: Dictionary
		for header: String in headers:
			response_headers[header.get_slice(": ", 0)] = header.get_slice(": ", 1)
		##读取响应头
		if response_headers.has("Set-Cookie"):
			store_cookies(response_headers)
		var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
		var user_info: Dictionary = json.get("user_info")
		Application.user_id = user_info.get("id", -1)
		avatar_request.request(user_info.get("avatar_url", ""))
		if !Settings.automatic_login:
			nickname_label.text = user_info.get("nickname", "")
			description_label.text = user_info.get("description", "")
			animation_player.play("ExpansionUserDataPanel")
		else: hide()

func on_avatar_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS: push_error("无法下载图像。尝试一个不同的图像。")

	var image = Image.new()
	var error = image.load_jpg_from_buffer(body)
	if error != OK:
		push_error("无法加载图像。")

	var texture = ImageTexture.create_from_image(image)
	Application.user_avatar = texture
	avatar_texture.texture = texture
	if Settings.automatic_login: queue_free()

# 存储从 Set-Cookie 中提取的 Cookie
func store_cookies(set_cookie_headers):
	for set_cookie in set_cookie_headers:
		var cookie_parts = set_cookie_headers.get(set_cookie).split("; ")
		var name_value = cookie_parts[0].split("=")
		if name_value.size() == 2:
			var _name = name_value[0]
			var value = name_value[1]
			Application.cookies[_name] = value

func _on_visitor_login_button_pressed():
	hide()

func _on_login_button_pressed():
	login_data["identity"] = identity_edit.text
	login_data["password"] = password_edit.text
	var json = JSON.stringify(login_data)
	var headers = ["Content-Type: application/json"]
	login_request.request("https://api.codemao.cn/tiger/v3/web/accounts/login", headers, HTTPClient.METHOD_POST, json)

func _on_enter_button_pressed():
	animation_player.play("Hide")

func _on_automatic_login_check_pressed():
	Settings.automatic_login = automatic_login_check.button_pressed
	Settings.save_settings_config()
