extends Control

@onready var text_edit = %TextEdit
@onready var next_button = %NextButton

@onready var animation_player = %AnimationPlayer

func set_data(data: Dictionary) -> void:
	text_edit.text = data.get("user_agreement", "")

func _on_next_button_pressed():
	var user_data: Dictionary = Application.load_json_file(Application.USER_DATA_PATH)
	user_data["version"] = ProjectSettings.get_setting("application/config/version")
	user_data["user_agreement"] = true
	Application.save_json_file(Application.USER_DATA_PATH, user_data)
	animation_player.play("Hide")

func _on_agree_user_agreement_check_box_toggled(toggled_on: bool) -> void:
	next_button.disabled = !toggled_on
