@tool
extends PanelContainer

@export var icon: Texture
@export var text: String
@export var popup_items: Array[PopupItem]
@export_group("Popup menu")
@export_range(-1, 9999) var popup_menu_width: int = -1
@export_enum("Left", "Center", "Right") var popup_menu_size_flags_horizontal: int = 0

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

func _on_button_pressed() -> void:
	down_arrow_animation_player.play("Animation")
	popup_menu.popup_items = popup_items
	popup_menu.set_anchor(Vector2i(ceili(global_position.x), ceili(global_position.y + 40)))
	if popup_menu_size_flags_horizontal == 1: popup_menu.anchor.x += size.x / 2
	elif popup_menu_size_flags_horizontal == 2: popup_menu.anchor.x += size.x + 16
	popup_menu.width = popup_menu_width
	popup_menu.size_flags_horizontal = popup_menu_size_flags_horizontal
	popup_menu.emit = true

func _on_popup_menu_index_pressed(index: int) -> void:
	index_pressed.emit(index)
