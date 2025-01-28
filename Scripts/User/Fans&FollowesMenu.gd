extends Control

@onready var fans_request = %FansRequest
@onready var followers_request = %FollowersRequest

@onready var scroll_container = %ScrollContainer
@onready var fans_card_container = %FansCardContainer
@onready var pagination_bar = %PaginationBar

enum display_type{Fans, Followers}

const FANS_CARD_SCENE = preload("res://Scenes/User/FansCard.tscn")

const LOADS_NUMBER: int = 30

var user_id: int
var display_mode = display_type.Fans

func set_data(data: Dictionary) -> void:
	user_id = int(data.get("id"))
	display_mode = data.get("mode")
	if display_mode == display_type.Fans:
		fans_request.request("https://api.codemao.cn/creation-tools/v1/user/fans?user_id=%s&offset=0&limit=%s" %[user_id, LOADS_NUMBER], \
				[Application.generate_cookie_header()])
	elif display_mode == display_type.Followers:
		fans_request.request("https://api.codemao.cn/creation-tools/v1/user/followers?user_id=%s&offset=0&limit=%s" %[user_id, LOADS_NUMBER], \
				[Application.generate_cookie_header()])

func on_fans_or_fllowers_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json_class: JSON = JSON.new()
	if json_class.parse(body.get_string_from_utf8()) != OK:
		Application.emit_system_error_message("JSON parsing failed")
		return
	var json: Dictionary = json_class.data
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	pagination_bar.total = ceili(json.get("total") / LOADS_NUMBER)
	pagination_bar.update_pager_total()
	var items: Array = json.get("items")
	for node in fans_card_container.get_children():
		node.queue_free()
	for item: Dictionary in items:
		var fans_card_scene = FANS_CARD_SCENE.instantiate()
		fans_card_container.add_child(fans_card_scene)
		fans_card_scene.set_fans_card_data(item)

func _on_pagination_bar_page_changed(page) -> void:
	Application.scroll_to_top(scroll_container)
	if display_mode == display_type.Fans:
		fans_request.request("https://api.codemao.cn/creation-tools/v1/user/fans?user_id=%s&offset=%s&limit=%s" %[user_id, (page - 1) * LOADS_NUMBER, LOADS_NUMBER], \
				[Application.generate_cookie_header()])
	elif display_mode == display_type.Followers:
		fans_request.request("https://api.codemao.cn/creation-tools/v1/user/followers?user_id=%s&offset=%s&limit=%s" %[user_id, (page - 1) * LOADS_NUMBER, LOADS_NUMBER], \
				[Application.generate_cookie_header()])
