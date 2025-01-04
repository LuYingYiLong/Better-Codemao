@tool
extends Window

@export var width: int = -1
@export var emit: bool:
	set(value):
		if value:
			if width > -1: size.x = width + 16
			size.y = 38 + (clampi(items_total, 1, 10) * 34)
			margin_container.add_theme_constant_override("margin_bottom", size.y * 2)
		visible = true
		emit = value

@onready var texture_rect = %TextureRect
@onready var margin_container = %MarginContainer
@onready var panel_container = %PanelContainer
@onready var scroll_container = %ScrollContainer
@onready var items_container = %ItemsContainer

signal index_pressed(index: int)

const POPUP_BUTTON_COMPONENT = preload("res://Scenes/BaseUIComponents/PopupButton.tscn")
const SPEED: float = 14.0
const TOLERANCE: int = 4

var items_total: int

func set_pos(pos: Vector2i = Vector2i(536, 274)):
	position = pos

func _process(delta):
	#var items_total: int = items_container.get_child_count()
	#var target_size_y: int = 40 + (clampi(items_total, 1, 10) * 34)
	#if items_total == 1: target_size_y -= 10
	#if items_total >= 6: scroll_container.vertical_scroll_mode = 2
	#else: scroll_container.vertical_scroll_mode = 0
	#if size.y != target_size_y:
	#	size.y = lerp(size.y, target_size_y, delta * SPEED)
	#	if size.y >= target_size_y - TOLERANCE:
	#		size.y = target_size_y
	if emit:
		if margin_container.get_theme_constant("margin_bottom") == 16: emit = false
		else: margin_container.add_theme_constant_override("margin_bottom", lerp(margin_container.get_theme_constant("margin_bottom"), 16, delta * SPEED))

func populate_items(items: Array[PopupItem]) -> void:
	items_total = items.size()
	for item in items_container.get_children():
		item.queue_free()
	var count: int = -1
	for item: PopupItem in items:
		count += 1
		var popup_button_component = POPUP_BUTTON_COMPONENT.instantiate()
		items_container.add_child(popup_button_component)
		popup_button_component.index = count
		popup_button_component.set_item_text(item.text)
		popup_button_component.pressed.connect(on_popup_buton_pressed)

func on_popup_buton_pressed(index: int):
	index_pressed.emit(index)
	focus_exited.emit()

func _on_focus_exited():
	visible = false

func _on_close_requested():
	visible = false
