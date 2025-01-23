@tool
extends PanelContainer

@export var selector_bar_items: Array[SelectorBarItem]:
	set(value):
		selector_bar_items = value
		for node in selector_bar_item_container.get_children():
			node.queue_free()
		var count: int = 0
		for selector_bar_item: SelectorBarItem in selector_bar_items:
			if selector_bar_item == null: continue
			var selector_bar_item_scene = SELECTOR_BAR_ITEM_SCENE.instantiate()
			selector_bar_item_container.add_child(selector_bar_item_scene)
			selector_bar_item_scene.index = count
			selector_bar_item_scene.index_pressed.connect(_on_selector_bar_item_index_pressed)
			selector_bar_item_scene.text = selector_bar_item.text
			selector_bar_item_scene.icon = selector_bar_item.icon
			if count == current_item: selector_bar_item_scene.selected = true
			if size_fill: selector_bar_item_scene.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			if items_width > 0.0: selector_bar_item_scene.custom_minimum_size = Vector2(items_width, 0)
			count += 1

@export var current_item: int
@export_enum("Left", "Center", "Right") var item_alignment: int = 0:
	set(value):
		item_alignment = value
		@warning_ignore("int_as_enum_without_cast")
		selector_bar_item_container.alignment = item_alignment
@export var size_fill: bool = true
@export var items_width: float = 0.0
@export_group("Other")
@export var selector_bar_item_container: HBoxContainer

const SELECTOR_BAR_ITEM_SCENE = preload("res://Scenes/BaseUIComponents/SelectorBarItem.tscn")

signal index_pressed(index: int)

func _on_selector_bar_item_index_pressed(index: int) -> void:
	index_pressed.emit(index)
	for node in selector_bar_item_container.get_children():
		if node.index != index and node.selected: node.selected = false
