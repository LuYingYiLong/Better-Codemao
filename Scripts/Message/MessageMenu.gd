extends Control

@onready var message_count_request = %MessageCountRequest
@onready var message_record_request = %MessageRecordRequest

@onready var progress_bar = %ProgressBar

@onready var tab_bar = %TabBar

@onready var message_card_container = %MessageCardContainer
@onready var load_more_button = %LoadMoreButton

const MESSAGE_CARD_SCENE = preload("res://Scenes/Message/MessageCard.tscn")

var comment_reply_count: int
var like_fork_count: int
var system_count: int

var query_type: String = "COMMENT_REPLY"

var limit: int = 0
var offset: int = 0

func _ready():
	message_count_request.request("https://api.codemao.cn/web/message-record/count", [Application.generate_cookie_header()], HTTPClient.METHOD_GET)
	_message_record_request()

func on_message_count_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json_class: JSON = JSON.new()
	if json_class.parse('{"query":%s}' %body.get_string_from_utf8()) != OK:
		Application.emit_system_error_message("JSON parsing failed")
		return
	var json: Dictionary = json_class.data
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	
	if result != HTTPRequest.RESULT_SUCCESS: push_error("Could not get data")
	for query: Dictionary in json.get("query"):
		if query.get("query_type") == "COMMENT_REPLY":
			comment_reply_count = query.get("count")
			tab_bar.tab_items[0].text = str(comment_reply_count)
		elif query.get("query_type") == "LIKE_FORK":
			like_fork_count = query.get("count")
			tab_bar.tab_items[1].text = str(like_fork_count)
		elif query.get("query_type") == "SYSTEM":
			system_count = query.get("count")
			tab_bar.tab_items[2].text = str(system_count)
	tab_bar.update_tab_data()

func _message_record_request(reload: bool = true):
	if reload:
		for node in message_card_container.get_children():
			node.queue_free()
	limit += 100
	if limit > 200:
		limit = 200
		offset += 100
	message_record_request.request("https://api.codemao.cn/web/message-record?query_type=%s&limit=%s&offset=%s" %[query_type, limit, offset], \
			[Application.generate_cookie_header()], HTTPClient.METHOD_GET)
	message_count_request.request("https://api.codemao.cn/web/message-record/count", \
			[Application.generate_cookie_header()], HTTPClient.METHOD_GET)
	progress_bar.show()

func on_message_record_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		progress_bar.progress_state = 2
		return
	progress_bar.hide()

	load_more_button.disabled = false
	var items: Array = json.get("items", [])
	if items.is_empty(): return
	for _i in range(limit - offset - 100):
		if items.size() > 0: items.remove_at(0)
	for item: Dictionary in items:
		var message_card_scene = MESSAGE_CARD_SCENE.instantiate()
		message_card_container.add_child(message_card_scene)
		message_card_scene.set_message_card_data(item)
	load_more_button.visible = limit <= json.get("total")

func _on_load_more_button_pressed():
	load_more_button.disabled = true
	_message_record_request(false)

func _on_tab_bar_index_pressed(index: int) -> void:
	limit = 0
	offset = 0
	if index == 0: query_type = "COMMENT_REPLY"
	elif index == 1: query_type = "LIKE_FORK"
	elif index == 2: query_type = "SYSTEM"
	_message_record_request()
