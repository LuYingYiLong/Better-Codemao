extends Control

@onready var boards_request = %BoardsRequest
@onready var all_request = %AllRequest
@onready var board_request = %BoardRequest
@onready var mine_posts_request = %MinePostsRequest
@onready var mine_replied_request = %MineRepliedRequest
@onready var scroll_container = %ScrollContainer

@onready var board_name_label = %BoardNameLabel
@onready var posts_progress_bar = %PostsProgressBar
@onready var post_card_container = %PostCardContainer
@onready var pagination_bar = %PaginationBar

@onready var mine_posts_total = %MinePostsTotal
@onready var mine_replied_total = %MineRepliedTotal
@onready var history_total = %HistoryTotal

@onready var forum_board_card_container = %ForumBoardCardContainer

enum status_type{Forum, Board, MinePosts, MineReplied, History}

const POST_CARD_SCENE = preload("res://Scenes/Forum/PostCard.tscn")
const BASE_BUTTON_SCENE = preload("res://Scenes/BaseUIComponents/BaseButton.tscn")

const LOADS_NUMBER: int = 30

var boards_customized_res: Dictionary = {
	"17": {
		"name": TranslationServer.translate("POPULAR_ACTIVITIES_NAME")
	},
	"2": {
		"name": TranslationServer.translate("CODING_PARADISE_NAME")
	},
	"10": {
		"name": TranslationServer.translate("WORKSHOP_MASTER_APPRENTICE_NAME")
	},
	"5": {
		"name": TranslationServer.translate("YOU_ASK_I_ANSWER_NAME")
	},
	"3": {
		"name": TranslationServer.translate("THE_CODE_ISLAND_NAME")
	},
	"6": {
		"name": TranslationServer.translate("LIBRARY_NAME")
	},
	"27": {
		"name": TranslationServer.translate("COCO_APP_AUTHORING_NAME")
	},
	"11": {
		"name": TranslationServer.translate("PYTHON_PARADISE_NAME")
	},
	"26": {
		"name": TranslationServer.translate("THE_CODE_SPRITE_NAME")
	},
	"13": {
		"name": TranslationServer.translate("THE_NOC_MATCH_NAME")
	},
	"7": {
		"name": TranslationServer.translate("CHATTING_SQUARE_NAME")
	},
	"4": {
		"name": TranslationServer.translate("THE_TOWER_OF_BABEL_NAME")
	},
	"28": {
		"name": TranslationServer.translate("PROGRAMMER_CLASSROOM_NAME")
	}
}
var boards_data: Dictionary
var board_id: String
var status = status_type.Forum:
	set(value):
		status = value
		if status == status_type.Forum:
			pagination_bar.current_page = 1
			pagination_bar.update_current_page()
			load_forum()
		elif status == status_type.History:
			pagination_bar.current_page = 1
			pagination_bar.update_current_page()
			load_history()

func _ready() -> void:
	var headers = ["Content-Type: application/json"]
	boards_request.request("https://api.codemao.cn/web/forums/boards/simples/all", headers, HTTPClient.METHOD_GET)
	load_forum()
	if !Application.logged_in: Application.user_avatar_update.connect(on_user_avatar_update)
	else: on_user_avatar_update()
	if !FileAccess.file_exists(Application.FORUM_HISTORY_PATH):
		Application.save_json_file(Application.FORUM_HISTORY_PATH, {"items": []})
		history_total.text = "0"
	else:
		var forum_history: Dictionary = Application.load_json_file(Application.FORUM_HISTORY_PATH)
		var items: Array = forum_history.get("items", [])
		history_total.text = str(items.size())

func load_forum() -> void:
	all_request.request("https://api.codemao.cn/web/forums/posts/hots/all")

func load_history() -> void:
	scroll_container.scroll_vertical = 0
	var forum_history: Dictionary = Application.load_json_file(Application.FORUM_HISTORY_PATH)
	var items: Array = forum_history.get("items", [])
	@warning_ignore("integer_division")
	pagination_bar.total = ceili(items.size() / LOADS_NUMBER)
	pagination_bar.update_pager_total()
	pagination_bar.visible = pagination_bar.total > 0
	for _i in range((pagination_bar.current_page - 1) * LOADS_NUMBER):
		items.remove_at(0)
	for node in post_card_container.get_children():
		node.queue_free()
	var count: int = -1
	for item: Dictionary in items:
		if count >= LOADS_NUMBER: break
		count += 1
		var post_card_scene = POST_CARD_SCENE.instantiate()
		post_card_container.add_child(post_card_scene)
		post_card_scene.set_post_card_data(item)
		post_card_scene.pressed.connect(on_post_card_scene_pressed)

func on_user_avatar_update() -> void:
	mine_posts_request.request("https://api.codemao.cn/web/forums/posts/mine/created?page=1&limit=20", [Application.generate_cookie_header()])
	mine_replied_request.request("https://api.codemao.cn/web/forums/posts/mine/replied?page=1&limit=20", [Application.generate_cookie_header()])

func on_boards_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	var items: Array = json.get("items")
	items.insert(0, {"id": "0", "name": TranslationServer.translate("FORUM_SQUARE_NAME")})
	boards_data = json
	for node in forum_board_card_container.get_children():
		node.queue_free()
	for item: Dictionary in items:
		var base_button_scene = BASE_BUTTON_SCENE.instantiate()
		forum_board_card_container.add_child(base_button_scene)
		base_button_scene.add_to_group("Boards")
		if boards_customized_res.has(item.get("id")):
			var key: String = item.get("id")
			if boards_customized_res.get(key).has("icon"): base_button_scene.icon = load(boards_customized_res.get(key).get("icon"))
			base_button_scene.text = boards_customized_res.get(key).get("name")
		else:
			base_button_scene.text = item.get("name")
		base_button_scene.group = "Boards"
		base_button_scene.metadata = {"id": item.get("id"), "name": base_button_scene.text}
		base_button_scene.metadata_output.connect(_on_board_button_metadata_output)

func _on_board_button_metadata_output(metadata: Dictionary) -> void:
	board_id = metadata.get("id")
	board_name_label.text = metadata.get("name")
	scroll_container.scroll_vertical = 0
	pagination_bar.current_page = 1
	pagination_bar.update_current_page()
	if board_id == "0":
		status = status_type.Forum
		_on_pagination_bar_page_changed(1)
	else:
		status = status_type.Board
		board_request.request("https://api.codemao.cn/web/forums/boards/%s/posts?page=1&limit=%s" %[board_id, LOADS_NUMBER])

func on_all_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	for node in post_card_container.get_children():
		node.queue_free()
	pagination_bar.total = ceili(json.get("items").size() / LOADS_NUMBER)
	pagination_bar.update_pager_total()
	pagination_bar.visible = pagination_bar.total > 0
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

func _on_pagination_bar_page_changed(page: int) -> void:
	scroll_container.scroll_vertical = 0
	if status == status_type.Forum:
		all_request.request("https://api.codemao.cn/web/forums/posts/hots/all")
	elif status == status_type.Board:
		board_request.request("https://api.codemao.cn/web/forums/boards/%s/posts?page=%s&limit=%s" %[board_id, page, LOADS_NUMBER])

func _on_board_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	for node in post_card_container.get_children():
		node.queue_free()
	pagination_bar.total = ceili(json.get("total") / LOADS_NUMBER)
	pagination_bar.update_pager_total()
	pagination_bar.visible = pagination_bar.total > 0
	var items: Array = json.get("items")
	for item: Dictionary in items:
		var post_card_scene = POST_CARD_SCENE.instantiate()
		post_card_container.add_child(post_card_scene)
		post_card_scene.set_post_card_data(item)
		post_card_scene.pressed.connect(on_post_card_scene_pressed)

func _on_mine_posts_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	if mine_posts_request.progress_bar == null:
		mine_posts_request.progress_bar = posts_progress_bar.get_path()
		mine_posts_total.text = str(json.get("total", 0))
	var items: Array = json.get("items")

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

func on_post_card_scene_pressed(data: Dictionary) -> void:
	var forum_history: Dictionary = Application.load_json_file(Application.FORUM_HISTORY_PATH)
	var items: Array = forum_history.get("items", [])
	items.insert(0, data)
	#检查items是否有和该帖子ID相匹配的item，若有则删除
	if items.size() >= 2:
		var index: int = 1
		for _i in range(items.size() - 2):
			var id: String = items[index].get("id", "")
			if id == data.get("id"): items.remove_at(index)
			index += 1
	if items.size() > 100: items.resize(100)
	forum_history["items"] = items
	Application.save_json_file(Application.FORUM_HISTORY_PATH, forum_history)
	history_total.text = str(items.size())
	Application.append_address.emit(data.get("title"), \
			"res://Scenes/Forum/PostMenu.tscn", \
			data)

func _on_history_gui_input(event) -> void:
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		status = status_type.History
