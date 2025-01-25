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

var avatar_url: String

var login_data = {"pid": "65edCTyg",
	"identity": "",
	"password": ""}

var user_headers: PackedStringArray

func _ready():
	automatic_login_check.button_pressed = Settings.automatic_login
	Application.show_login_menu.connect(show_login_menu)
	if FileAccess.file_exists(LOGIN_DATA_JSON_PATH):
		login_data = Application.load_json_file(LOGIN_DATA_JSON_PATH)
		identity_edit.text = login_data.get("identity", "")
		password_edit.text = login_data.get("password", "")
	if Settings.automatic_login: _on_login_button_pressed()
	else: show_login_menu()

func show_login_menu():
	automatic_login_check.button_pressed = Settings.automatic_login
	animation_player.play("ShowLoginMenu")

func on_login_received(_result: int, _response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())

	if !Settings.automatic_login: login_data.erase("password")
	Application.save_json_file(LOGIN_DATA_JSON_PATH, login_data)
	user_headers = headers
	Application.login_data = login_data
	Application.logged_in = true
	var response_headers: Dictionary
	for header: String in headers:
		response_headers[header.get_slice(": ", 0)] = header.get_slice(": ", 1)

	# 读取响应头
	if response_headers.has("Set-Cookie"):
		store_cookies(response_headers)

	var user_info: Dictionary = json.get("user_info")
	Settings.save_settings_config()
	Application.user_id = user_info.get("id", -1)
	avatar_url = user_info.get("avatar_url", "")
	avatar_texture.load_image(avatar_url)
	avatar_request.request(avatar_url)
	if !Settings.automatic_login:
		nickname_label.text = user_info.get("nickname", "")
		Application.user_name = user_info.get("nickname", "")
		description_label.text = user_info.get("description", "")
		animation_player.play("HideLoginMenu")
		await animation_player.animation_finished
		animation_player.play("ShowWelcomeMenu")
	else: hide()
	
	# 如果没有UserData则创建一个
	if !FileAccess.file_exists(ProjectSettings.globalize_path("user://UserData.json")):
		var user_data: Dictionary = {
			"nickname": user_info.get("nickname", ""),
			"description": user_info.get("description", ""),
			"version": ProjectSettings.get_setting("application/config/version"),
			"user_agreement": true
			}
		Application.save_json_file("user://UserData.json", user_data)
	# 检查 user_data 的 version 键对值是否对应本产品版本和 user_agreement 是否已同意
	else:
		var user_data: Dictionary = Application.load_json_file(Application.USER_DATA_PATH)
		if user_data.get("version", "") != ProjectSettings.get_setting("application/config/version") or \
				user_data.get("user_agreement", false) == false:
			Application.async_load_scene.emit("res://Scenes/InitConfigMenu.tscn", {
				"user_agreement": TranslationServer.translate("USER_AGREEMENT_DESCRIPTION")
				})

func _on_avatar_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS: return
	var image = Image.new()
	var error
	if avatar_url.ends_with(".jpeg") or avatar_url.ends_with(".jpg"):
		error = image.load_jpg_from_buffer(body)
	elif avatar_url.ends_with(".png"):
		error = image.load_png_from_buffer(body)
		if error != OK: return

	if error != OK: return
	image.save_png("user://UserAvatar.png")
	Application.user_avatar = ImageTexture.create_from_image(image)

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
	animation_player.play("HideLoginMenu")

func _on_login_button_pressed():
	login_data["identity"] = identity_edit.text
	login_data["password"] = password_edit.text
	var json = JSON.stringify(login_data)
	var headers = ["Content-Type: application/json"]
	login_request.request("https://api.codemao.cn/tiger/v3/web/accounts/login", headers, HTTPClient.METHOD_POST, json)

func _on_enter_button_pressed():
	animation_player.play("HideWelcomeMenu")

func _on_automatic_login_check_pressed():
	Settings.automatic_login = automatic_login_check.button_pressed
