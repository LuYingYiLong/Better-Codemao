extends Control

@onready var recommended_works_request = %RecommendedWorksRequest
@onready var new_works_request = %NewWorksRequest
@onready var recommended_users_request = %RecommendedUsersRequest
@onready var recommended_fanfics_request = %RecommendedFanficsRequest

@onready var recommended_works_container = %RecommendedWorksContainer
@onready var new_works_container = %NewWorksContainer
@onready var recommended_users_container = %RecommendedUsersContainer
@onready var recommended_fanfics_container = %RecommendedFanficsContainer

const WORK_CARD_SCENE = preload("res://Scenes/Work/WorkCard.tscn")
const RECOMMENDED_USER_CARD_SCENE = preload("res://Scenes/User/RecommendedUserCard.tscn")
const V_FANFIC_CARD_SCENE = preload("res://Scenes/Library/VFanficCard.tscn")

func _ready():
	recommended_works_request.request("https://api.codemao.cn/creation-tools/v1/pc/home/recommend-work?type=1")
	new_works_request.request("https://api.codemao.cn/creation-tools/v1/pc/home/recommend-work?type=2")
	recommended_users_request.request("https://api.codemao.cn/web/users/recommended")
	recommended_fanfics_request.request("https://api.codemao.cn/web/fanfic/index-list?limit=4")

func _process(_delta):
	@warning_ignore("integer_division")
	var columns: int = clampi(floori((size.x - 80) / 172), 1, 999)
	var recommended_fanfics_container_columns: int =  clampi(floori((size.x - 80) / 370), 1, 999)
	recommended_works_container.columns = columns
	new_works_container.columns = columns
	recommended_users_container.columns = columns
	recommended_fanfics_container.columns = recommended_fanfics_container_columns

func _on_recommended_works_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())

	for node in recommended_works_container.get_children():
		node.queue_free()
	var items: Array = json.get("array")
	for item: Dictionary in items:
		var work_card_scene = WORK_CARD_SCENE.instantiate()
		recommended_works_container.add_child(work_card_scene)
		work_card_scene.description_visible = false
		work_card_scene.set_work_card_data(item)

func _on_new_works_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())

	for node in new_works_container.get_children():
		node.queue_free()
	var items: Array = json.get("array")
	for item: Dictionary in items:
		var work_card_scene = WORK_CARD_SCENE.instantiate()
		new_works_container.add_child(work_card_scene)
		work_card_scene.description_visible = false
		work_card_scene.set_work_card_data(item)

func _on_recommended_users_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())

	for node in new_works_container.get_children():
		node.queue_free()
	var items: Array = json.get("items", [])
	for item: Dictionary in items:
		var recommended_user_card_scene = RECOMMENDED_USER_CARD_SCENE.instantiate()
		recommended_users_container.add_child(recommended_user_card_scene)
		recommended_user_card_scene.set_recommended_user_card_data(item)


func _on_recommended_fanfics_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())

	for node in recommended_fanfics_container.get_children():
		node.queue_free()
	var items: Array = json.get("array", [])
	for item: Dictionary in items:
		var v_fanfic_card_scene = V_FANFIC_CARD_SCENE.instantiate()
		recommended_fanfics_container.add_child(v_fanfic_card_scene)
		v_fanfic_card_scene.set_v_fanfic_card_data(item)
