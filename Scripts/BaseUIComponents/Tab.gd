@tool
extends Control

@export var title: String:
	set(value):
		title = value
		title_label.text = title
@export var text: String:
	set(value):
		text = value
		text_label.text = text
@export_group("Other")
@export var title_label: Node
@export var text_label: Node
@export var animation_player: Node

signal index_pressed

var index: int
var current_tab: int:
	set(value):
		current_tab = value
		if current_tab == index: animation_player.play("Selected")
		else: animation_player.play("RESET")

func _ready() -> void:
	if !Engine.is_editor_hint():
		Settings.settings_config_update.connect(_on_settings_config_update)
		_on_settings_config_update()

func _on_pressed():
	index_pressed.emit(index)

func is_tab() -> void:
	pass

func _on_settings_config_update() -> void:
	if Settings.dark_mode == 0:
		title_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
		text_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_translucent_palette))
	else:
		title_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
		text_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_translucent_palette))
