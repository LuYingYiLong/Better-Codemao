extends Control

@onready var all_request = %AllRequest
@onready var collection_works_request = %CollectionWorksRequest
@onready var kitten_n_request = %KittenNRequest
@onready var kitten_4_request = %Kitten4Request
@onready var kitten_3_request = %Kitten3Request
@onready var nemo_request = %NemoRequest
@onready var coco_request = %CoCoRequest
@onready var turtle_editor_request = %TurtleEditorRequest
@onready var the_code_island_request = %TheCodeIslandRequest
@onready var fanfic_request = %FanficRequest

@onready var scroll_container = %ScrollContainer
@onready var selector_bar = %SelectorBar
@onready var work_card_container = %WorkCardContainer
@onready var pagination_bar = %PaginationBar

enum Type{ALL = 0, COLLECT = 1, KITTENN = 2, KITTEN4 = 3, KITTEN3 = 4, NEMO = 5, COCO = 6, TURTLE_EDITOR = 7, THE_CODE_ISLAND = 8, FANFIC = 9}

const WORK_CARD_SCENE = preload("res://Scenes/Work/WorkCard.tscn")
const FANFIC_CARD_SCENE = preload("res://Scenes/Library/FanficCard.tscn")
const LOAD_QUANTITY: int = 30

var current_type: Type
var user_id: int

func set_data(data: Dictionary) -> void:
	user_id = data.get("id", 0)
	current_type = data.get("type", 0)
	selector_bar.current_item = current_type
	jump_to(current_type, 1)

func _process(_delta):
	@warning_ignore("narrowing_conversion")
	var columns: int = clampi((size.x - 64) / 168, 1, 999)
	work_card_container.columns = columns

func _on_selector_bar_index_pressed(index: int) -> void:
	Application.scroll_to_top(scroll_container)
	pagination_bar.current_page = 1
	pagination_bar.update_current_page()
	@warning_ignore("int_as_enum_without_cast")
	current_type = index
	jump_to(current_type, pagination_bar.current_page)

func jump_to(type: Type, page: int) -> void:
	match type:
		Type.ALL: all_request.request("https://api.codemao.cn/creation-tools/v2/user/center/work-list?type=newest&user_id=%s&offset=%s&limit=%s" %[user_id, (page - 1) * LOAD_QUANTITY, LOAD_QUANTITY])
		Type.COLLECT: collection_works_request.request("https://api.codemao.cn/creation-tools/v2/user/center/collect/list?user_id=%s&offset=%s&limit=%s" %[user_id, (page - 1) * LOAD_QUANTITY, LOAD_QUANTITY])
		Type.KITTENN: kitten_n_request.request("https://api-creation.codemao.cn/neko/works/v2/list/user?name=&limit=%s&offset=%s&status=1&work_business_classify=1" %[LOAD_QUANTITY, (page - 1) * LOAD_QUANTITY], [Application.generate_cookie_header()])
		Type.KITTEN4: kitten_4_request.request("https://api-creation.codemao.cn/kitten/common/work/list2?offset=%s&limit=%s&version_no=KITTEN_V4&work_status=SHOW&published_status=all" %[(page - 1) * LOAD_QUANTITY, LOAD_QUANTITY], [Application.generate_cookie_header()])
		Type.KITTEN3: kitten_3_request.request("https://api-creation.codemao.cn/kitten/common/work/list2?offset=%s&limit=%s&version_no=KITTEN_V3&work_status=SHOW&published_status=all" %[(page - 1) * LOAD_QUANTITY, LOAD_QUANTITY], [Application.generate_cookie_header()])
		Type.NEMO: nemo_request.request("https://api.codemao.cn/creation-tools/v1/works/list?offset=%s&limit=%s&published_status=all" %[(page - 1) * LOAD_QUANTITY, LOAD_QUANTITY], [Application.generate_cookie_header()])
		Type.COCO: coco_request.request("https://api-creation.codemao.cn/coconut/web/work/list?status=1&offset=%s&limit=%s" %[(page - 1) * LOAD_QUANTITY, LOAD_QUANTITY], [Application.generate_cookie_header()])
		Type.TURTLE_EDITOR: turtle_editor_request.request("https://api-creation.codemao.cn/wood/user/project/search?query=&page=%s&limit=%s&language_type=0" %[page, LOAD_QUANTITY], [Application.generate_cookie_header()])
		Type.THE_CODE_ISLAND: the_code_island_request.request("https://api-creation.codemao.cn/box/v2/work/list?offset=%s&limit=%s&work_status=SHOW&published_status=all" %[(page - 1) * LOAD_QUANTITY, LOAD_QUANTITY], [Application.generate_cookie_header()])
		Type.FANFIC: fanfic_request.request("https://api.codemao.cn/web/fanfic/my/new?offset=%s&limit=%s&fiction_status=SHOW" %[(page - 1) * LOAD_QUANTITY, LOAD_QUANTITY], [Application.generate_cookie_header()])

func populate_work(items: Array, total: int) -> void:
	pagination_bar.total = ceili(float(total) / LOAD_QUANTITY)
	pagination_bar.update_pager_total()
	pagination_bar.visible = pagination_bar.total > 1
	for node in work_card_container.get_children():
		node.queue_free()
	for item: Dictionary in items:
		if current_type == Type.FANFIC:
			var fanfic_card_scene = FANFIC_CARD_SCENE.instantiate()
			work_card_container.add_child(fanfic_card_scene)
			fanfic_card_scene.set_fanfic_card_data(item)
		else:
			var work_card_scene = WORK_CARD_SCENE.instantiate()
			work_card_container.add_child(work_card_scene)
			work_card_scene.user_visible = false
			work_card_scene.set_work_card_data(item)

func _on_all_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	populate_work(json.get("items", []), int(json.get("total", 0)))

func _on_collection_works_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	populate_work(json.get("items", []), int(json.get("total", 0)))

func _on_kitten_n_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	populate_work(json.get("items", []), int(json.get("total", 0)))

func _on_kitten_4_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	populate_work(json.get("items", []), int(json.get("total", 0)))

func _on_kitten_3_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	populate_work(json.get("items", []), int(json.get("total", 0)))

func _on_nemo_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	populate_work(json.get("items", []), int(json.get("total", 0)))

func _on_coco_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	populate_work(json.get("data", {}).get("items", []), int(json.get("data", {}).get("total", 0)))

func _on_turtle_editor_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	populate_work(json.get("array", []), json.get("array", []).size())

func _on_the_code_island_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	populate_work(json.get("items", []), int(json.get("total", 0)))

func _on_fanfic_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	populate_work(json.get("items", []), int(json.get("total", 0)))

func _on_pagination_bar_page_changed(page: int) -> void:
	Application.scroll_to_top(scroll_container)
	jump_to(current_type, page)
