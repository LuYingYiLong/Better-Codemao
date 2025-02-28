extends PanelContainer

@onready var cover_texture = $HBoxContainer/Mask/CoverTexture
@onready var updating_info = %UpdatingInfo
@onready var ended_info = %EndedInfo
@onready var title_label = %TitleLabel
@onready var nickname_label = %NicknameLabel
@onready var introduction_label = %IntroductionLabel
@onready var last_update_section_button = %LastUpdateSectionButton
@onready var update_time_label = %UpdateTimeLabel

signal pressed(id: int)

var id: int
var last_update_section_id: int

func set_comic_card_data(data: Dictionary) -> void:
	id = int(data.get("id", 0))
	cover_texture.load_image(data.get("cover_pic"), data.get("title"))
	updating_info.visible = int(data.get("status", 0)) == 1
	ended_info.visible = int(data.get("status", 0)) == 2
	title_label.text = data.get("title", "ERROR")
	nickname_label.text = data.get("nickname", "--")
	introduction_label.text = data.get("introduction", "--")
	last_update_section_id = int(data.get("lastUpdateSection", {}).get("id", 0))
	last_update_section_button.text = "%s: %s" %[
		TranslationServer.translate("LAST_UPDATE_NAME"),
		data.get("lastUpdateSection", {}).get("name", "--")
	]
	update_time_label.text = "%s: %s %s" %[
		TranslationServer.translate("UPDATE_TIME_NAME"),
		Application.format_relative_time(data.get("update_time", 0)),
		data.get("update_day", "")
	]

func _on_card_pressed() -> void:
	pressed.emit(id)
