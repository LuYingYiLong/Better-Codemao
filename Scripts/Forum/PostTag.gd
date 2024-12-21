@tool
extends PanelContainer

@export var text: String
@export var color: Color = Color8(0, 103, 192)

@onready var label = %Label

func _ready() -> void:
	label.text = text
	self_modulate = color

func _process(_delta) -> void:
	if Engine.is_editor_hint():
		label.text = text
		self_modulate = color
