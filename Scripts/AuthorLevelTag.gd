extends PanelContainer

@onready var texture_rect = %TextureRect
@onready var author_level_label = %AuthorLevelLabel

func set_author_level_data(author_level: int):
	match author_level:
		0: hide()
		1: hide()
		2:
			texture_rect.self_modulate = Color.html(GlobalTheme.author_level_2_tag_color)
			show()
		3:
			texture_rect.self_modulate = Color.html(GlobalTheme.author_level_3_tag_color)
			show()
		4:
			texture_rect.self_modulate = Color.html(GlobalTheme.author_level_4_tag_color)
			show()
		5:
			texture_rect.self_modulate = Color.html(GlobalTheme.author_level_5_tag_color)
			show()
	author_level_label.text = TranslationServer.translate("AUTHOR_LEVEL%s" %author_level)
