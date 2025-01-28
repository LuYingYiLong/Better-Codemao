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
	if json.has("id"): id = int(json.get("id", 0))
	elif json.has("work_id"): id = int(json.get("work_id", 0))
	
	if json.has("work_name"): work_name_label.text = json.get("work_name")
	elif json.has("name"): work_name_label.text = json.get("name")
	
	if json.has("preview"): preview_texture.load_image(json.get("preview"), json.get("name", ""))
	elif json.has("preview_url"): preview_texture.load_image(json.get("preview_url"), json.get("name", ""))
	elif json.has("thumbnail"): preview_texture.load_image(json.get("thumbnail"), json.get("name"))
	elif json.has("cover_url"): preview_texture.load_image(json.get("cover_url"), json.get("name"))
	
	description_label.text = json.get("description", "--")
	
	if json.has("view_times"): view_times.text = str(int(json.get("view_times", "--")))
	elif json.has("views_count"): view_times.text = str(int(json.get("views_count", "--")))
	
	if json.has("praise_times"): praise_times.text = str(int(json.get("praise_times", "--")))
	elif json.has("liked_times"): praise_times.text = str(int(json.get("liked_times", "--")))
	elif json.has("likes_count"): praise_times.text = str(int(json.get("likes_count", "--")))
	
	var user: Dictionary = json.get("user", {})
	avatar_texture.load_image(user.get("avatar_url", ""), user.get("nickname", "ERROR"))
	nickname_label.text = user.get("nickname", "ERROR")

func jump_to_work_menu() -> void:
	Application.append_address.emit(work_name_label.text, \
			"res://Scenes/Work/WorkMenu.tscn", \
			{"id": id})

func _on_preview_texture_pressed() -> void:
	jump_to_work_menu()

func _on_card_pressed() -> void:
	jump_to_work_menu()
