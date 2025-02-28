extends Control

@onready var fanfic_request = %FanficRequest
@onready var comic_request = %ComicRequest
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
@onready var comic_tag_container = %ComicTagContainer
@onready var status_label = %StatusLabel
@onready var introduction = %Introduction

@onready var section_card_container = %SectionCardContainer

const SECTION_CARD_SCENE = preload("res://Scenes/Library/SectionCard.tscn")
const COMIC_TAG_SCENE = preload("res://Scenes/Library/ComicTag.tscn")

var type: int
var fanfic_id: int
var comic_id: int

func set_data(data: Dictionary) -> void:
	type = data.get("type", 0)
	match type:
		0:
			for node in get_tree().get_nodes_in_group("only_comic"):
				node.hide()
			fanfic_request.request("https://api.codemao.cn/api/fanfic/%s" %data.get("id", 0), [Application.generate_cookie_header()])
		1:
			for node in get_tree().get_nodes_in_group("only_fanfic"):
				node.hide()
			comic_request.request("https://api.codemao.cn/api/comic/%s" %data.get("id", 0), [Application.generate_cookie_header()])

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
		2: status_label.text = "%s: %s" %[TranslationServer.translate("STATUS_NAME"), TranslationServer.translate("ENDED_NAME")]
	introduction.text = fanfic_info.get("introduction", "--")
	
	var section_list: Array = data.get("sectionList", [])
	for section: Dictionary in section_list:
		var section_card_scene = SECTION_CARD_SCENE.instantiate()
		section_card_container.add_child(section_card_scene)
		section_card_scene.set_section_card_data(section, 0)
		section_card_scene.pressed.connect(_on_section_card_pressed)

func _on_comic_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var data: Dictionary = json.get("data", {})
	var comic_info: Dictionary = data.get("comic", {})
	comic_id = comic_info.get("id", 0)
	cover_texture.load_image(comic_info.get("cover_pic", ""), comic_info.get("title", "ERROR"))
	share_button.url = "https://shequ.codemao.cn/wiki/cartoon/cover/%s" %comic_id
	title_label.text = comic_info.get("title", "ERROR")
	nickname_label.text = comic_info.get("nickname", "ERROR")
	view_times_label.text = str(int(comic_info.get("view_times", "--")))
	for tag: String in comic_info.get("label_list", []):
		var comic_tag_scene = COMIC_TAG_SCENE.instantiate()
		comic_tag_container.add_child(comic_tag_scene)
		comic_tag_scene.set_tag(tag)
	var status: int = comic_info.get("status")
	match status:
		1: status_label.text = "%s: %s" %[TranslationServer.translate("STATUS_NAME"), TranslationServer.translate("SERIALIZED_NAME")]
		2: status_label.text = "%s: %s" %[TranslationServer.translate("STATUS_NAME"), TranslationServer.translate("ENDED_NAME")]
	introduction.text = comic_info.get("introduction", "--")
	
	var comic_section_list: Array = comic_info.get("comicSectionList", [])
	for section: Dictionary in comic_section_list:
		var section_card_scene = SECTION_CARD_SCENE.instantiate()
		section_card_container.add_child(section_card_scene)
		section_card_scene.set_section_card_data(section, 1)
		section_card_scene.pressed.connect(_on_section_card_pressed)

func _on_collect_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	collect_button.disabled = false
	collected_button.disabled = false
	if int(json.get("code")) == 200:
		collect_button.visible = !collect_button.visible
		collected_button.visible = !collected_button.visible

func _on_read_button_pressed() -> void:
	match type:
		0: Application.async_load_scene.emit("res://Scenes/FanficReader.tscn", {"fanfic_id": fanfic_id, "id": -1, "type": type})
		1: Application.async_load_scene.emit("res://Scenes/FanficReader.tscn", {"comic_id": comic_id, "id": -1, "type": type})

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

func _on_section_card_pressed(work_id: int, id: int) -> void:
	match type:
		0: Application.async_load_scene.emit("res://Scenes/FanficReader.tscn", {"fanfic_id": work_id, "id": id, "type": type})
		1: Application.async_load_scene.emit("res://Scenes/FanficReader.tscn", {"comic_id": work_id, "id": id, "type": type})
