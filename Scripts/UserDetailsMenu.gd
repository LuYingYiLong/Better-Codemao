extends Control

@onready var details_request = %DetailsRequest

@onready var avatar_texture = %AvatarTexture
@onready var nickname_edit = %NicknameEdit
@onready var description_edit = %DescriptionEdit
@onready var id = %ID
@onready var sex = %Sex

@onready var real_name_edit = %RealNameEdit
@onready var year_edit = %YearEdit
@onready var month_edit = %MonthEdit
@onready var day_edit = %DayEdit
@onready var create_time = %CreateTime

@onready var has_password = %HasPassword
@onready var phone_number = %PhoneNumber

@onready var has_bound_qq = %HasBoundQQ
@onready var has_bound_wechat = %HasBoundWechat

@onready var gold = %Gold
@onready var has_signed = %HasSigned
@onready var voice_forbidden = %VoiceForbidden

func _ready() -> void:
	details_request.request_completed.connect(on_details_received)
	details_request.request("https://api.codemao.cn/web/users/details", \
			[Application.generate_cookie_header()], HTTPClient.METHOD_GET)
	Settings.update_theme()

func on_details_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS: push_error("Could not get data")
	avatar_texture.texture = Application.user_avatar
	nickname_edit.text = json.get("nickname")
	description_edit.text = json.get("description")
	id.text = json.get("id")
	sex.text = TranslationServer.translate("%s_NAME" %json.get("sex"))

	real_name_edit.text = json.get("real_name")
	var birthday_dict: Dictionary = Time.get_date_dict_from_unix_time(json.get("birthday"))
	year_edit.text = str(birthday_dict.get("year"))
	month_edit.text = str(birthday_dict.get("month"))
	day_edit.text = str(birthday_dict.get("day"))
	var create_time_dict: Dictionary = Time.get_datetime_dict_from_unix_time(json.get("create_time"))
	create_time.text = "%s%s%s%s%s%s  %s:%s:%s" %[create_time_dict.get("year"), \
			TranslationServer.translate("YEAR_NAME"), \
			create_time_dict.get("month"), \
			TranslationServer.translate("MONTH_NAME"), \
			create_time_dict.get("day"), \
			TranslationServer.translate("DAY_NAME1"), \
			create_time_dict.get("hour"), \
			create_time_dict.get("minute"), \
			create_time_dict.get("second")
			]

	if json.get("has_password"): has_password.text = TranslationServer.translate("ITS_SET_NAME")
	else: has_password.text = TranslationServer.translate("NOT_SET_NAME")
	phone_number.text = json.get("phone_number")

	var oauths: Array = json.get("oauths")
	for oauth: Dictionary in oauths:
		if oauth.get("name") == "qq":
			if oauth.get("is_bound"): has_bound_qq.text = TranslationServer.translate("BOUND_NAME")
			else: has_bound_qq.text = TranslationServer.translate("UNBOUND_NAME")
		if oauth.get("name") == "wechat":
			if oauth.get("is_bound"): has_bound_wechat.text = TranslationServer.translate("BOUND_NAME")
			else: has_bound_wechat.text = TranslationServer.translate("UNBOUND_NAME")

	gold.text = str(json.get("gold"))
	has_signed.text = TranslationServer.translate(("%s_NAME" %json.get("has_signed")).to_upper())
	voice_forbidden.text = TranslationServer.translate(("%s_NAME" %json.get("voice_forbidden")).to_upper())

func _on_copy_id_button_pressed() -> void:
	DisplayServer.clipboard_set(id.text)

func _on_copy_create_time_button_pressed() -> void:
	DisplayServer.clipboard_set(create_time.text)
