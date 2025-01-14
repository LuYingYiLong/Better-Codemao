@tool
extends PanelContainer

@export var tab_items: Array[TabItem]:
	set(value):
		tab_items = value
		populate_tab_container()
@export var current_tab: int = 0:
	set(value):
		current_tab = value
		update_current_tab()
@export_group("Other")
@export var tab_container: Node

signal index_pressed(index: int)

const TAB_SCENE = preload("res://Scenes/BaseUIComponents/Tab.tscn")
const H_SEPARATOR_SCENE = preload("res://Scenes/BaseUIComponents/HSeparator.tscn")

func populate_tab_container() -> void:
	for node in tab_container.get_children():
		node.queue_free()
	var count: int = 0
	for tab_item: TabItem in tab_items:
		var tab_scene = TAB_SCENE.instantiate()
		tab_container.add_child(tab_scene)
		if tab_item != null:
			if !tab_item.title.is_empty(): tab_scene.title = tab_item.title
			if !tab_item.text.is_empty(): tab_scene.text = tab_item.text
		tab_scene.index = count
		tab_scene.current_tab = current_tab
		tab_scene.index_pressed.connect(_on_tab_index_pressed)
		count += 1
		if count < tab_items.size():
			var h_separator_scene = H_SEPARATOR_SCENE.instantiate()
			tab_container.add_child(h_separator_scene)

func update_tab_data():
	var count: int = 0
	for node in tab_container.get_children():
		if node.has_method("is_tab"):
			node.title = tab_items[count].title
			node.text = tab_items[count].text
			count += 1
			if count >= tab_items.size(): break

func update_current_tab() -> void:
	for node in tab_container.get_children():
		if node.has_method("is_tab"):
			node.current_tab = current_tab

func _on_tab_index_pressed(index: int) -> void:
	current_tab = index
	index_pressed.emit(index)
