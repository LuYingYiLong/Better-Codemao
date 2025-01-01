@tool
extends PanelContainer

@export var icon: Texture:
	set(value):
		icon = value
		set_icon(icon)
@export var text: String:
	set(value):
		text = value
		set_text(text)
@export var group: String
@export var selected: bool
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

@onready var color_rect = %ColorRect
@onready var button = %Button
@onready var info_badge = %InfoBadge
@onready var info_badge_2 = %InfoBadge2
@onready var animation_player = %AnimationPlayer

signal pressed
signal metadata_output(metadata)
signal animation_finished(anim_name)

var current_tab: int
var last_tab: int = -1
var last_tab_scene = null

var metadata = null

func _ready():
	if !Engine.is_editor_hint():
		current_tab = get_index()
		button.text = text
		button.icon = icon
		if selected:
			selected = false
			_on_pressed()

func set_icon(_icon: Texture) -> void:
	if Engine.is_editor_hint():
		%Button.icon = _icon
	else:
		%Button.icon = _icon

func set_text(_text: String) -> void:
	if Engine.is_editor_hint():
		%Button.text = _text
	else:
		%Button.text = _text

func _on_pressed():
	if not selected:
		selected = true
		color_rect.show()

		if last_tab == -1:
			animation_player.play("Selected")

		else:
			if last_tab > current_tab:
				last_tab_scene.selected = false
				last_tab_scene.color_rect.hide()
				last_tab_scene.play("PushOutTop")
				await last_tab_scene.animation_finished
				play("PushInBottom")
			
			elif last_tab < current_tab:
				last_tab_scene.selected = false
				last_tab_scene.color_rect.hide()
				last_tab_scene.play("PushOutBottom")
				await last_tab_scene.animation_finished
				play("PushInTop")

		for node in get_tree().get_nodes_in_group(group):
			node.last_tab = current_tab
			node.last_tab_scene = self
	pressed.emit()
	if metadata != null:
		metadata_output.emit(metadata)

func _set_infobadge_visible():
	if infobage_display_mode == 0:
		info_badge.visible = infobadge_visible
		info_badge_2.hide()
	elif infobage_display_mode == 1:
		info_badge.hide()
		info_badge_2.visible = infobadge_visible

func _on_mouse_entered():
	color_rect.show()

func _on_mouse_exited():
	if !selected:
		color_rect.hide()

func play(anim: String):
	animation_player.play(anim)

func _on_animation_player_animation_finished(anim_name):
	animation_finished.emit(anim_name)
