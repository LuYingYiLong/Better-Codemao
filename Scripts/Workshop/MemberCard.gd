extends PanelContainer

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var manager_info = %ManagerInfo
@onready var sub_manager_info = %SubManagerInfo

signal pressed(nick_name: String, user_id: int)

var user_id: int

func set_member_card_data(data: Dictionary) -> void:
	user_id = data.get("id")
	avatar_texture.load_image(data.get("avatar_url"), data.get("name"))
	nickname_label.text = data.get("name")
	var pos: String = data.get("position")
	manager_info.visible = pos == "LEADER"
	sub_manager_info.visible = pos == "DEPUTYLEADER"

func _on_button_pressed() -> void:
	pressed.emit(nickname_label.text, user_id)
