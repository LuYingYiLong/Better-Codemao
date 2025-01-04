extends Button

@onready var margin_container = %MarginContainer
@onready var collapse_page_button_container = %CollapsePageButtonContainer
@onready var animation_player = %AnimationPlayer

const COLLAPSE_PAGE_BUTTON_SCENE = preload("res://Scenes/BaseUIComponents/CollapsePageButton.tscn")
const BUTTON_THEME1 = preload("res://Resources/Themes/ButtonTheme1.tres")
const BUTTON_THEME4 = preload("res://Resources/Themes/ButtonTheme4.tres")

signal on_pressed(page: int)

var page: int = -1
var current_page: int = -1:
	set(value):
		current_page = value
		if page == current_page: theme = BUTTON_THEME1
		else: theme = BUTTON_THEME4
var collapse_pages: Vector2i

func set_page(_page: int) -> void:
	page = _page

func _on_pressed() -> void:
	if text == "...":
		if margin_container.visible:
			animation_player.play("HideCollapsePages")
		else:
			for node in collapse_page_button_container.get_children():
				node.queue_free()
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
			animation_player.play("ShowCollapsePages")
	else:
		on_pressed.emit(page)

func _on_collapse_page_button_page_pressed(_page: int) -> void:
	on_pressed.emit(_page)
	animation_player.play("HideCollapsePages")
