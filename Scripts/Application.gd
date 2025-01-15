extends Control

signal user_avatar_update

@warning_ignore("unused_signal")
signal append_address(address_name: String, scene_path: String, data: Dictionary)
@warning_ignore("unused_signal")
signal set_root_address(address_name: String, scene_path: String, data: Dictionary)

@warning_ignore("unused_signal")
signal show_login_menu

signal add_system_message(message: String, color: String, time: float)

const USER_DATA_PATH = "user://UserData.json"
const SETTINGS_OPTIONS_DATA_PATH = "res://Resources/SettingsOptionsData.json"
const FORUM_HISTORY_PATH = "user://Forum-history.json"

const INITI_LOGIN_DATA = {"pid": "65edCTyg",
	"identity": "",
	"password": ""}

var login_data: Dictionary = INITI_LOGIN_DATA
var logged_in: bool
var user_id: int
var cookies: Dictionary
var user_name: String
var user_avatar: Texture = null:
	set(value):
		user_avatar = value
		user_avatar_update.emit()

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		var clipboard_get: String = DisplayServer.clipboard_get()
		if clipboard_get.begins_with("https://shequ.codemao.cn/community/"):
			append_address.emit(TranslationServer.translate("POST_NAME"), \
			"res://Scenes/Forum/PostMenu.tscn", \
			{"id": clipboard_get.trim_prefix("https://shequ.codemao.cn/community/").to_int()})
			DisplayServer.clipboard_set("")
		if clipboard_get.begins_with("https://shequ.codemao.cn/work/"):
			append_address.emit(TranslationServer.translate("WORK_NAME"), \
			"res://Scenes/Work/WorkMenu.tscn", \
			{"id": clipboard_get.trim_prefix("https://shequ.codemao.cn/work/").to_int()})
			DisplayServer.clipboard_set("") 

#保存json文件
func save_json_file(file_path: String, data: Dictionary):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	var json = JSON.stringify(data, "\t")
	file.store_string(json)
	file.close()

#加载json文件
func load_json_file(file_path: String):
	if FileAccess.file_exists(file_path):
		var data_file = FileAccess.open(file_path, FileAccess.READ)
		var paresd_result = JSON.parse_string(data_file.get_as_text())
		if paresd_result is Dictionary: return paresd_result
		else: 
			push_error("Failed to load json")
			return null
	else: push_warning("Attempts to locate the file failed")
	return null

#生成 Cookie 请求头
func generate_cookie_header() -> String:
	var cookie_str = ""
	for _name in cookies.keys():
		cookie_str += _name + "=" + cookies[_name] + "; "
	return "Cookie: " + cookie_str.trim_suffix("; ")

func sign_out() -> void:
	login_data = INITI_LOGIN_DATA
	save_json_file("user://LoginData.json", login_data)
	logged_in = false
	user_id = 0
	cookies.clear()
	user_name = TranslationServer.translate("VISITOR_NAME")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://UserData.json"))
	if FileAccess.file_exists(ProjectSettings.globalize_path("user://UserAvatar.png")): DirAccess.remove_absolute(ProjectSettings.globalize_path("user://UserAvatar.png"))
	Settings.automatic_login = false
	Settings.save_settings_config()
	user_avatar = null

func html_to_text(html: String):
	var regex = RegEx.new()
	regex.compile("(<.+?>|&nbsp;)")
	for result in regex.search_all(html):
		html = html.replace(result.get_string(), "")
	return html

func html_to_bbcode(html: String) -> String:
	var regex = RegEx.new()
	regex.compile("(<.+?>|&nbsp;)")
	#var results = []
	for result in regex.search_all(html):
		#results.push_back(result.get_string())
		var get_string: String = result.get_string()
		match get_string:
			'<p style="text-align: right;">': html = html.replace(get_string, "[right]")
			'<p style="text-align: center;">': html = html.replace(get_string, "[center]")
			'<p style="text-align: left;">': html = html.replace(get_string, "[left]")
			'<span style="font-size: x-喵all;">': html = html.replace(get_string, "[font_size=12]")
			'<span style="font-size: 喵all;">': html = html.replace(get_string, "[font_size=14]")
			'<span style="font-size: medium;">': html = html.replace(get_string, "[font_size=16]")
			'<span style="font-size: large;">': html = html.replace(get_string, "[font_size=22]")
			'<span style="font-size: x-large;">': html = html.replace(get_string, "[font_size=26]")
			'<span style="font-size: xx-large;">': html = html.replace(get_string, "[font_size=30]")
			'<strong>': html = html.replace(get_string, "[b]")
			'</strong>': html = html.replace(get_string, "[/b]")
			'<span style="text-decoration: underline;">': html = html.replace(get_string, "[u]")
			'</span>': html = html.replace(get_string, "[/u]")
			'<pre class="language-python">': html = html.replace(get_string, "[language=python]")
			'<code>': html = html.replace(get_string, "[code][begin]")
			'</code>': html = html.replace(get_string, "[end][code]")
			#提取图片链接：https:\/\/cdn-community.codemao.cn\/.*?\.png|jpeg
			_:
				if get_string.contains("https://cdn-community.bcmcdn.com/47/community/"):
					var image_link_regex = RegEx.new()
					image_link_regex.compile('("https://cdn-community.bcmcdn.com/47/community/.*?")')
					var image_link_result = image_link_regex.search(get_string)
					if image_link_result:
						var image_link: String = image_link_result.get_string()
						image_link = image_link.replace('"', '[split]')
						html = html.replace(get_string, image_link)
				else:
					html = html.replace(get_string, "")
	return html

func bbcode_to_html(bbcode: String) -> String:
	var regex = RegEx.new()
	
	# 匹配基础标签
	regex.compile("(\\[.+?\\])")
	for result in regex.search_all(bbcode):
		var get_string: String = result.get_string()
		match get_string:
			'[b]': bbcode = bbcode.replace(get_string, "<strong>")
			'[/b]': bbcode = bbcode.replace(get_string, "</strong>")
			'[u]': bbcode = bbcode.replace(get_string, '<span style="text-decoration: underline;">')
			'[/u]': bbcode = bbcode.replace(get_string, "</span>")
			'[right]': bbcode = bbcode.replace(get_string, '<p style="text-align: right;">')
			'[/right]': bbcode = bbcode.replace(get_string, "</p>")
			'[center]': bbcode = bbcode.replace(get_string, '<p style="text-align: center;">')
			'[/center]': bbcode = bbcode.replace(get_string, "</p>")
			'[left]': bbcode = bbcode.replace(get_string, '<p style="text-align: left;">')
			'[/left]': bbcode = bbcode.replace(get_string, "</p>")
			'[split]': bbcode = bbcode.replace(get_string, "")
			'[code]': bbcode = bbcode.replace(get_string, "")
			'[begin]': bbcode = bbcode.replace(get_string, "<code>")
			'[end]': bbcode = bbcode.replace(get_string, "</code>")
			'[/font_size]': bbcode = bbcode.replace(get_string, "</span>")
			_:
				if get_string.contains("color"): bbcode = bbcode.replace(get_string, '<span style="color: %s;">' %get_string.get_slice("=", 1).trim_suffix("]"))
				if get_string.contains("font_size"): bbcode = bbcode.replace(get_string, '<span style="font-size: %spx;">' %get_string.get_slice("=", 1).trim_suffix("]"))

	return bbcode

#字符串转16进制
func string_to_hex(input: String) -> String:
	var hex_char: String
	var bytes: PackedByteArray = input.to_utf8_buffer()
	for byte in bytes:
		hex_char = hex_char + "%" + "%02x" %byte
	return hex_char.to_upper()

# 时间戳转北京时间
func adjust_to_beijing_time_from_unix_time(unix_time_val: int) -> Dictionary:
	return adjust_to_beijing_time(Time.get_datetime_dict_from_unix_time(unix_time_val))

# UTC转北京时间
func adjust_to_beijing_time(datetime_dict: Dictionary) -> Dictionary:
	# 北京时间是UTC+8
	var beijing_time: Dictionary = {
		"year": datetime_dict["year"],
		"month": datetime_dict["month"],
		"day": datetime_dict["day"],
		"weekday": datetime_dict["weekday"],
		"hour": datetime_dict["hour"] + 8,
		"minute": datetime_dict["minute"],
		"second": datetime_dict["second"]
	}

	# 处理小时溢出
	if beijing_time["hour"] >= 24:
		beijing_time["hour"] -= 24
		beijing_time["day"] += 1

	# 处理天数溢出
	if beijing_time["day"] > get_days_in_month(beijing_time["year"], beijing_time["month"]):
		beijing_time["day"] = 1
		beijing_time["month"] += 1

	# 处理月份溢出
	if beijing_time["month"] > 12:
		beijing_time["month"] = 1
		beijing_time["year"] += 1

	return beijing_time

func format_relative_time(target_time: int) -> String:
	# 将目标时间转换为北京时间（UTC+8）
	target_time += 3600 * 8

	var current_time = Time.get_unix_time_from_system() + 3600 * 8  # 当前时间也转换为北京时间
	var time_diff = current_time - target_time

	if time_diff < 60: return "JUST_NOW_NAME"
	elif time_diff < 3600: return TranslationServer.translate("MINUTES_AGO_NAME").format([floori(time_diff / 60)])
	elif time_diff < 3600 * 24: return TranslationServer.translate("HOURS_AGO_NAME").format([floori(time_diff / 3600)])
	elif time_diff < 3600 * 24 * 30: return TranslationServer.translate("DAYS_AGO_NAME").format([floori(time_diff / (3600 * 24))])
	else:
		var datetime_dict = Time.get_datetime_dict_from_unix_time(target_time)
		return "%s%s%s%s%s%s %s:%s" %[
			datetime_dict.get("year"), 
			TranslationServer.translate("YEAR_NAME"), 
			datetime_dict.get("month"), 
			TranslationServer.translate("MONTH_NAME"), 
			datetime_dict.get("day"), 
			TranslationServer.translate("DAY_NAME1"), 
			datetime_dict.get("hour"), 
			datetime_dict.get("minute")
		]

func get_days_in_month(year: int, month: int) -> int:
	var days_in_month: Array = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0):
		days_in_month[1] = 29# 闰年二月有 29 天
	return days_in_month[month - 1]

func emit_system_error_message(message: String):
	add_system_message.emit(message, GlobalTheme.system_error_message_color, 6.0)

func get_popup_menu():
	return get_node("/root/@Control@101/MainPopupMenu")

func get_file_dialog():
	return get_node("/root/@Control@101/FileDialog")

func get_content_dialog():
	return get_node("/root/@Control@101/ContentDialog")

func view_the_image(image: Texture):
	var view_the_image_window = get_node("/root/@Control@101/ImageViewer")
	view_the_image_window.populate_image(image)
	view_the_image_window.show_window()

func get_mouse_position():
	return get_global_mouse_position()
