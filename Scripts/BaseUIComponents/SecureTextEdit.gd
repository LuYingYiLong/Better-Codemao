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
		
@onready var theme_painter = %ThemePainter

@onready var tools_bar = %ToolsBar
@onready var text_edit = %TextEdit
@onready var perview = %Perview
@onready var rich_text_label = %RichTextLabel
@onready var color_rect = %ColorRect
@onready var warning_label = %WarningLabel
@onready var sensitive_word_bar = %SensitiveWordBar
@onready var sensitive_word_button = %SensitiveWordButton
@onready var warning_button = %WarningButton

@onready var sensitive_word_tag_container = %SensitiveWordTagContainer

@onready var animation_player = %AnimationPlayer

signal send(text: String, send_type: int)

enum Error{CHECKING, OK, WARNING}

const SENSITIVE_WORD_TAG_SCENE = preload("res://Scenes/BaseUIComponents/SensitiveWordTag.tscn")

var sensitive_word_tag_visible: bool

var sensitive_words: PackedStringArray

var thread_helper: ThreadHelper

func _ready() -> void:
	thread_helper = ThreadHelper.new(self)
	theme_painter.update_theme()
	Settings.settings_config_update.connect(_on_settings_config_update)
	_on_settings_config_update()

func clear() -> void:
	text_edit.clear()
	color_rect.self_modulate = Color.html("#7b7b7b")
	warning_label.text = TranslationServer.translate("SECURE_TEXT_EDIT_REPORT1")
	sensitive_word_button.text = ""
	clear_sensitive_word_tag()

func _on_text_edit_text_changed() -> void:
	rich_text_label.clear()
	rich_text_label.append_text(text_edit.text)
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
		var content: String = text_edit.text
		var paragraphs: PackedStringArray = content.split("\n")
		var count: int = 0
		for string: String in paragraphs:
			paragraphs.set(count, "<p>%s</p>\n" %string)
			count += 1
		count = 0
		for string: String in paragraphs:
			paragraphs.set(count, paragraphs[count].replace("[b]", "<strong>"))
			paragraphs.set(count, paragraphs[count].replace("[/b]", "</strong>"))
			paragraphs.set(count, paragraphs[count].replace("[u]", "<u>"))
			paragraphs.set(count, paragraphs[count].replace("[/u]", "</u>"))
			count += 1
		content = ""
		for string: String in paragraphs:
			content += string
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

func _on_bold_button_pressed():
	insert_text_at_caret("[b][/b]")

func _on_underline_button_pressed():
	insert_text_at_caret("[u][/u]")

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
