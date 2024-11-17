extends Control

@onready var shop_request = %ShopRequest
@onready var works_request = %WorksRequest

@onready var preview_texture = %PreviewTexture
@onready var name_label = %NameLabel
@onready var level_tag = %LevelTag
@onready var level_label = %LevelLabel
@onready var description_label = %DescriptionLabel
@onready var total_score_label = %TotalScoreLabel

@onready var work_card_container = %WorkCardContainer

const WORK_CARD_SCENE = preload("res://Scenes/Work/WorkCard.tscn")

func set_data(data: Dictionary):
	shop_request.request("https://api.codemao.cn/web/shops/%s" %data.get("id"))
	works_request.request("https://api.codemao.cn/web/works/subjects/%s/works?&offset=0&limit=20&sort=-created_at,-id&user_id=%s&work_subject_id=%s" %[data.get("id"), Application.user_id, data.get("id")])

func _on_shop_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	preview_texture.load_image(json.get("preview_url"))
	name_label.text = json.get("name")
	description_label.text = json.get("description")
	var level: int = json.get("level")
	level_label.text = str(level)
	match level:
		0: level_tag.self_modulate = Color.html(GlobalTheme.work_shop_level_0_tag_color)
		1: level_tag.self_modulate = Color.html(GlobalTheme.work_shop_level_1_tag_color)
		2: level_tag.self_modulate = Color.html(GlobalTheme.work_shop_level_2_tag_color)
		3: level_tag.self_modulate = Color.html(GlobalTheme.work_shop_level_3_tag_color)
		4: level_tag.self_modulate = Color.html(GlobalTheme.work_shop_level_4_tag_color)
	
	total_score_label.text = "%s: %s" %[TranslationServer.translate("TOTAL_SCORE_NAME"), \
			json.get("total_score")]

func _on_works_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	var items: Array = json.get("items")
	for node in work_card_container.get_children():
		node.queue_free()
	for item: Dictionary in items:
		var work_card_scene = WORK_CARD_SCENE.instantiate()
		work_card_container.add_child(work_card_scene)
		work_card_scene.set_work_card_data(item)
