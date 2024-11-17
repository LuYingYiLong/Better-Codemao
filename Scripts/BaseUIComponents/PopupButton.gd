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
			%Control.visible = !checked
			%ColorRect.visible = checked

@onready var checked_icon = %CheckedIcon
@onready var control = %Control
@onready var button = %Button
@onready var color_rect = %ColorRect

signal pressed(index: int)

var index: int

func _ready():
	if !Engine.is_editor_hint():
		button.text = text
		checked_icon.visible = checked
		control.visible = !checked
		color_rect.visible = checked

func set_item_text(_text: String):
	text = _text
	button.text = text

func _on_mouse_entered():
	color_rect.show()

func _on_mouse_exited():
	if !checked:
		color_rect.hide()

func _on_button_pressed():
	pressed.emit(index)
