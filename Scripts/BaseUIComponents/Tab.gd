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
		text_label.visible = !text.is_empty()
@export_enum("Left", "Center", "Right") var alignment: int = 0:
	set(value):
		alignment = value
		title_label.horizontal_alignment = alignment
		text_label.horizontal_alignment = alignment
@export_group("Other")
@export var title_label: Node
@export var text_label: Node
@onready var line = %Line
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
	if Settings.dark_mode == 0: line.self_modulate = Color.html("0067c0")
	else: line.self_modulate = Color.html("#4cc2ff")
