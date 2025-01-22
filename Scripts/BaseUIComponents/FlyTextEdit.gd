extends Control

@export var menu_size: Vector2 = Vector2(400, 500)
@export_multiline var text: String:
	set(value):
		text = value
		text_edit.text = text
@export_multiline var placeholder_text: String:
	set(value):
		placeholder_text = value
		text_edit.placeholder_text = placeholder_text

@onready var panel_container = %PanelContainer
@onready var text_edit = %TextEdit

@onready var animation_player = %AnimationPlayer

signal finish_editing(text: String)

func show_fly_text_edit() -> void:
	animation_player.play("Show")

func hide_fly_text_edit() -> void:
	animation_player.play("Hide")

func _on_cancel_button_pressed() -> void:
	finish_editing.emit("")
	hide_fly_text_edit()

func _on_ok_button_pressed() -> void:
	finish_editing.emit(text_edit.text)
	hide_fly_text_edit()
