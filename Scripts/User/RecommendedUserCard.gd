extends PanelContainer

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var description_label = %DescriptionLabel

var user_id: int

func set_recommended_user_card_data(data: Dictionary) -> void:
	user_id = int(data.get("user_id"))
	avatar_texture.load_image(data.get("avatar_url", ""), data.get("nickname"))
	nickname_label.text = data.get("nickname", "ERROR")
	description_label.text = data.get("description", "--")

func _on_card_pressed():
	Application.append_address.emit(nickname_label.text, \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": user_id})
