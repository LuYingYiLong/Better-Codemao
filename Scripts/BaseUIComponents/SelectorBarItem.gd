@tool
extends Control

signal index_pressed(index: int)

@export var icon: Texture:
	set(value):
		icon = value
		icon_texture.texture = icon
@export var text: String:
	set(value):
		text = value
		text_label.text = text
@export_group("other")
@export var icon_texture: Node
@export var text_label: Node

@onready var h_box_container = %HBoxContainer
@onready var line = %Line
@onready var animation_player = %AnimationPlayer

var selected: bool:
	set(value):
		selected = value
		if selected: animation_player.play("Selected")
		else: animation_player.play("RESET")
var index: int

func _ready():
	if not Engine.is_editor_hint():
		Settings.settings_config_update.connect(_on_settings_config_update)
		_on_settings_config_update()

func _on_pressed() -> void:
	if !selected:
		selected = true
		index_pressed.emit(index)

func _on_settings_config_update() -> void:
	if Settings.dark_mode == 0: line.self_modulate = Color.html("0067c0")
	else: line.self_modulate = Color.html("#4cc2ff")
