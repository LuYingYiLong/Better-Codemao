extends Control

signal user_avatar_update

@warning_ignore("unused_signal")
signal append_address(address_name: String, scene_path: String, data: Dictionary)
@warning_ignore("unused_signal")
signal set_root_address(address_name: String, scene_path: String, data: Dictionary)
@warning_ignore("unused_signal")
signal async_load_scene(scene_path: String, data: Dictionary)

@warning_ignore("unused_signal")
signal show_login_menu

signal add_system_message(message: String, color: String, time: float)

const USER_DATA_PATH = "user://UserData.json"
const SETTINGS_OPTIONS_DATA_PATH = "res://Resources/SettingsOptionsData.json"
const FORUM_HISTORY_PATH = "user://Forum-history.json"
const LIBARAY_HISTORY_PATH = "user://Libaray-history.json"

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

var has_lastest_version: bool
var latest_version: String

# 识别网页链接
func is_valid_url(url: String) -> bool:
	var regex := RegEx.new()
	regex.compile("^https?://[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}(:[0-9]+)?(/.*)?$")
	var result = regex.search(url)
	if result == null: return false
	else: return true

func extract_host_from_url(url: String) -> String:
	var regex := RegEx.new()
	regex.compile("https?://([^/]+)")
	var result = regex.search(url)
	if result: return result.get_string()
	else: return ""

func extract_path_from_url(url: String) -> String:
	var regex := RegEx.new()
	regex.compile("https?://[^/]+(/.*)")
	var result = regex.search(url)
	if result: return result.get_string(1)
	else: return ""

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
			return {}
	else: return {}

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
	html = html.replace("&nbsp;", " ").replace("&mdash;", "—").replace("&ndash;", "–").\
			replace("&hellip;", "…").replace("&bull;", "•").replace("&times;", "×").\
			replace("&divide;", "÷").replace("&copy;", "©").replace("&reg;", "®").\
			replace("&trade;", "™").replace("&quot;", '"').replace("&apos;", "'").\
			replace("&lsquo;", "‘").replace("&rsquo;", "’").replace("&ldquo;", "“").\
			replace("&rdquo;", "”").replace("&plusmn;", "±").replace("&lt;", "<").\
			replace("&gt;", ">").replace("&le;", '≤').replace("&ge;", "≥").\
			replace("&ne;", "≠").replace("&middot;", "·")
	var text: String = html
	var regex = RegEx.new()
	regex.compile("(<.+?>)")

	# 先把 HTML标签 格式化
	var count: int = 0
	for result in regex.search_all(text):
		var pos: int = text.find(result.get_string())
		if pos >= 0:
			var result_length: int = result.get_string().length()
			for i: int in range(result_length):
				text[pos] = ""
			text = text.insert(pos, "{%s}" %count)
		count += 1

	# 将 HTML标签 转为 BBCode
	var tags: Array
	var end_tags: Array
	for result in regex.search_all(html):
		var get_string: String = result.get_string()
		match get_string:
			# 在你猫有头无尾的标签
			'<p style="text-align: right;">':
				tags.append("[right]")
				end_tags.append("[/right]")
			'<p style="text-align: center;">':
				tags.append("[center]")
				end_tags.append("[/center]")
			'<p style="text-align: left;">':
				tags.append("[left]")
				end_tags.append("[/left]")
			'<span style="font-size: x-喵all;">':
				tags.append("[font_size=12]")
				end_tags.append("[/font_size]")
			'<span style="font-size: 喵all;">':
				tags.append("[font_size=14]")
				end_tags.append("[/font_size]")
			'<span style="font-size: medium;">':
				tags.append("[font_size=16]")
				end_tags.append("[/font_size]")
			'<span style="font-size: large;">':
				tags.append("[font_size=22]")
				end_tags.append("[/font_size]")
			'<span style="font-size: x-large;">':
				tags.append("[font_size=26]")
				end_tags.append("[/font_size]")
			'<span style="font-size: xx-large;">':
				tags.append("[font_size=30]")
				end_tags.append("[/font_size]")
			'<h1">':
				tags.append("[font_size=12]")
				end_tags.append("[/font_size]")
			'<h2">':
				tags.append("[font_size=14]")
				end_tags.append("[/font_size]")
			'<h3">':
				tags.append("[font_size=16]")
				end_tags.append("[/font_size]")
			'<h4">':
				tags.append("[font_size=22]")
				end_tags.append("[/font_size]")
			'<h5">':
				tags.append("[font_size=26]")
				end_tags.append("[/font_size]")
			'<h6">':
				tags.append("[font_size=30]")
				end_tags.append("[/font_size]")
			'<span style="text-decoration: underline;">':
				tags.append("[u]")
				end_tags.append("[/u]")
			'<span>':
				tags.append("")
				end_tags.append("")
			'</span>':
				tags.append(end_tags.pop_back())
			# 在你猫有头有尾的标签
			'<strong>':
				tags.append("[b]")
				end_tags.append("[/b]")
			'</strong>':
				tags.append(end_tags.pop_back())
			'<code>':
				tags.append("[code]")
				end_tags.append("[/code]")
			'</code>': tags.append(end_tags.pop_back())
			'</pre>': tags.append(end_tags.pop_back())
			'<p>':
				tags.append("")
			'</p>':
				end_tags.append("")
				for item: String in end_tags:
					tags.append(end_tags.pop_front())
				end_tags.clear()
			_:
				# 检查是否是 HTML 多样式标签，如 <span style="color: #ff5050; font-size: x-large;">
				if get_string.begins_with('<span style="') and get_string.ends_with(';">'):
					var style_declarations: PackedStringArray = get_string.trim_prefix('<span style="').trim_suffix(';">').replace(" ", "").split(";")
					# 创建一个空项，让后续更好的添加标签
					tags.append("")
					end_tags.append("")
					var prefix_index: int = tags.size() - 1
					var end_tags_index: int = end_tags.size() - 1
					for style_declaration: String in style_declarations:
						var property_name: String = style_declaration.get_slice(":", 0)
						var property_value: String = style_declaration.get_slice(":", 1)
						var prefix: String = tags[prefix_index]
						var suffix: String = end_tags[end_tags_index]
						match property_name:
							"color":
								tags[prefix_index] = "%s[color=%s]" %[prefix, property_value]
								end_tags[end_tags_index] = "[/color]%s" %suffix
							"font-size":
								tags[prefix_index] = "%s[font_size=%s]" %[prefix, html_font_size_vlaue_to_bbcode(property_value)]
								end_tags[end_tags_index] = "[/font_size]%s" %suffix

				elif get_string.contains("https://cdn-community.bcmcdn.com/47/community/") or \
						get_string.contains("https://kn-cdn.codemao.cn/wood/image/") or \
						get_string.contains("https://cdn-community.codemao.cn/47/community/"):
					var image_link_regex = RegEx.new()
					if get_string.contains("https://cdn-community.bcmcdn.com/47/community/"): image_link_regex.compile('("https://cdn-community.bcmcdn.com/47/community/.*?")')
					elif get_string.contains("https://kn-cdn.codemao.cn/wood/image/"): image_link_regex.compile('("https://kn-cdn.codemao.cn/wood/image/.*?")')
					elif get_string.contains("https://cdn-community.codemao.cn/47/community/"): image_link_regex.compile('("https://cdn-community.codemao.cn/47/community/.*?")')
					var image_link_result = image_link_regex.search(get_string)
					if image_link_result:
						var image_link: String = image_link_result.get_string()
						tags.append("[image=%s]" %image_link.replace('"', ''))

				elif get_string.begins_with('<pre class="language-') and get_string.ends_with('">'):
					tags.append("[language=%s]" %get_string.trim_prefix('<pre class="language-').trim_suffix('">'))
					end_tags.append("[/language]")

				else:
					tags.append("")
	text = text.format(tags)

	return text

func html_font_size_vlaue_to_bbcode(value: String) -> String:
	match value:
		"x-喵all": return "12"
		"喵all": return "14"
		"medium": return "16"
		"large": return "22"
		"x-large": return "26"
		"xx-large": return "30"
		_: return "16"

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
			'[/color]': bbcode = bbcode.replace(get_string, "</span>")
			'[/font_size]': bbcode = bbcode.replace(get_string, "</span>")
			'[code]': bbcode = bbcode.replace(get_string, "<code>")
			'[/code]': bbcode = bbcode.replace(get_string, "</code>")
			'[/language]': bbcode = bbcode.replace(get_string, "</pre>")
			_:
				if get_string.begins_with("[color="): bbcode = bbcode.replace(get_string, '<span style="color: %s;">' %get_string.get_slice("=", 1).trim_suffix("]"))
				if get_string.begins_with("[font_size="): bbcode = bbcode.replace(get_string, '<span style="font-size: %spx;">' %get_string.get_slice("=", 1).trim_suffix("]"))
				if get_string.begins_with("[image="):
					var str_result: String = '<img style="max-width: 100%; display: block; margin: 0 auto;" src="' + get_string.get_slice("=", 1).trim_suffix("]") + '" alt="center_image">'
					print(str_result)
					bbcode = bbcode.replace(get_string, str_result)
				if get_string.begins_with("[language="): bbcode = bbcode.replace(get_string, '<pre class="language-%s">' %get_string.get_slice("=", 1).trim_suffix("]"))

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

# 创建 Tween 对 ScrollContainer 节点进行播放返回顶部的补间动画
func scroll_to_top(scroll_container: ScrollContainer) -> void:
	if scroll_container.scroll_vertical >= 0:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(scroll_container, "scroll_vertical", 0, 0.25)
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)

func emit_system_error_message(message: String):
	add_system_message.emit(message, GlobalTheme.system_error_message_color, 6.0)

func get_global_node(node_name: String):
	for node in get_tree().get_nodes_in_group("GlobalNode"):
		if node.name == node_name: return node
	return null

func view_the_image(image: Texture):
	var view_the_image_window = get_global_node("ImageViewer")
	view_the_image_window.populate_image(image)
	view_the_image_window.show_window()

func get_mouse_position():
	return get_global_mouse_position()
