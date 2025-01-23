extends Window

@onready var collapse_page_button_container = %CollapsePageButtonContainer
@onready var animation_player = %AnimationPlayer

const COLLAPSE_PAGE_BUTTON_SCENE = preload("res://Scenes/BaseUIComponents/PaginationBarComponents/CollapsePageButton.tscn")

signal pressed(page: int)

func populate_collapse_pages(collapse_pages: Vector2i, current_page: int):
	var begin: int = collapse_pages.x
	var end: int = collapse_pages.y
	var count: int = 0
	for collapse_page: int in range(end - begin):
		var collapse_page_button_scene = COLLAPSE_PAGE_BUTTON_SCENE.instantiate()
		collapse_page_button_container.add_child(collapse_page_button_scene)
		collapse_page_button_scene.page = begin + count
		collapse_page_button_scene.text = str(begin + count)
		collapse_page_button_scene.current_page = current_page
		collapse_page_button_scene.page_pressed.connect(_on_collapse_page_button_page_pressed)
		count += 1

func _on_collapse_page_button_page_pressed(page: int) -> void:
	pressed.emit(page)
	hide_fly_collapse_pages_menu()

func show_fly_collapse_pages_menu() -> void:
	animation_player.play("Show")

func hide_fly_collapse_pages_menu() -> void:
	animation_player.play("Hide")
