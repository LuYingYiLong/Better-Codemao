@tool
extends PanelContainer

@export var text: String:
	set(value):
		text = value
		if Engine.is_editor_hint():
			%Button.text = text
@export var checked: bool:
	set(value):
		checked = value
		if Engine.is_editor_hint():
			%CheckedIcon.visible = checked
			%ColorRect.visible = checked
			if checked: %Control.custom_minimum_size = Vector2(14, 0)
			else: %Control.custom_minimum_size = Vector2(20, 0)

@onready var checked_icon = %CheckedIcon
@onready var control = %Control
@onready var button = %Button
@onready var color_rect = %ColorRect

signal pressed(index: int)

var index: int

func _ready() -> void:
	if !Engine.is_editor_hint():
		button.text = text
		checked_icon.visible = checked
		color_rect.visible = checked
		if checked: control.custom_minimum_size = Vector2(14, 0)
		else: control.custom_minimum_size = Vector2(20, 0)

func set_item_text(_text: String) -> void:
	text = _text
	button.text = text

func _on_mouse_entered() -> void:
	color_rect.show()

func _on_mouse_exited() -> void:
	if !checked:
		color_rect.hide()

func _on_button_pressed() -> void:
	pressed.emit(index)
