extends PanelContainer

@onready var label = %Label

@export var value: int:
	set(_value):
		value = _value
		if value >= 100: label.text = "*"
		else: label.text = str(value)
