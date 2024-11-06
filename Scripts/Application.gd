extends Control

signal user_avatar_update

@warning_ignore("unused_signal")
signal append_address(address_name: String, scene_path: String, data: Dictionary)
@warning_ignore("unused_signal")
signal set_root_address(address_name: String, scene_path: String, data: Dictionary)

@warning_ignore("unused_signal")
signal add_system_message(message: String, color: String, time: float)

const EFFECTIVE_POST_ID_PATH = "user://EffectivePostID.dat"

var login_data = {"pid": "65edCTyg",
	"identity": "",
	"password": ""}
var user_id: int
var cookies: Dictionary
var user_avatar: Texture = null:
	set(value):
		user_avatar = value
		user_avatar_update.emit()

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

func html_to_bbcode(html: String) -> String:
	html = html.replace("</p>", "\n").replace("<p>", "").replace("</a", "").trim_suffix("\n")
	var line_packs := html.split("\n")
	var count: int = -1
	for line: String in line_packs:
		count += 1
		line = line.replace('<strong>', '[b]')
		line = line.replace('</strong>', '[/b]')
		line = line.replace('<span style="font-size: x-喵all;">', '[font_size=12]')
		line = line.replace('<span style="font-size: 喵all;">', '[font_size=16]')
		line = line.replace('<span style="font-size: medium;">', '[font_size=20]')
		line = line.replace('<span style="font-size: large;">', '[font_size=24]')
		line = line.replace('<span style="font-size: x-large;">', '[font_size=28]')
		line = line.replace('<span style="font-size: xx-large;">', '[font_size=32]')
		line = line.replace('</span>', '[/font_size]')
		line = line.replace('<span style="text-decoration: underline;">', '[u]')

		line_packs.set(count, line)

	html = ""
	for line: String in line_packs:
		html = "%s%s\n" %[html, line]
	return html
