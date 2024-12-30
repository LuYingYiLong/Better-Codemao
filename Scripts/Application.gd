extends Control

signal user_avatar_update

@warning_ignore("unused_signal")
signal append_address(address_name: String, scene_path: String, data: Dictionary)
@warning_ignore("unused_signal")
signal set_root_address(address_name: String, scene_path: String, data: Dictionary)

signal add_system_message(message: String, color: String, time: float)

const EFFECTIVE_POST_ID_PATH = "user://EffectivePostID.dat"
const SETTINGS_OPTIONS_DATA_PATH = "res://Resources/SettingsOptionsData.json"

var login_data = {"pid": "65edCTyg",
	"identity": "",
	"password": ""}
var logged_in: bool
var user_id: int
var cookies: Dictionary
var user_avatar: Texture = null:
	set(value):
		user_avatar = value
		user_avatar_update.emit()
var user_name: String

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

func save_effective_post_id(post_id: int):
	var file = FileAccess.open(EFFECTIVE_POST_ID_PATH, FileAccess.WRITE)
	file.store_string(str(post_id))
	file.close()

func get_effective_post_id() -> int:
	var file = FileAccess.open(EFFECTIVE_POST_ID_PATH, FileAccess.READ)
	var post_id: int = file.get_as_text().to_int()
	return post_id

#生成 Cookie 请求头
func generate_cookie_header() -> String:
	var cookie_str = ""
	for _name in cookies.keys():
		cookie_str += _name + "=" + cookies[_name] + "; "
	return "Cookie: " + cookie_str.trim_suffix("; ")

func html_to_text(html: String):
	var regex = RegEx.new()
	regex.compile("(<.+?>|&nbsp;)")
	for result in regex.search_all(html):
		html = html.replace(result.get_string(), "")
	return html

func html_to_bbcode(html: String):
	var regex = RegEx.new()
	regex.compile("(<.+?>|&nbsp;)")
	#var results = []
	for result in regex.search_all(html):
		#results.push_back(result.get_string())
		var get_string: String = result.get_string()
		match get_string:
			'<p style="text-align: center;">': html = html.replace(get_string, "[center]")
			'<p style="text-align: left;">': html = html.replace(get_string, "[left]")
			'<p style="text-align: right;">': html = html.replace(get_string, "[right]")
			'<span style="font-size: x-喵all;">': html = html.replace(get_string, "[font_size=10]")
			'<span style="font-size: 喵all;">': html = html.replace(get_string, "[font_size=14]")
			'<span style="font-size: medium;">': html = html.replace(get_string, "[font_size=18]")
			'<span style="font-size: large;">': html = html.replace(get_string, "[font_size=22]")
			'<span style="font-size: x-large;">': html = html.replace(get_string, "[font_size=26]")
			'<span style="font-size: xx-large;">': html = html.replace(get_string, "[font_size=30]")
			'<strong>': html = html.replace(get_string, "[b]")
			#提取图片链接：https:\/\/cdn-community.codemao.cn\/.*?\.png|jpeg
			_:
				if get_string.contains("https://cdn-community.bcmcdn.com/47/community/"):
					var image_link_regex = RegEx.new()
					image_link_regex.compile('("https://cdn-community.bcmcdn.com/47/community/.*?")')
					var image_link_result = image_link_regex.search(get_string)
					if image_link_result:
						var image_link: String = image_link_result.get_string()
						image_link = image_link.replace('"', '|SPLIT|')
						html = html.replace(get_string, image_link)
				else:
					html = html.replace(get_string, "")
	return html

func emit_system_error_message(message: String):
	add_system_message.emit(message, GlobalTheme.system_error_message_color, 6.0)

func get_popup_menu():
	return get_node("/root/@Control@100/MainPopupMenu")

func get_file_dialog():
	return get_node("/root/@Control@100/FileDialog")

func get_content_dialog():
	return get_node("/root/@Control@100/ContentDialog")

func view_the_image(image: Texture):
	var view_the_image_window = get_node("/root/@Control@100/ImageViewer")
	view_the_image_window.populate_image(image)
	view_the_image_window.show_window()

func get_mouse_position():
	return get_global_mouse_position()
