extends Control

@onready var simple_request = %SimpleRequest
@onready var shops_request = %ShopsRequest

@onready var go_to_button = %GoToButton

@onready var advanced_workshop_card_container = %AdvancedWorkshopCardContainer
@onready var upper_intermediate_workshop_card_container = %UpperIntermediateWorkshopCardContainer
@onready var lower_intermediate_workshop_card_container = %LowerIntermediateWorkshopCardContainer
@onready var elementary_workshop_card_container = %ElementaryWorkshopCardContainer
@onready var beginner_workshop_card_container = %BeginnerWorkshopCardContainer

const WORKSHOP_CARD_SCENE = preload("res://Scenes/Workshop/WorkshopCard.tscn")

var work_shop_name: String
var work_subject_id: int

func _ready():
	simple_request.request("https://api.codemao.cn/web/work_shops/simple", [Application.generate_cookie_header()], HTTPClient.METHOD_GET)
	shops_request.request("https://api.codemao.cn/web/shops?levels=0,1,2,3,4&max_number=4&works_limit=4&sort=-ordinal,-updated_at")

func _on_simple_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS: push_error("Could not get data")
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if !json.get("has_joined"):
		go_to_button.hide()
		return
	var work_shop: Dictionary = json.get("work_shop")
	work_subject_id = work_shop.get("work_subject_id")
	work_shop_name = work_shop.get("name")
	go_to_button.text = "   %s%s   " %[TranslationServer.translate("GO_TO_THE_NAME"), \
			work_shop_name]

func _on_go_to_button_pressed():
	Application.append_address.emit(work_shop_name, \
			"res://Scenes/Workshop/ShopMenu.tscn", \
			{"id": work_subject_id})

func _on_shops_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS: push_error("Could not get data")
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var items: Array = json.get("items")
	for node in beginner_workshop_card_container.get_children():
		node.queue_free()
	for node in elementary_workshop_card_container.get_children():
		node.queue_free()
	for node in lower_intermediate_workshop_card_container.get_children():
		node.queue_free()
	for node in upper_intermediate_workshop_card_container.get_children():
		node.queue_free()
	for node in advanced_workshop_card_container.get_children():
		node.queue_free()
	for item: Dictionary in items:
		var workshop_card_scene = WORKSHOP_CARD_SCENE.instantiate()
		var level: int = item.get("level")
		match level:
			0: beginner_workshop_card_container.add_child(workshop_card_scene)
			1: elementary_workshop_card_container.add_child(workshop_card_scene)
			2: lower_intermediate_workshop_card_container.add_child(workshop_card_scene)
			3: upper_intermediate_workshop_card_container.add_child(workshop_card_scene)
			4: advanced_workshop_card_container.add_child(workshop_card_scene)
			_: continue
		workshop_card_scene.set_workshop_card_data(item)
