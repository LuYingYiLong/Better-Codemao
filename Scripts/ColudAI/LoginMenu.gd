extends Control

@onready var sso_login_request = %SSOLoginRequest
@onready var login_request = %LoginRequest

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel

@onready var identity_edit = %IdentityEdit
@onready var password_edit = %PasswordEdit

@onready var animation_player = %AnimationPlayer

var avatar_url: String

var login_data = {
	"user_name": "",
	"password": ""
	}

var user_headers: PackedStringArray

func _on_sso_login_request_request_completed(_result: int, _response_code: int, headers: PackedStringArray, _body: PackedByteArray):
	var cookie: String = Application.store_cookies_from_headers(headers)
	if cookie.is_empty(): return
	ColudAIUserManager.save_cookie(cookie)
	var payload = "username=" + login_data.get("user_name") + "&md5Password=" + login_data.get("password")
	login_request.request("https://email.coludai.cn/email/login", \
			["Content-Type: application/x-www-form-urlencoded"], \
			HTTPClient.METHOD_POST, \
			payload)

func on_login_received(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	ColudAIUserManager.save_login_data(login_data)
	ColudAIUserManager.save_user_data(json)
	avatar_texture.load_image(json.get("data", {}).get("fields", {}).get("头像", {}).get("title", ""))
	nickname_label.text = json.get("data", {}).get("fields", {}).get("用户名", "ERROR")
	animation_player.play("HideLoginMenu")
	await animation_player.animation_finished
	animation_player.play("ShowWelcomeMenu")

func _on_visitor_login_button_pressed():
	animation_player.play("HideLoginMenu")

func _on_login_button_pressed():
	login_data["user_name"] = identity_edit.text
	login_data["password"] = password_edit.text.md5_text()
	sso_login_request.request("https://sso.coludai.cn/api/sso/login", \
			[], \
			HTTPClient.METHOD_POST, \
			JSON.stringify({"username": login_data.get("user_name"), "md5password": login_data.get("password")}))

func _on_enter_button_pressed():
	animation_player.play("HideWelcomeMenu")
