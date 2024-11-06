extends PanelContainer

@onready var level_label = %LevelLabel
@onready var name_label = %NameLabel

var subject_id: int

func set_work_shop_data(level: int, work_shop_name: String, id: int):
	if id == 0:
		hide()
		return
	level_label.text = str(level)
	match level:
		0: self_modulate = Color.html(GlobalTheme.work_shop_level_0_tag_color)
		1: self_modulate = Color.html(GlobalTheme.work_shop_level_1_tag_color)
		2: self_modulate = Color.html(GlobalTheme.work_shop_level_2_tag_color)
		3: self_modulate = Color.html(GlobalTheme.work_shop_level_3_tag_color)
		4: self_modulate = Color.html(GlobalTheme.work_shop_level_4_tag_color)
	name_label.text = work_shop_name
	subject_id = id
	show()
