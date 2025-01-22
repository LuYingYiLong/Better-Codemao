@tool
extends PanelContainer

@export var text: String:
	set(value):
		text = value
		button.text = text
@export var checked: bool:
	set(value):
		checked = value
		checked_icon.visible = checked
		color_rect.visible = checked
		if checked: control.custom_minimum_size = Vector2(14, 0)
		else: control.custom_minimum_size = Vector2(20, 0)
@export_group("Other")
@export var button: Button
@export var checked_icon: TextureRect
@export var control: Control
@export var color_rect: PanelContainer

signal pressed(index: int)

var index: int

func _ready() -> void:
	if !Engine.is_editor_hint():
		button.text = text
		checked_icon.visible = checked
		color_rect.visible = checked
		if checked: control.custom_minimum_size = Vector2(14, 0)
		else: control.custom_minimum_size = Vector2(20, 0)

func _on_mouse_entered() -> void:
	color_rect.show()

func _on_mouse_exited() -> void:
	if !checked:
		color_rect.hide()

func _on_button_pressed() -> void:
	pressed.emit(index)
