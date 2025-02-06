extends Window

@onready var colud_ai_menu = %ColudAIMenu

func _ready() -> void:
	colud_ai_menu.set_data({"in_new_window": true})
	show()

func set_data(data: Dictionary) -> void:
	size = data.get("size", Vector2(1152, 648))

func _on_close_requested() -> void:
	queue_free()

func _on_colud_ai_menu_pin() -> void:
	always_on_top = true

func _on_colud_ai_menu_unpin() -> void:
	always_on_top = false
