extends Control

@onready var section_request = %SectionRequest
@onready var fanfic_request = %FanficRequest
@onready var comic_request = %ComicRequest

@onready var scroll_container = %ScrollContainer

@onready var drop_down_button = %DropDownButton
@onready var title_label = %TitleLabel
@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var rich_content = %RichContent

@onready var previous_button = %PreviousButton
@onready var next_button = %NextButton

@onready var animation_player = %AnimationPlayer

var type: int

var section_list: Array

var user_id: int
var fanfic_id: int
var comic_id: int
var id: int

var index: int = 0

func set_data(data: Dictionary):
	type = data.get("type", 0)
	match type:
		0:
			fanfic_id = int(data.get("fanfic_id", 0))
			id = int(data.get("id", -1))
			if id == -1 and get_history() != -1: id = int(get_history())
			save_history()
			fanfic_request.request("https://api.codemao.cn/api/fanfic/%s" %fanfic_id)
			section_request.request("https://api.codemao.cn/api/fanfic/section/%s" %id)
		1:
			for node in get_tree().get_nodes_in_group("only_fanfic"):
				node.hide()
			comic_id = int(data.get("comic_id", 0))
			id = int(data.get("id", -1))
			if id == -1 and get_history() != -1: id = int(get_history())
			save_history()
			comic_request.request("https://api.codemao.cn/api/comic/%s" %comic_id)
			section_request.request("https://api.codemao.cn/api/comic/page/list/%s" %id)

# 获取历史记录
func get_history() -> int:
	var library_history: Dictionary = Application.load_json_file(Application.LIBARAY_HISTORY_PATH)
	match type:
		0:
			var fanfic_history: Dictionary = library_history.get("fanfic_history", {})
			if fanfic_history.has(str(fanfic_id)): return int(fanfic_history.get(str(fanfic_id)))
			else: return -1
		1:
			var comic_history: Dictionary = library_history.get("comic_history", {})
			if comic_history.has(str(comic_id)): return int(comic_history.get(str(comic_id)))
			else: return -1
		_:
			return -1

# 保存历史记录
func save_history() -> void:
	var library_history: Dictionary = Application.load_json_file(Application.LIBARAY_HISTORY_PATH)
	match type:
		0:
			var fanfic_history: Dictionary = library_history.get("fanfic_history", {})
			fanfic_history[str(fanfic_id)] = id
			library_history["fanfic_history"] = fanfic_history
		1:
			var comic_history: Dictionary = library_history.get("comic_history", {})
			comic_history[str(comic_id)] = id
			library_history["comic_history"] = comic_history
	Application.save_json_file(Application.LIBARAY_HISTORY_PATH, library_history)

func _on_section_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	match type:
		0:
			var data: Dictionary = json.get("data", {})
			var section: Dictionary = data.get("section", {})
			title_label.text = section.get("title", "ERROR")
			rich_content.init_contents(section.get("content", ""))
		1:
			var data: Dictionary = json.get("data", {})
			var rich_text: String = ""
			var comic_page_list: Array = data.get("comicPageList")
			for comic_page: Dictionary in comic_page_list:
				rich_text += "[image=%s]" %comic_page.get("img_url", "")
			rich_content.init_contents(rich_text)

func _on_fanfic_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var data: Dictionary = json.get("data", {})
	var fanfic_info: Dictionary = data.get("fanficInfo", {})
	avatar_texture.load_image(fanfic_info.get("avatar", ""), fanfic_info.get("nickname", "ERROR"))
	nickname_label.text = fanfic_info.get("nickname", "ERROR")
	
	section_list = data.get("sectionList", [])
	drop_down_button.popup_items.clear()
	for section: Dictionary in section_list:
		var popup_item: PopupItem = PopupItem.new()
		popup_item.text = section.get("title", "ERROR")
		if int(section.get("id", -1)) == id:
			popup_item.checked = true
			index = drop_down_button.popup_items.size()
		popup_item.metadata = int(section.get("id", -1))
		drop_down_button.popup_items.append(popup_item)
	update_button_status()

func _on_comic_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var data: Dictionary = json.get("data", {})
	var comic_info: Dictionary = data.get("comic", {})
	section_list = comic_info.get("comicSectionList", [])
	drop_down_button.popup_items.clear()
	for section: Dictionary in section_list:
		var popup_item: PopupItem = PopupItem.new()
		popup_item.text = section.get("title", "ERROR")
		if int(section.get("id", -1)) == id:
			title_label.text  = section.get("title", "ERROR")
			popup_item.checked = true
			index = drop_down_button.popup_items.size()
		popup_item.metadata = int(section.get("id", -1))
		drop_down_button.popup_items.append(popup_item)
	update_button_status()

func _on_drop_down_button_index_pressed(_index: int) -> void:
	index = _index
	update_button_status()
	section_request.request("https://api.codemao.cn/api/fanfic/section/%s" %id)

func _on_previous_button_pressed() -> void:
	index -= 1
	update_button_status()
	section_request.request("https://api.codemao.cn/api/fanfic/section/%s" %id)

func _on_go_back_to_the_home_page_button_pressed() -> void:
	animation_player.play("Hide")

func _on_next_button_pressed() -> void:
	index += 1
	update_button_status()
	section_request.request("https://api.codemao.cn/api/fanfic/section/%s" %id)

func update_button_status() -> void:
	id = int(section_list[index].get("id", 0))
	for popup_item: PopupItem in drop_down_button.popup_items:
		popup_item.checked = popup_item.metadata == id
	previous_button.disabled = index <= 0
	next_button.disabled = index >= drop_down_button.popup_items.size() - 1
	Application.scroll_to_top(scroll_container)
	save_history()
