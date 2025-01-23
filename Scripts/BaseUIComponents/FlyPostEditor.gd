extends Control

@onready var post_request = %PostRequest

@onready var title_edit = %TitleEdit
@onready var content_edit = %ContentEdit
@onready var boards_box = %BoardsBox

@onready var animation_player = %AnimationPlayer

var board_id: int

func set_data(data: Dictionary) -> void:
	title_edit.text = data.get("title", "")
	content_edit.text = data.get("content", "")
	if data.has("boards"):
		var boards: Array = data.get("boards")
		boards.remove_at(0)
		for board: Dictionary in boards:
			var popup_item: PopupItem = PopupItem.new()
			popup_item.text = board.get("name", "ERROR")
			popup_item.metadata = int(board.get("id"))
			boards_box.items.append(popup_item)
		boards_box.update_selected_item()
		board_id = boards_box.items[0].metadata

func _on_boards_box_item_changed(item: PopupItem) -> void:
	board_id = item.metadata

func _on_cancel_button_pressed():
	animation_player.play("Hide")

func _on_publish_button_pressed():
	var headers: PackedStringArray = [Application.generate_cookie_header()]
	headers.append("content-type: Application/json;charset=UTF-8")
	var request_data: Dictionary = {
		"title": title_edit.text,
		"content": content_edit.text
	}
	post_request.request("https://api.codemao.cn/web/forums/boards/%s/posts" %board_id, \
			headers, \
			HTTPClient.METHOD_POST, \
			JSON.stringify(request_data))

func _on_post_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	
	if json.has("id"):
		Application.append_address.emit(title_edit.text, \
			"res://Scenes/Forum/PostMenu.tscn", \
			{"id": int(json.get("id"))})
		animation_player.play("Hide")
