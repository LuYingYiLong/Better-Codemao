extends Button

@export_multiline var url: String:
	set(value):
		url = value
		fly_share_menu.url = url

@onready var fly_share_menu = %FlyShareMenu

func _on_pressed():
	fly_share_menu.position.x = global_position.x - size.x / 2
	fly_share_menu.position.y = global_position.y + 40
	fly_share_menu.show()
