extends Button

signal on_pressed(page: int)

var page: int = -1

func set_page(_page: int):
	page = _page

func _on_pressed():
	on_pressed.emit(page)
