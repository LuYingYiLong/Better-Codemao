extends Control

@onready var simple_request = %SimpleRequest
@onready var shops_request = %ShopsRequest

@onready var scroll_container = %ScrollContainer

@onready var go_to_button = %GoToButton

@onready var advanced_workshop_label = %AdvancedWorkshopLabel
@onready var advanced_workshop_card_container = %AdvancedWorkshopCardContainer
@onready var upper_intermediate_workshop_label = %UpperIntermediateWorkshopLabel
@onready var upper_intermediate_workshop_card_container = %UpperIntermediateWorkshopCardContainer
@onready var lower_intermediate_workshop_label = %LowerIntermediateWorkshopLabel
@onready var lower_intermediate_workshop_card_container = %LowerIntermediateWorkshopCardContainer
@onready var elementary_workshop_label = %ElementaryWorkshopLabel
@onready var elementary_workshop_card_container = %ElementaryWorkshopCardContainer
@onready var beginner_workshop_label = %BeginnerWorkshopLabel
@onready var beginner_workshop_card_container = %BeginnerWorkshopCardContainer
@onready var workshop_card_container = %WorkshopCardContainer

@onready var pagination_bar = %PaginationBar

enum status_type{Recommended, All, Lv0, Lv1, Lv2, Lv3, Lv4, Search}

const WORKSHOP_CARD_SCENE = preload("res://Scenes/Workshop/WorkshopCard.tscn")

const LOADS_NUMBER: int = 30

var work_shop_name: String
var work_subject_id: int
var search: String
var status = status_type.Recommended:
	set(value):
		status = value
		pagination_bar.current_page = 1
		pagination_bar.update_current_page()
		if status == status_type.Recommended: shops_request.request("https://api.codemao.cn/web/shops?levels=0,1,2,3,4&max_number=4&works_limit=4&sort=-ordinal,-updated_at")
		elif status == status_type.All: shops_request.request("https://api.codemao.cn/web/work-shops/search?&works_limit=4&offset=0&limit=%s&sort=-latest_joined_at,-created_at" %LOADS_NUMBER)
		elif status == status_type.Lv0: shops_request.request("https://api.codemao.cn/web/work-shops/search?level=0&works_limit=4&offset=0&limit=%s&sort=-latest_joined_at,-created_at" %LOADS_NUMBER)
		elif status == status_type.Lv1: shops_request.request("https://api.codemao.cn/web/work-shops/search?level=1&works_limit=4&offset=0&limit=%s&sort=-latest_joined_at,-created_at" %LOADS_NUMBER)
		elif status == status_type.Lv2: shops_request.request("https://api.codemao.cn/web/work-shops/search?level=2&works_limit=4&offset=0&limit=%s&sort=-latest_joined_at,-created_at" %LOADS_NUMBER)
		elif status == status_type.Lv3: shops_request.request("https://api.codemao.cn/web/work-shops/search?level=3&works_limit=4&offset=0&limit=%s&sort=-latest_joined_at,-created_at" %LOADS_NUMBER)
		elif status == status_type.Lv4: shops_request.request("https://api.codemao.cn/web/work-shops/search?level=4&works_limit=4&offset=0&limit=%s&sort=-latest_joined_at,-created_at" %LOADS_NUMBER)
		elif status == status_type.Search: shops_request.request("https://api.codemao.cn/web/work-shops/search?name=%s&works_limit=4&offset=0&limit=%s&sort=-latest_joined_at,-created_at" %[Application.string_to_hex(search), LOADS_NUMBER])
		for node in get_tree().get_nodes_in_group("Recommended"):
			node.visible = status == status_type.Recommended
		workshop_card_container.visible = status != status_type.Recommended

func _ready() -> void:
	simple_request.request("https://api.codemao.cn/web/work_shops/simple", [Application.generate_cookie_header()], HTTPClient.METHOD_GET)
	shops_request.request("https://api.codemao.cn/web/shops?levels=0,1,2,3,4&max_number=4&works_limit=4&sort=-ordinal,-updated_at")
	Settings.settings_config_update.connect(_on_settings_config_update)
	_on_settings_config_update()

func _on_simple_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
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

func _on_selector_bar_index_pressed(index: int) -> void:
	@warning_ignore("int_as_enum_without_cast")
	status = index

func _on_go_to_button_pressed() -> void:
	Application.append_address.emit(work_shop_name, \
			"res://Scenes/Workshop/ShopMenu.tscn", \
			{"id": work_subject_id})

func _on_shops_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json_class: JSON = JSON.new()
	if json_class.parse(body.get_string_from_utf8()) != OK:
		Application.emit_system_error_message("JSON parsing failed")
		return
	var json: Dictionary = json_class.data
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	pagination_bar.total = ceili(float(json.get("total")) / LOADS_NUMBER)
	pagination_bar.update_pager_total()
	pagination_bar.visible = pagination_bar.total > 1
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
	for node in workshop_card_container.get_children():
		node.queue_free()
	for item: Dictionary in items:
		var workshop_card_scene = WORKSHOP_CARD_SCENE.instantiate()
		if status == status_type.Recommended:
			var level: int = item.get("level")
			match level:
				0: beginner_workshop_card_container.add_child(workshop_card_scene)
				1: elementary_workshop_card_container.add_child(workshop_card_scene)
				2: lower_intermediate_workshop_card_container.add_child(workshop_card_scene)
				3: upper_intermediate_workshop_card_container.add_child(workshop_card_scene)
				4: advanced_workshop_card_container.add_child(workshop_card_scene)
				_: continue
		else:
			workshop_card_container.add_child(workshop_card_scene)
		workshop_card_scene.set_workshop_card_data(item)

func _on_auto_suggest_box_search_pressed(text: String) -> void:
	search = text
	status = status_type.Search

func _on_pagination_bar_page_changed(page: int) -> void:
	scroll_container.scroll_vertical = 0
	if status == status_type.All: shops_request.request("https://api.codemao.cn/web/work-shops/search?&works_limit=4&offset=%s&limit=%s&sort=-latest_joined_at,-created_at" %[(page - 1) * LOADS_NUMBER, LOADS_NUMBER])
	elif status == status_type.Lv0: shops_request.request("https://api.codemao.cn/web/work-shops/search?level=0&works_limit=4&offset=%s&limit=%s&sort=-latest_joined_at,-created_at" %[(page - 1) * LOADS_NUMBER, LOADS_NUMBER])
	elif status == status_type.Lv1: shops_request.request("https://api.codemao.cn/web/work-shops/search?level=1&works_limit=4&offset=%s&limit=%s&sort=-latest_joined_at,-created_at" %[(page - 1) * LOADS_NUMBER, LOADS_NUMBER])
	elif status == status_type.Lv2: shops_request.request("https://api.codemao.cn/web/work-shops/search?level=2&works_limit=4&offset=%s&limit=%s&sort=-latest_joined_at,-created_at" %[(page - 1) * LOADS_NUMBER, LOADS_NUMBER])
	elif status == status_type.Lv3: shops_request.request("https://api.codemao.cn/web/work-shops/search?level=3&works_limit=4&offset=%s&limit=%s&sort=-latest_joined_at,-created_at" %[(page - 1) * LOADS_NUMBER, LOADS_NUMBER])
	elif status == status_type.Lv4: shops_request.request("https://api.codemao.cn/web/work-shops/search?level=4&works_limit=4&offset=%s&limit=%s&sort=-latest_joined_at,-created_at" %[(page - 1) * LOADS_NUMBER, LOADS_NUMBER])
	elif status == status_type.Search: shops_request.request("https://api.codemao.cn/web/work-shops/search?name=%s&works_limit=4&offset=%s&limit=%s&sort=-latest_joined_at,-created_at" %[Application.string_to_hex(search), (page - 1) * LOADS_NUMBER, LOADS_NUMBER])

func _on_settings_config_update() -> void:
	if Settings.dark_mode == 0:
		advanced_workshop_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
		upper_intermediate_workshop_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
		lower_intermediate_workshop_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
		elementary_workshop_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
		beginner_workshop_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
	else:
		advanced_workshop_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
		upper_intermediate_workshop_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
		lower_intermediate_workshop_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
		elementary_workshop_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
		beginner_workshop_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
