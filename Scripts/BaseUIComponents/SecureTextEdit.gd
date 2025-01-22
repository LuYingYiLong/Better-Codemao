extends PanelContainer

@export_enum("Web", "String") var send_type: int = 0:
	set(value):
		send_type = value
		tools_bar.visible = send_type == 0
		perview.visible = send_type == 0
@export var text: String:
	set(value):
		text = value
		text_edit.text = text
@export var placeholder_text: String:
	set(value):
		placeholder_text = value
		text_edit.placeholder_text = placeholder_text
		
@onready var uploading_request = %UploadingRequest
@onready var upload_request = %UploadRequest

@onready var tools_bar = %ToolsBar
@onready var font_color_button = %FontColorButton
@onready var fly_color_picker = %FlyColorPicker

@onready var text_edit = %TextEdit
@onready var perview = %Perview
@onready var rich_content = %RichContent

@onready var color_rect = %ColorRect
@onready var warning_label = %WarningLabel
@onready var sensitive_word_bar = %SensitiveWordBar
@onready var sensitive_word_button = %SensitiveWordButton
@onready var warning_button = %WarningButton

@onready var sensitive_word_tag_container = %SensitiveWordTagContainer

@onready var file_dialog = %FileDialog
@onready var animation_player = %AnimationPlayer

signal send(text: String, send_type: int)

enum Error{CHECKING, OK, WARNING}

const SENSITIVE_WORD_TAG_SCENE = preload("res://Scenes/BaseUIComponents/SensitiveWordTag.tscn")

var sensitive_word_tag_visible: bool

var sensitive_words: PackedStringArray

var bucket_url: String
var file_path: String

var thread_helper: ThreadHelper

func _ready() -> void:
	thread_helper = ThreadHelper.new(self)
	Settings.settings_config_update.connect(_on_settings_config_update)
	_on_settings_config_update()

func clear() -> void:
	text_edit.clear()
	color_rect.self_modulate = Color.html("#7b7b7b")
	warning_label.text = TranslationServer.translate("SECURE_TEXT_EDIT_REPORT1")
	sensitive_word_button.text = ""
	clear_sensitive_word_tag()

func _on_text_edit_text_changed() -> void:
	rich_content.init_contents(text_edit.text)
	color_rect.self_modulate = Color.html("#7b7b7b")
	warning_label.text = TranslationServer.translate("SECURE_TEXT_EDIT_REPORT1")
	sensitive_word_button.text = ""
	if !thread_helper.is_running():
		clear_sensitive_word_tag()
		thread_helper.join_function(func(): check_text_from_thread(text_edit.text))
		thread_helper.start()

func _on_gui_input(event) -> void:
	if event is InputEventMouseButton and event.is_pressed and sensitive_word_tag_visible: _on_sensitive_word_button_pressed()

func check_text_from_thread(_text: String) -> void:
	sensitive_words = SensitiveWordsManager.check_text(_text)
	if sensitive_words.is_empty():
		color_rect.call_deferred("set_self_modulate", Color.html(GlobalTheme.default_ok_color))
		warning_label.call_deferred("set_text", TranslationServer.translate("SECURE_TEXT_EDIT_REPORT3"))
	else:
		color_rect.call_deferred("set_self_modulate", Color.html(GlobalTheme.default_error_color))
		warning_label.call_deferred("set_text", TranslationServer.translate("SECURE_TEXT_EDIT_REPORT2"))
		var sensitive_word: String
		for word: String in sensitive_words:
			sensitive_word = "%s%s, " %[sensitive_word, word]
			call_deferred_thread_group("add_sensitive_word_tag", word)
		sensitive_word = sensitive_word.trim_suffix(", ")
		sensitive_word_button.call_deferred("set_text", sensitive_word)
	warning_button.call_deferred("set_visible", not sensitive_words.is_empty())

func replace(word: String) -> void:
	text_edit.text = text_edit.text.replace(word, "")
	color_rect.self_modulate = Color.html("#7b7b7b")
	clear_sensitive_word_tag()
	sensitive_word_button.text = ""
	if !thread_helper.is_running():
		thread_helper.join_function(func(): check_text_from_thread(text_edit.text))
		thread_helper.start()

func clear_sensitive_word_tag() -> void:
	for node in sensitive_word_tag_container.get_children():
		node.queue_free()

func add_sensitive_word_tag(word: String) -> void:
	var sensitive_word_tag_scene = SENSITIVE_WORD_TAG_SCENE.instantiate()
	sensitive_word_tag_container.add_child(sensitive_word_tag_scene)
	sensitive_word_tag_scene.set_word(word)
	sensitive_word_tag_scene.pressed.connect(replace)

func _on_warning_button_pressed() -> void:
	warning_button.hide()
	for word: String in sensitive_words:
		text_edit.text = text_edit.text.replace(word, "")
	color_rect.self_modulate = Color.html("#7b7b7b")
	clear_sensitive_word_tag()
	sensitive_word_button.text = ""
	if !thread_helper.is_running():
		thread_helper.join_function(func(): check_text_from_thread(text_edit.text))
		thread_helper.start()

func _on_sensitive_word_button_pressed() -> void:
	if sensitive_word_tag_visible: animation_player.play("HideSensitiveWordTag")
	else: animation_player.play("ShowSensitiveWordTag")
	sensitive_word_tag_visible = not sensitive_word_tag_visible

func _on_send_button_pressed() -> void:
	if send_type == 0:
		var content: String = Application.bbcode_to_html(text_edit.text)
		var paragraphs: PackedStringArray = content.split("\n")
		var count: int = 0
		for string: String in paragraphs:
			paragraphs.set(count, "<p>%s</p>\n" %string)
			count += 1
		content = ""
		for string: String in paragraphs:
			content += string
		content = content.trim_suffix("\n")
		print(content)
		send.emit(content, send_type)
	elif send_type == 1:
		send.emit(text_edit.text, send_type)

func insert_text_at_caret(insert_text: String) -> void:
	text_edit.begin_complex_operation()
	text_edit.begin_multicaret_edit()
	for i in range(text_edit.get_caret_count()):
		if text_edit.multicaret_edit_ignore_caret(i):
			continue
		text_edit.insert_text_at_caret(insert_text, i)
	text_edit.end_multicaret_edit()
	text_edit.end_complex_operation()

func _on_bold_button_pressed() -> void:
	insert_text_at_caret("[b][/b]")

func _on_underline_button_pressed() -> void:
	insert_text_at_caret("[u][/u]")

func _on_font_size_button_pressed() -> void:
	insert_text_at_caret("[font_size=16][/font_size]")

func _on_font_color_button_pressed() -> void:
	fly_color_picker.position.x = font_color_button.global_position.x - 8
	fly_color_picker.position.y = font_color_button.global_position.y + 40
	fly_color_picker.show()

func _on_fly_color_picker_color_selected(color: Color) -> void:
	insert_text_at_caret("[color=#%s][/color]" %color.to_html(false))

func _on_align_right_button_pressed() -> void:
	insert_text_at_caret("[right][/right]")

func _on_align_center_button_pressed() -> void:
	insert_text_at_caret("[center][/center]")

func _on_align_left_button_pressed() -> void:
	insert_text_at_caret("[left][/left]")

func _on_photo_button_pressed():
	file_dialog.show()

func _on_code_button_pressed() -> void:
	insert_text_at_caret("[language=python][code][/code][/language]")

func _on_settings_config_update() -> void:
	if Settings.dark_mode == 0:
		pass
	else:
		var tools_bar_style: StyleBoxFlat = tools_bar.get_theme_stylebox("panel")
		tools_bar_style.bg_color = Color.html("#1c1c1c")
		tools_bar_style.border_color = Color.html("#1b1b1b")
		var text_edit_style: StyleBoxFlat = text_edit.get_theme_stylebox("normal")
		text_edit_style.bg_color = Color.html("#242424")
		text_edit_style.border_color = Color.html("#1b1b1b")
		var perview_style: StyleBoxFlat = perview.get_theme_stylebox("panel")
		perview_style.bg_color = Color.html("#1c1c1c")
		perview_style.border_color = Color.html("#1b1b1b")
		var sensitive_word_bar_style: StyleBoxFlat = sensitive_word_bar.get_theme_stylebox("panel")
		sensitive_word_bar_style.bg_color = Color.html("#1c1c1c")
		sensitive_word_bar_style.border_color = Color.html("#1b1b1b")

func _on_file_dialog_file_selected(path: String) -> void:
	file_path = path
	var unique_filename = generate_unique_filename(path)
	uploading_request.request("https://open-service.codemao.cn/cdn/qi-niu/tokens/uploading?projectName=community_frontend&filePaths=community/%s&filePath=community/%s&tokensCount=1&fileSign=p1&cdnName=qiniu" %[
				unique_filename, \
				unique_filename
			], \
			[Application.generate_cookie_header()])

func generate_unique_filename(path: String) -> String:
	# 固定前缀
	var prefix = "d2ViXz"
	# 获取当前时间戳（毫秒级）
	var timestamp = str(int(Time.get_unix_time_from_system()))
	# 读取文件内容并计算哈希值
	var file_access: FileAccess = FileAccess.open(path, FileAccess.READ)
	var file_data: PackedByteArray = file_access.get_buffer(file_access.get_length())
	file_access.close()
	# 计算文件内容的 MD5 哈希值
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_MD5)
	ctx.update(file_data)
	var file_hash = ctx.finish().hex_encode()
	# 获取文件扩展名
	var file_extension = path.get_extension().to_lower()
	# 生成唯一文件名
	var unique_filename = prefix + timestamp + file_hash + "." + file_extension
	return unique_filename

func _on_uploading_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(_body.get_string_from_utf8())
	bucket_url = json.get("bucket_url", "")
	var upload_url: String = json.get("upload_url", "")
	var tokens: Dictionary = json.get("tokens", [{}])[0]
	var key: String = tokens.get("file_path", "")
	var token: String = tokens.get("token", "")
	
	# 获取文件数据
	var file_access: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	var file_data: PackedByteArray = file_access.get_buffer(file_access.get_length())
	file_access.close()

	# 创建请求头，携带 token
	var headers: PackedStringArray = ["Content-Type: multipart/form-data; boundary=----WebKitFormBoundary"]
	headers.append("Authorization: UpToken " + token)
	# 创建请求体（multipart/form-data）
	var boundary = "----WebKitFormBoundary"
	var body: PackedByteArray = []

	# 添加 token 参数
	body += _string_to_bytes("--" + boundary + "\r\n")
	body += _string_to_bytes("Content-Disposition: form-data; name=\"token\"\r\n\r\n")
	body += _string_to_bytes(token + "\r\n")

	# 添加 key 参数（可选）
	body += _string_to_bytes("--" + boundary + "\r\n")
	body += _string_to_bytes("Content-Disposition: form-data; name=\"key\"\r\n\r\n")
	body += _string_to_bytes(key + "\r\n")

	# 添加文件数据
	body += _string_to_bytes("--" + boundary + "\r\n")
	body += _string_to_bytes("Content-Disposition: form-data; name=\"file\"; filename=\"" + file_path.get_file() + "\"\r\n")
	body += _string_to_bytes("Content-Type: image/png\r\n\r\n")  # 根据文件类型修改
	body += file_data  # 添加文件数据
	body += _string_to_bytes("\r\n")

	# 结束边界
	body += _string_to_bytes("--" + boundary + "--\r\n")
	upload_request.request_raw(upload_url, headers, HTTPClient.METHOD_POST, body)
	
# 将字符串转换为字节数组
func _string_to_bytes(string: String) -> PackedByteArray:
	return string.to_utf8_buffer()  

func _on_upload_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	insert_text_at_caret("[image=%s%s]" %[bucket_url, json.get("key")])
