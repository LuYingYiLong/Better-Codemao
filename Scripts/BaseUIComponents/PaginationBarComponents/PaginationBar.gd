@tool
extends Node

@export_range(0, 999) var total: int:
	set(value):
		total = value
		if Engine.is_editor_hint(): update_pager_total()
@export_range(0, 999) var size: int:
	set(value):
		size = value
		if Engine.is_editor_hint(): update_pager_total()
@export_range(0, 999) var current_page: int:
	set(value):
		current_page = value
		if Engine.is_editor_hint(): update_current_page()

@onready var pager_button_container = %PagerButtonContainer

signal page_changed(page: int)

const PAGER_BUTTON_SCENE = preload("res://Scenes/BaseUIComponents/PaginationBarComponents/PagerButton.tscn")

func _ready() -> void:
	update_pager_total()

func update_pager_total() -> void:
	if pager_button_container == null: return
	for node in pager_button_container.get_children():
		node.queue_free()
	for count: int in range(total):
		var pager_button_scene = PAGER_BUTTON_SCENE.instantiate()
		pager_button_container.add_child(pager_button_scene)
		if size >= 3 and count >= size - 2:
			if count == size - 2: pager_button_scene.text = "..."
			elif count > size - 2: pager_button_scene.text = str(total)
		else:
			pager_button_scene.text = str(count + 1)
		if !Engine.is_editor_hint():
			if pager_button_scene.text != "...": pager_button_scene.set_page(pager_button_scene.text.to_int())
			else: pager_button_scene.collapse_pages = Vector2i(count + 1, total)
			pager_button_scene.on_pressed.connect(_on_pager_button_pressed)
		pager_button_scene.current_page = current_page
		if pager_button_scene.text.to_int() == total: break

func update_current_page() -> void:
	if pager_button_container == null: return
	for pager in pager_button_container.get_children():
		pager.current_page = current_page

func is_current_page(page: int) -> bool:
	return page == current_page

func _on_pager_button_pressed(page: int):
	if page != current_page:page_changed.emit(page)
	current_page = page
	update_current_page()

func _on_previous_button_pressed() -> void:
	if current_page > 1:
		current_page -=1
		page_changed.emit(current_page)
		update_current_page()

func _on_next_button_pressed() -> void:
	if current_page < total:
		current_page += 1
		page_changed.emit(current_page)
		update_current_page()
