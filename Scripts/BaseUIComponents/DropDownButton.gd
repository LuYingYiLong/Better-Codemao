@tool
extends PanelContainer

@export var icon: Texture
@export var text: String
@export var popup_items: Array[PopupItem]

@onready var texture = %Texture
@onready var label = %Label
@onready var down_arrow_icon = %DownArrowIcon
@onready var down_arrow_animation_player = %DownArrowAnimationPlayer

@onready var popup_menu = %PopupMenu

signal index_pressed(index: int)

func _ready() -> void:
	texture.texture = icon
	texture.visible = icon != null
	label.text = text
	label.visible = !text.is_empty()
	if !Engine.is_editor_hint():
		Settings.settings_config_update.connect(_on_settings_config_update)
		_on_settings_config_update()

func _on_button_pressed() -> void:
	down_arrow_animation_player.play("Animation")
	popup_menu.populate_items(popup_items)
	popup_menu.set_pos(Vector2i(ceili(global_position.x - 6), ceili(global_position.y + 40)))
	popup_menu.emit = true

func _on_popup_menu_index_pressed(index: int) -> void:
	index_pressed.emit(index)

func _on_settings_config_update() -> void:
	if Settings.dark_mode == 0:
		add_theme_stylebox_override("panel", load("res://Resources/Themes/DefaultPanelStyle.tres"))
		texture.self_modulate = Color.html(GlobalTheme.light_mode_icon_color)
		label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
		down_arrow_icon.self_modulate = Color.html(GlobalTheme.light_mode_translucent_icon_color)
	else:
		add_theme_stylebox_override("panel", load("res://Resources/Themes/DefaultPanelDarknessStyle.tres"))
		texture.self_modulate = Color.html(GlobalTheme.dark_mode_icon_color)
		label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_icon_color))
		down_arrow_icon.self_modulate = Color.html(GlobalTheme.dark_mode_translucent_icon_color)
