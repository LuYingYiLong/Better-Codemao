extends Control

@onready var boards_request = %BoardsRequest
@onready var all_request = %AllRequest

@onready var post_card_container = %PostCardContainer

@onready var forum_board_card_container = %ForumBoardCardContainer

const POST_CARD_SCENE = preload("res://Scenes/Forum/PostCard.tscn")
const FORUM_BOARD_CARD_SCENE = preload("res://Scenes/Forum/ForumBoardCard.tscn")

func _ready():
	boards_request.request_completed.connect(on_boards_received)
	all_request.request_completed.connect(on_all_received)
	var headers = ["Content-Type: application/json"]
	for node in forum_board_card_container.get_children():
		node.queue_free()
	boards_request.request("https://api.codemao.cn/web/forums/boards/simples/all", headers, HTTPClient.METHOD_GET)
	for node in post_card_container.get_children():
		node.queue_free()
	all_request.request("https://api.codemao.cn/web/forums/posts/hots/all")

func on_boards_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	var items: Array = json.get("items")
	for item: Dictionary in items:
		var forum_board_card_scene = FORUM_BOARD_CARD_SCENE.instantiate()
		forum_board_card_container.add_child(forum_board_card_scene)
		forum_board_card_scene.set_forum_board_card_data(item)

func on_all_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	var items: Array = json.get("items")
	var count: int = -1
	for post_id: String in items:
		if count >= 20: break
		count += 1
		var post_card_scene = POST_CARD_SCENE.instantiate()
		post_card_container.add_child(post_card_scene)
		post_card_scene.set_post_card_id(post_id)
		post_card_scene.pressed.connect(on_post_card_scene_pressed)

func on_posts_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	if json.has("error_code"): return
	var post_card_scene = POST_CARD_SCENE.instantiate()
	post_card_container.add_child(post_card_scene)
	post_card_scene.set_post_card_data(json)
	post_card_scene.pressed.connect(on_post_card_scene_pressed)

func on_post_card_scene_pressed(data: Dictionary):
	Application.append_address.emit(TranslationServer.translate("POST_NAME"), \
			"res://Scenes/Forum/PostMenu.tscn", \
			data)
