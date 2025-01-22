extends PanelContainer

@onready var follow_request = %FollowRequest

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var description_label = %DescriptionLabel
@onready var total_likes_label = %TotalLikesLabel
@onready var total_works_label = %TotalWorksLabel

@onready var follow_button = %FollowButton
@onready var followed_button = %FollowedButton

var data: Dictionary

func set_fans_card_data(json: Dictionary) -> void:
	data = json
	avatar_texture.load_image(data.get("avatar_url"))
	nickname_label.text = data.get("nickname")
	description_label.text = data.get("description")
	total_likes_label.text = str(int(data.get("total_likes")))
	total_works_label.text = str(int(data.get("n_works")))
	follow_button.visible = !data.get("is_followed")
	followed_button.visible = data.get("is_followed")

func _on_avatar_gui_input(event) -> void:
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		Application.append_address.emit(data.get("nickname"), \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": data.get("id")})

func _on_follow_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS and body.get_string_from_utf8().is_empty(): return
	follow_button.disabled = false
	followed_button.disabled = false
	follow_button.visible = not follow_button.visible
	followed_button.visible = not followed_button.visible

func _on_follow_button_pressed() -> void:
	follow_request.request("https://api.codemao.cn/nemo/v2/user/%s/follow" %data.get("id"), \
				[Application.generate_cookie_header()], \
				HTTPClient.METHOD_POST)
	follow_button.disabled = true

func _on_followed_button_pressed() -> void:
	follow_request.request("https://api.codemao.cn/nemo/v2/user/%s/follow" %data.get("id"), \
				[Application.generate_cookie_header()], \
				HTTPClient.METHOD_DELETE)
	followed_button.disabled = true
