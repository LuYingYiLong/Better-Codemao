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
@export var selected: bool

@onready var color_rect = %ColorRect
@onready var button = %Button
@onready var animation_player = %AnimationPlayer

signal pressed
signal animation_finished(anim_name)

var current_tab: int
var last_tab: int = -1
var last_tab_scene = null

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

		for node in get_tree().get_nodes_in_group("NavigationButtonsGroup"):
			node.last_tab = current_tab
			node.last_tab_scene = self
	pressed.emit()

func _on_mouse_entered():
	color_rect.show()

func _on_mouse_exited():
	if !selected:
		color_rect.hide()

func play(anim: String):
	animation_player.play(anim)

func _on_animation_player_animation_finished(anim_name):
	animation_finished.emit(anim_name)
