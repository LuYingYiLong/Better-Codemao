extends PanelContainer

@export var description_visible: bool:
	set(value):
		description_visible = value
		description_label.visible = description_visible
@export var user_visible: bool:
	set(value):
		user_visible = value
		line.visible = user_visible
		user_container.visible = user_visible

@onready var preview_texture = %PreviewTexture
@onready var work_name_label = %WorkNameLabel
@onready var description_label = %DescriptionLabel

@onready var view_praise_container = %"View&PraiseContainer"
@onready var view_times = %ViewTimes
@onready var praise_times = %PraiseTimes

@onready var line = %Line

@onready var user_container = %UserContainer
@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel

var id: int
	
func set_work_card_data(json: Dictionary) -> void:
	id = json.get("id")
	if json.has("work_name"):
		work_name_label.text = json.get("work_name")
		preview_texture.load_image(json.get("preview"), json.get("work_name"))
	elif json.has("name"):
		work_name_label.text = json.get("name")
		preview_texture.load_image(json.get("preview"), json.get("name"))
	description_label.text = json.get("description", "")
	if json.has("view_times"): view_times.text = str(int(json.get("view_times", "--")))
	elif json.has("views_count"): view_times.text = str(int(json.get("views_count", "--")))
	if json.has("praise_times"): praise_times.text = str(int(json.get("praise_times", "--")))
	elif json.has("liked_times"): praise_times.text = str(int(json.get("liked_times", "--")))
	elif json.has("likes_count"): praise_times.text = str(int(json.get("likes_count", "--")))
	var user: Dictionary = json.get("user", {})
	avatar_texture.load_image(user.get("avatar_url", ""), user.get("nickname", ""))
	nickname_label.text = user.get("nickname", "ERROR")

func jump_to_work_menu() -> void:
	Application.append_address.emit(work_name_label.text, \
			"res://Scenes/Work/WorkMenu.tscn", \
			{"id": id})

func _on_preview_texture_pressed() -> void:
	jump_to_work_menu()

func _on_card_pressed() -> void:
	jump_to_work_menu()
