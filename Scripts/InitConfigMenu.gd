extends Control

@onready var tab_container = %TabContainer

@onready var post_request = %PostRequest
@onready var post_id_edit = %PostIDEdit
@onready var find_button = %FindButton
@onready var rich_text_label = %RichTextLabel

@onready var next_button = %NextButton

const MAX_ERROR_QUANTITY: int = 8

var post_id: int
var effective_post_id: int
var ok_count: int
var error_count: int

func _ready():
	tab_container.current_tab = 0
	post_request.request_completed.connect(on_post_received)

func on_post_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		find_button.disabled = false
		return
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if json.has("error_code") and ok_count == 0:
		find_button.disabled = false
		rich_text_label.add_text("Error")
		return
	elif json.has("error_code") and error_count < MAX_ERROR_QUANTITY:
		error_count += 1
		rich_text_label.add_text("Error count: %s\nPost ID: %s\n\n" %[error_count, post_id])
	elif !json.has("error_code"):
		error_count = 0
		effective_post_id = post_id
		rich_text_label.add_text("Error count: %s\nPost ID: %s\n\n" %[error_count, post_id])
	elif json.has("error_code") and ok_count > 0 and error_count >= MAX_ERROR_QUANTITY:
		next_button.disabled = false
		Application.save_effective_post_id(effective_post_id)
		rich_text_label.add_text("OK: %s" %effective_post_id)
		return
	post_id += 1
	ok_count += 1
	var url = "https://api.codemao.cn/web/forums/posts/%s/details" %post_id
	var headers = ["Content-Type: application/json"]
	post_request.request(url, headers, HTTPClient.METHOD_GET)

func _on_next_button_pressed():
	if tab_container.current_tab <= 1:
		tab_container.current_tab += 1
		match tab_container.current_tab:
			1:
				next_button.disabled = true

func _on_find_button_pressed():
	find_button.disabled = true
	rich_text_label.clear()
	ok_count = 0
	error_count = 0
	post_id = post_id_edit.text.to_int()
	var url = "https://api.codemao.cn/web/forums/posts/%s/details" %post_id
	var headers = ["Content-Type: application/json"]
	post_request.request(url, headers, HTTPClient.METHOD_GET)
