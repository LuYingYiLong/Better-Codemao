extends Window

@export_multiline var url: String:
	set(value):
		url = value
		url_label.text = url
		qr_code_rect.data = url
@export_group("Other")
@export var url_label: LineEdit
@export var qr_code_rect: QRCodeRect
@onready var animation_player = %AnimationPlayer

func _on_visibility_changed():
	if visible == true: animation_player.play("Show")

func _on_copy_button_pressed():
	DisplayServer.clipboard_set(url)

func _on_close_requested():
	visible = false

func _on_focus_exited():
	visible = false
