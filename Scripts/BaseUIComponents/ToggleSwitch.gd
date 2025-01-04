extends Control

@onready var margin_container = %MarginContainer
@onready var animation_player = %AnimationPlayer

const MARGIN_LEFT: int = 3
const MARGIN_TOP: int = 3
const MARGIN_RIGHT: int = 29
const MARGIN_BOTTOM: int = 3

var button_pressed: bool
var focus: bool

#func _process(_delta) -> void:
#	var margin_left: int = MARGIN_LEFT
#	var margin_top: int = MARGIN_TOP
#	var margin_right: int = MARGIN_RIGHT
#	var margin_bottom: int = MARGIN_BOTTOM

#	if focus:
#		margin_left -= 1
#		margin_top -= 1
#		margin_right -= 1
#		margin_bottom -= 1

#	margin_container.add_theme_constant_override("margin_left", margin_left)
#	margin_container.add_theme_constant_override("margin_top", margin_top)
#	margin_container.add_theme_constant_override("margin_right", margin_right)
#	margin_container.add_theme_constant_override("margin_bottom", margin_bottom)

func _on_gui_input(event) -> void:
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		if button_pressed: animation_player.play("OFF")
		else: animation_player.play("ON")
		button_pressed = not button_pressed

func _on_switch_mouse_entered() -> void:
	focus = true

func _on_switch_mouse_exited() -> void:
	focus = false
