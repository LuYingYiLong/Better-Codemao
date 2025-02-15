extends Control

@onready var fanfic_type_request = %FanficTypeRequest
@onready var fanfic_recommend_request = %FanficRecommendRequest
@onready var comic_request = %ComicRequest
@onready var faction_request = %FactionRequest

@onready var fanfic_card_container = %FanficCardContainer
@onready var comic_card_container = %ComicCardContainer
@onready var faction_card_container = %FactionCardContainer
@onready var pagination_bar = %PaginationBar

enum Type{FANFIC, COMIC, FACTION}

const MAX_QUANTITY: int = 20
const FANFIC_CARD_SCENE = preload("res://Scenes/Library/FanficCard.tscn")
const COMIC_CARD_SCENE = preload("res://Scenes/Library/ComicCard.tscn")
const FACTION_CARD_SCENE = preload("res://Scenes/Library/FactionCard.tscn")

var current_type: Type = Type.FANFIC:
	set(value):
		current_type = value
		pagination_bar.visible = current_type == Type.FANFIC
		for node in fanfic_card_container.get_children():
			node.queue_free()
		for node in comic_card_container.get_children():
			node.queue_free()
		faction_request.cancel_request()
		comic_request.cancel_request()
		match current_type:
			Type.FANFIC: fanfic_recommend_request.request("https://api.codemao.cn/api/fanfic/list/recommend")
			Type.COMIC: comic_request.request("https://api.codemao.cn/api/comic/list/all")
			Type.FACTION: faction_request.request("https://api.codemao.cn/api/sprite/list/all")
var fanfic_type_dict: Dictionary

func _ready():
	fanfic_type_request.request("https://api.codemao.cn/api/fanfic/type")

func _process(_delta):
	fanfic_card_container.columns = clampi(floori(fanfic_card_container.size.x / 170), 1, 999)
	faction_card_container.columns = clampi(floori(faction_card_container.size.x / 230), 1, 999)

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

func _on_tab_bar_index_pressed(index: int) -> void:
	match index:
		0: current_type = Type.FANFIC
		1: current_type = Type.COMIC
		2: current_type = Type.FACTION

func _on_fanfic_recommend_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var data: Dictionary = json.get("data")
	var fanfic_list: Array = data.get("fanficList")
	@warning_ignore("integer_division")
	pagination_bar.total = ceili(fanfic_list.size() / MAX_QUANTITY)
	pagination_bar.update_pager_total()
	pagination_bar.show()
	for _i in range((pagination_bar.current_page - 1) * MAX_QUANTITY):
		fanfic_list.remove_at(0)
	var count: int = 1
	for fanfic: Dictionary in fanfic_list:
		var fanfic_card_scene = FANFIC_CARD_SCENE.instantiate()
		fanfic_card_container.add_child(fanfic_card_scene)
		fanfic_card_scene.set_fanfic_card_data(fanfic)
		fanfic_card_scene.pressed.connect(_on_fanfic_card_scene)
		count += 1
		if count > MAX_QUANTITY: break

func _on_comic_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var data: Dictionary = json.get("data")
	var comic_list: Array = data.get("comicList")
	for comic: Dictionary in comic_list:
		var comic_card_scene = COMIC_CARD_SCENE.instantiate()
		comic_card_container.add_child(comic_card_scene)
		comic_card_scene.set_comic_card_data(comic)
		comic_card_scene.pressed.connect(_on_comic_card_pressed)

func _on_faction_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var data: Dictionary = json.get("data")
	var sprite_list: Array = data.get("sprite_list")
	for sprite: Dictionary in sprite_list:
		var faction_card_scene = FACTION_CARD_SCENE.instantiate()
		faction_card_container.add_child(faction_card_scene)
		faction_card_scene.set_faction_card_data(sprite)
		faction_card_scene.pressed.connect(_on_faction_card_pressed)

func _on_fanfic_card_scene(id: int) -> void:
	Application.append_address.emit("FANFIC_NAME", \
			"res://Scenes/Library/FanficMenu.tscn", \
			{"id": id, "type": 0})

func _on_comic_card_pressed(id: int) -> void:
	Application.append_address.emit("FANFIC_NAME", \
			"res://Scenes/Library/FanficMenu.tscn", \
			{"id": id, "type": 1})

func _on_faction_card_pressed(id: int) -> void:
	Application.append_address.emit("FACTION_NAME", \
			"res://Scenes/Library/FactionMenu.tscn", \
			{"id": id})

func _on_pagination_bar_page_changed(_page: int) -> void:
	fanfic_recommend_request.request("https://api.codemao.cn/api/fanfic/list/recommend")
