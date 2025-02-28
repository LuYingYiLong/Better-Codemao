extends PanelContainer

@onready var comic_label = %ComicLabel

func set_tag(tag_name: String) -> void:
	comic_label.text = tag_name
