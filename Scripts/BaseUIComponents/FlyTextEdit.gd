extends Control

@export var menu_size: Vector2 = Vector2(400, 500)
@export_multiline var init_text: String:
	set(value):
		init_text = value
		text_edit.text = init_text
@export_multiline var placeholder_text: String:
	set(value):
		placeholder_text = value
		text_edit.placeholder_text = placeholder_text

@onready var panel_container = %PanelContainer
@onready var text_edit = %TextEdit
@onready var line = %Line

@onready var animation_player = %AnimationPlayer

signal finish_editing(text: String)

func show_fly_text_edit() -> void:
	panel_container.custom_minimum_size = menu_size
	animation_player.play("Show")

func hide_fly_text_edit() -> void:
	animation_player.play("Hide")

func clear() -> void:
	text_edit.clear()

func _on_text_edit_focus_entered() -> void:
	line.show()

func _on_text_edit_focus_exited() -> void:
	line.hide()

func _on_cancel_button_pressed() -> void:
	hide_fly_text_edit()

func _on_ok_button_pressed() -> void:
	finish_editing.emit(text_edit.text)
	hide_fly_text_edit()
