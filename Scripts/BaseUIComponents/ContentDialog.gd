extends Control

@export var box_size: Vector2i = Vector2i(398, 272)

@export var title: String
@export_multiline var text: String

@export var popup_item: Array[PopupItem]

@onready var panel_container = %PanelContainer

@onready var title_label = %TitleLabel
@onready var text_label = %TextLabel

@onready var button_container = %ButtonContainer

@onready var animation_player = %AnimationPlayer

signal callback(index: int)

const CONTENT_DIALOG_BUTTON_SCENE = preload("res://Scenes/BaseUIComponents/ContentDialogButton.tscn")

func show_content_dialog() -> void:
	panel_container.custom_minimum_size = box_size
	panel_container.pivot_offset = panel_container.size / 2
	title_label.text = title
	text_label.text = text
	for node in button_container.get_children():
		node.queue_free()
	var index: int = 0
	for item: PopupItem in popup_item:
		var content_dialog_button_scene = CONTENT_DIALOG_BUTTON_SCENE.instantiate()
		button_container.add_child(content_dialog_button_scene)
		content_dialog_button_scene.style_type = int(item.flat)
		content_dialog_button_scene.text = item.text
		content_dialog_button_scene.index = index
		content_dialog_button_scene.on_pressed.connect(_on_button_pressed)
		index += 1
	animation_player.play("Show")

func hide_content_dialog() -> void:
	animation_player.play("Hide")

func _on_button_pressed(index: int) -> void:
	callback.emit(index)
