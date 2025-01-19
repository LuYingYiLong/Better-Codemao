extends Control

@onready var fanfic_type_request = %FanficTypeRequest
@onready var fanfic_recommend_request = %FanficRecommendRequest

@onready var fanfic_card_container = %FanficCardContainer

const FANFIC_CARD_SCENE = preload("res://Scenes/Library/FanficCard.tscn")

var fanfic_type_dict: Dictionary

func _ready():
	fanfic_type_request.request("https://api.codemao.cn/api/fanfic/type")

func _process(_delta):
	fanfic_card_container.columns = clampi(floori(fanfic_card_container.size.x / 170), 1, 999)

func _on_fanfic_type_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	var data: Dictionary = json.get("data")
	var fanfic_type_list: Array = data.get("fanficTypeList")
	fanfic_type_dict.clear()
	for fanfic_type: Dictionary in fanfic_type_list:
		var id = str(fanfic_type.get("id"))
		var _name = fanfic_type.get("name")
		fanfic_type_dict[id] = _name
	fanfic_recommend_request.request("https://api.codemao.cn/api/fanfic/list/recommend")

func _on_fanfic_recommend_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	var data: Dictionary = json.get("data")
	var fanfic_list: Array = data.get("fanficList")
	for node in fanfic_card_container.get_children():
		node.queue_free()
	for fanfic: Dictionary in fanfic_list:
		var fanfic_card_scene = FANFIC_CARD_SCENE.instantiate()
		fanfic_card_container.add_child(fanfic_card_scene)
		fanfic_card_scene.set_fanfic_card_data(fanfic)
		fanfic_card_scene.pressed.connect(_on_fanfic_card_scene)

func _on_fanfic_card_scene(id: int) -> void:
	Application.append_address.emit("FANFIC_NAME", \
			"res://Scenes/Library/FanficMenu.tscn", \
			{"id": id})
