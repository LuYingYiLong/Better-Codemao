@tool
extends PanelContainer

@export var icon: Texture:
	set(value):
		icon = value
		button.icon = icon
@export var text: String:
	set(value):
		text = value
		button.text = text
@export var group: String
@export var selected: bool = false:
	set(value):
		selected = value
		call_deferred("update_group_status")
@export_group("InfoBadge")
@export var infobadge_visible: bool:
	set(value):
		infobadge_visible = value
		_set_infobadge_visible()
@export_enum("Left Compact", "Left Expanded") var infobage_display_mode: int = 0:
	set(value):
		infobage_display_mode = value
		_set_infobadge_visible()
@export var infobadge_value: int:
	set(value):
		infobadge_value = value
		info_badge.value = infobadge_value
		info_badge_2.value = infobadge_value

@export_group("Other")
@export var focused_rect: PanelContainer
@export var button: Button
@export var animation_player: AnimationPlayer

@onready var line = %Line
@onready var info_badge = %InfoBadge
@onready var info_badge_2 = %InfoBadge2

signal pressed
signal metadata_output(metadata)
signal animation_finished(anim_name)

var current_tab: int
var last_tab: int = -1
var last_tab_scene = null

var metadata = null

func _ready():
	current_tab = get_index()
	if !Engine.is_editor_hint():
		Settings.settings_config_update.connect(_on_settings_config_update)
		_on_settings_config_update()

func _on_pressed():
	selected = not selected

func update_group_status() -> void:
	focused_rect.visible = selected
	if selected:
		if last_tab == -1: animation_player.play("Selected")
		else:
			if last_tab > current_tab:
				last_tab_scene.selected = false
				last_tab_scene.focused_rect.hide()
				last_tab_scene.play("PushOutTop")
				await last_tab_scene.animation_finished
				play("PushInBottom")
				
			elif last_tab < current_tab:
				last_tab_scene.selected = false
				last_tab_scene.focused_rect.hide()
				last_tab_scene.play("PushOutBottom")
				await last_tab_scene.animation_finished
				play("PushInTop")

		for node in get_tree().get_nodes_in_group(group):
			node.last_tab = current_tab
			node.last_tab_scene = self
		pressed.emit()
		if metadata != null:
			metadata_output.emit(metadata)

	else: animation_player.play("RESET")
	

func _set_infobadge_visible():
	if infobage_display_mode == 0:
		info_badge.visible = infobadge_visible
		info_badge_2.hide()
	elif infobage_display_mode == 1:
		info_badge.hide()
		info_badge_2.visible = infobadge_visible

func _on_mouse_entered():
	focused_rect.show()

func _on_mouse_exited():
	if !selected:
		focused_rect.hide()

func play(anim: String):
	animation_player.play(anim)

func _on_animation_player_animation_finished(anim_name):
	animation_finished.emit(anim_name)

func _on_settings_config_update() -> void:
	if Settings.get_dark_mode():
		button.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
		button.add_theme_color_override("font_disabled_color", Color.html(GlobalTheme.dark_mode_font_color))
		button.add_theme_color_override("font_focus_color", Color.html(GlobalTheme.dark_mode_font_color))
		button.add_theme_color_override("font_hover_color", Color.html(GlobalTheme.dark_mode_font_color))
		button.add_theme_color_override("font_hover_pressed_color", Color.html(GlobalTheme.dark_mode_font_color))
		button.add_theme_color_override("font_pressed_color", Color.html(GlobalTheme.dark_mode_font_color))
		line.self_modulate = Color.html("#4cc2ff")
	else:
		button.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
		button.add_theme_color_override("font_disabled_color", Color.html(GlobalTheme.light_mode_font_color))
		button.add_theme_color_override("font_focus_color", Color.html(GlobalTheme.light_mode_font_color))
		button.add_theme_color_override("font_hover_color", Color.html(GlobalTheme.light_mode_font_color))
		button.add_theme_color_override("font_hover_pressed_color", Color.html(GlobalTheme.light_mode_font_color))
		button.add_theme_color_override("font_pressed_color", Color.html(GlobalTheme.light_mode_font_color))
		line.self_modulate = Color.html("#0067c0")
