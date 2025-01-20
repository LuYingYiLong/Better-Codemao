extends Control

@onready var section_request = %SectionRequest
@onready var fanfic_request = %FanficRequest

@onready var drop_down_button = %DropDownButton
@onready var title_label = %TitleLabel
@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var content_label = %ContentLabel

var user_id: int
var fanfic_id: int
var id: int

func set_data(data: Dictionary):
	fanfic_id = data.get("fanfic_id", 0)
	id = data.get("id", 0)
	fanfic_request.request("https://api.codemao.cn/api/fanfic/%s" %fanfic_id)
	section_request.request("https://api.codemao.cn/api/fanfic/section/%s" %id)

func _on_section_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var data: Dictionary = json.get("data", {})
	var section: Dictionary = data.get("section", {})
	title_label.text = section.get("title", "ERROR")
	content_label.text = Application.html_to_bbcode(section.get("content", ""))

func _on_fanfic_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var data: Dictionary = json.get("data", {})
	var fanfic_info: Dictionary = data.get("fanficInfo", {})
	avatar_texture.load_image(fanfic_info.get("avatar", ""), fanfic_info.get("nickname", "ERROR"))
	nickname_label.text = fanfic_info.get("nickname", "ERROR")
	
	var section_list: Array = data.get("sectionList", {})
	drop_down_button.popup_items.clear()
	for section: Dictionary in section_list:
		var popup_item: PopupItem = PopupItem.new()
		popup_item.text = section.get("title", "ERROR")
		popup_item.checked = section.get("id", 0) == id
		popup_item.metadata = section.get("id", 0)
		drop_down_button.popup_items.append(popup_item)
