@tool
extends Window

@export var popup_items: Array[PopupItem]:
	set(value):
		popup_items = value
		for node in items_container.get_children():
			node.queue_free()
		var count: int = 0
		for popup_item: PopupItem in popup_items:
			if popup_item == null: continue
			var popup_button_component = POPUP_BUTTON_COMPONENT.instantiate()
			items_container.add_child(popup_button_component)
			popup_button_component.index = count
			popup_button_component.text = popup_item.text
			popup_button_component.checked = popup_item.checked
			popup_button_component.pressed.connect(on_popup_buton_pressed)
			count += 1
			
@export_range(-1, 9999) var width: int = -1:
	set(value):
		width = value
		if width == -1: size.x = 200
		else: size.x = width + 16
		update_pos()
@export_enum("Left", "Center", "Right") var size_flags_horizontal: int = 0:
	set(value):
		size_flags_horizontal = value
		update_pos()
@export var emit: bool:
	set(value):
		if value:
			if popup_items.size() >= 6: scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
			else: scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
			scroll_container.scroll_vertical = 0
			size.y = 38 + (clampi(popup_items.size(), 1, 6) * 40)
			margin_container.add_theme_constant_override("margin_bottom", size.y * 2)
		visible = true
		emit = value
@export_group("Other")
@export var items_container: Node
@export var scroll_container: ScrollContainer

@onready var margin_container = %MarginContainer
@onready var panel_container = %PanelContainer

signal index_pressed(index: int)

const POPUP_BUTTON_COMPONENT = preload("res://Scenes/BaseUIComponents/PopupButton.tscn")
const DEFAULT_POS: Vector2 = Vector2i(536, 274)
const SPEED: float = 14.0
const TOLERANCE: int = 4

var anchor: Vector2i = Vector2i(536, 274)

func set_anchor(pos: Vector2i = Vector2i(536, 274)) -> void:
	anchor = pos

func update_pos() -> void:
	if size_flags_horizontal == 0: position.x = anchor.x - 8
	@warning_ignore("integer_division")
	if size_flags_horizontal == 1: position.x = anchor.x - size.x / 2
	if size_flags_horizontal == 2: position.x = anchor.x - size.x - 8
	position.y = anchor.y

func _process(delta) -> void:
	if emit:
		if margin_container.get_theme_constant("margin_bottom") == 16: emit = false
		else: margin_container.add_theme_constant_override("margin_bottom", lerp(margin_container.get_theme_constant("margin_bottom"), 16, delta * SPEED))

func on_popup_buton_pressed(index: int) -> void:
	index_pressed.emit(index)
	focus_exited.emit()

func _on_focus_exited() -> void:
	visible = false

func _on_close_requested() -> void:
	visible = false
