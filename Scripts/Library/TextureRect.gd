extends Control

@onready var fanfic_request = %FanficRequest
@onready var collect_request = %CollectRequest

@onready var cover_texture = %CoverTexture
@onready var collect_button = %CollectButton
@onready var collected_button = %CollectedButton
@onready var share_button = %ShareButton
@onready var title_label = %TitleLabel
@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var view_times_label = %ViewTimesLabel
@onready var collect_times_label = %CollectTimesLabel
@onready var total_words_label = %TotalWordsLabel
@onready var type_label = %TypeLabel
@onready var status_label = %StatusLabel
@onready var introduction = %Introduction

@onready var section_card_container = %SectionCardContainer

const SECTION_CARD_SCENE = preload("res://Scenes/Library/SectionCard.tscn")

var fanfic_id: int

func set_data(data: Dictionary) -> void:
	fanfic_request.request("https://api.codemao.cn/api/fanfic/%s" %data.get("id", 0), \
			[Application.generate_cookie_header()])

func _on_fanfic_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var data: Dictionary = json.get("data", {})
	var fanfic_info: Dictionary = data.get("fanficInfo", {})
	fanfic_id = int(fanfic_info.get("id", 0))
	cover_texture.load_image(fanfic_info.get("cover_pic", ""), fanfic_info.get("title", "ERROR"))
	collect_button.visible = !fanfic_info.get("collected", false)
	collected_button.visible = fanfic_info.get("collected", false)
	share_button.url = "https://shequ.codemao.cn/wiki/novel/cover/%s" %fanfic_id
	title_label.text = fanfic_info.get("title", "ERROR")
	avatar_texture.load_image(fanfic_info.get("avatar", ""))
	nickname_label.text = fanfic_info.get("nickname", "ERROR")
	view_times_label.text = str(int(fanfic_info.get("view_times", "--")))
	collect_times_label.text = str(int(fanfic_info.get("collect_times", "--")))
	total_words_label.text = str(int(fanfic_info.get("total_words", "--")))
	type_label.text = fanfic_info.get("fanfic_type_name", "--")
	var status: int = fanfic_info.get("status")
	match status:
		1: status_label.text = "%s: %s" %[TranslationServer.translate("STATUS_NAME"), TranslationServer.translate("SERIALIZED_NAME")]
		2: status_label.text = "%s: %s" %[TranslationServer.translate("STATUS_NAME"), TranslationServer.translate("DONE_NAME")]
	introduction.text = fanfic_info.get("introduction", "--")
	
	var section_list: Array = data.get("sectionList", [])
	for section: Dictionary in section_list:
		var section_card_scene = SECTION_CARD_SCENE.instantiate()
		section_card_container.add_child(section_card_scene)
		section_card_scene.set_section_card_data(section)
		section_card_scene.pressed.connect(_on_section_card_pressed)

func _on_collect_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	collect_button.disabled = false
	collected_button.disabled = false
	if int(json.get("code")) == 200:
		collect_button.visible = !collect_button.visible
		collected_button.visible = !collected_button.visible

func _on_read_button_pressed() -> void:
	Application.async_load_scene.emit("res://Scenes/FanficReader.tscn", {"fanfic_id": fanfic_id, "id": -1})

func _on_collect_button_pressed():
	collect_request.request("https://api.codemao.cn/web/fanfic/collect/%s" %fanfic_id, \
			[Application.generate_cookie_header()], \
			HTTPClient.METHOD_POST)
	collect_button.disabled = true

func _on_collected_button_pressed() -> void:
	collect_request.request("https://api.codemao.cn/web/fanfic/collect/%s" %fanfic_id, \
			[Application.generate_cookie_header()], \
			HTTPClient.METHOD_DELETE)
	collected_button.disabled = true

func _on_section_card_pressed(_fanfic_id: int, id: int) -> void:
	Application.async_load_scene.emit("res://Scenes/FanficReader.tscn", {"fanfic_id": _fanfic_id, "id": id})
