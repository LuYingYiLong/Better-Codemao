extends PanelContainer

@export var items: Array[PopupItem]
@export var selected: int = 0:
	set(value):
		selected = value
		label.text = items[selected].text
		item_changed.emit(items[selected])

@onready var label = %Label
@onready var down_arrow_animation_player = %DownArrowAnimationPlayer

@onready var popup_menu = %PopupMenu

signal item_changed(item: PopupItem)

func _ready() -> void:
	update_selected_item()

func load_popup_item_from_json(json: Dictionary):
	items.clear()
	var _items: Array = json.get("items", [])
	for _item: Dictionary in _items:
		var popup_item: PopupItem = PopupItem.new()
		popup_item.text = _item.get("text", "")
		popup_item.metadata = _item.get("metadata")
		items.append(popup_item)
	update_selected_item()

func update_selected_item() -> void:
	if items.is_empty(): return
	if selected >= items.size() - 1 or selected <= items.size() - 1:
		var popup_item: PopupItem = items[selected]
		label.text = popup_item.text

func _on_gui_input(event) -> void:
	if event is InputEventMouseButton and event.is_pressed:
		if event.button_mask == 1:
			if event.button_index == 1:
				down_arrow_animation_player.play("Animation")
				popup_menu.populate_items(items)
				popup_menu.set_pos(Vector2i(ceili(global_position.x), ceili(global_position.y + 40)))
				popup_menu.emit = true
		if event.button_mask == 8 and event.button_index == 4:
			selected = clampi(selected - 1, 0, items.size() - 1)
		if event.button_mask == 16 and event.button_index == 5:
			selected = clampi(selected + 1, 0, items.size() - 1)

func _on_popup_menu_index_pressed(index: int) -> void:
	selected = index
