extends Control

@onready var boards_request = %BoardsRequest
@onready var all_request = %AllRequest
@onready var mine_posts_request = %MinePostsRequest
@onready var mine_replied_request = %MineRepliedRequest
@onready var scroll_container = %ScrollContainer

@onready var posts_progress_bar = %PostsProgressBar
@onready var post_card_container = %PostCardContainer
@onready var pagination_bar = %PaginationBar

@onready var mine_posts_total = %MinePostsTotal
@onready var mine_replied_total = %MineRepliedTotal

@onready var forum_board_card_container = %ForumBoardCardContainer

const POST_CARD_SCENE = preload("res://Scenes/Forum/PostCard.tscn")
const FORUM_BOARD_CARD_SCENE = preload("res://Scenes/Forum/ForumBoardCard.tscn")

const LOADS_NUMBER: int = 30

func _ready() -> void:
	var headers = ["Content-Type: application/json"]
	for node in forum_board_card_container.get_children():
		node.queue_free()
	boards_request.request("https://api.codemao.cn/web/forums/boards/simples/all", headers, HTTPClient.METHOD_GET)
	all_request.request("https://api.codemao.cn/web/forums/posts/hots/all")
	if !Application.logged_in: Application.user_avatar_update.connect(on_user_avatar_update)
	else: on_user_avatar_update()

func on_user_avatar_update() -> void:
	mine_posts_request.request("https://api.codemao.cn/web/forums/posts/mine/created?page=1&limit=20", [Application.generate_cookie_header()])
	mine_replied_request.request("https://api.codemao.cn/web/forums/posts/mine/replied?page=1&limit=20", [Application.generate_cookie_header()])

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

	for node in post_card_container.get_children():
		node.queue_free()
	pagination_bar.total = ceili(json.get("items").size() / LOADS_NUMBER)
	pagination_bar.update_pager_total()
	var items: Array = json.get("items")
	for _i in range((pagination_bar.current_page - 1) * LOADS_NUMBER):
		items.remove_at(0)
	var count: int = -1
	for post_id: String in items:
		if count >= LOADS_NUMBER: break
		count += 1
		var post_card_scene = POST_CARD_SCENE.instantiate()
		post_card_container.add_child(post_card_scene)
		post_card_scene.set_post_card_id(post_id)
		post_card_scene.pressed.connect(on_post_card_scene_pressed)

func _on_pagination_bar_page_changed(_page: int) -> void:
	scroll_container.scroll_vertical = 0
	all_request.request("https://api.codemao.cn/web/forums/posts/hots/all")

func _on_mine_posts_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	if mine_posts_request.progress_bar == null:
		mine_posts_request.progress_bar = posts_progress_bar.get_path()
		mine_posts_total.text = str(json.get("total", 0))

func _on_mine_replied_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	if mine_replied_request.progress_bar == null:
		mine_replied_request.progress_bar = posts_progress_bar.get_path()
		mine_replied_total.text = str(json.get("total", 0))

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
	Application.append_address.emit(data.get("title"), \
			"res://Scenes/Forum/PostMenu.tscn", \
			data)
