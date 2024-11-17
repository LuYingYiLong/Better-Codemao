extends PanelContainer

@onready var work_label = %WorkLabel

var data: Dictionary

func set_work_tag_data(_data: Dictionary):
	data = _data
	work_label.text = data.get("label_name")
