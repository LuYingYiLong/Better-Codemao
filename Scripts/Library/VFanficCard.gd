extends PanelContainer

@onready var cover_texture = %CoverTexture
@onready var title_label = %TitleLabel
@onready var nickname_label = %NicknameLabel
@onready var introduction_label = %IntroductionLabel
@onready var view_times_label = %ViewTimesLabel
@onready var collect_times_label = %CollectTimesLabel

var fanfic_id: int

func set_v_fanfic_card_data(data: Dictionary) -> void:
	fanfic_id = int(data.get("id", 0))
	cover_texture.load_image(data.get("cover_pic", data.get("title")))
	title_label.text = data.get("title", "ERROR")
	nickname_label.text = data.get("nickname", "ERROR")
	introduction_label.text = data.get("introduction", "--")
	view_times_label.text = str(int(data.get("view_times", "--")))
	collect_times_label.text = str(int(data.get("collect_times", "--")))

func _on_card_pressed():
	Application.append_address.emit(title_label.text, \
			"res://Scenes/Library/FanficMenu.tscn", \
			{"id": fanfic_id})
