extends PanelContainer

@export_multiline var text: String:
	set(value):
		text = value
		code_edit.text = text
@export var type: String:
	set(value):
		type = value
		type_label.text = type

@onready var type_label = %TypeLabel
@onready var copy_button = %CopyButton
@onready var timer = %Timer
@onready var code_edit = %CodeEdit

func _ready():
	code_edit.text = text
	type_label.text = type

func _on_copy_button_pressed():
	if !timer.is_stopped(): timer.stop()
	DisplayServer.clipboard_set(text)
	copy_button.text = TranslationServer.translate("COPIED_NAME")
	timer.start()

func _on_timer_timeout():
	copy_button.text = TranslationServer.translate("COPY_NAME")
