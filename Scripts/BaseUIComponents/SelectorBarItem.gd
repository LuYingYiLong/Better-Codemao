@tool
extends Button

signal index_pressed(index: int)

var selected: bool:
	set(value):
		selected = value
		if selected: animation_player.play("Selected")
		else: animation_player.play("RESET")
var index: int

@onready var animation_player = %AnimationPlayer

func _on_pressed() -> void:
	if !selected: selected = true
	index_pressed.emit(index)
