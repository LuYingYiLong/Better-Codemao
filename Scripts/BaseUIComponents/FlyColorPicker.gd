extends Window

@onready var color_picker = %ColorPicker
@onready var color_rect = %ColorRect
@onready var hex_line_edit = %HexLineEdit
@onready var preset_color_card_containr = %PresetColorCardContainr
@onready var animation_player = %AnimationPlayer

const PRESET_COLOR_CARD_SCENE = preload("res://Scenes/BaseUIComponents/PresetColorCard.tscn")
const MAX_PRESET_COLOR_QUABTITY: int = 6

signal color_selected(color: Color)

func _ready() -> void:
	hex_line_edit.text = "#%s" %color_picker.color.to_html(false)
	populate_preset_color()

func _on_visibility_changed() -> void:
	if visible and animation_player is AnimationPlayer: animation_player.play("Show")

func _on_color_picker_color_changed(color: Color) -> void:
	color_rect.self_modulate = color
	hex_line_edit.text = "#%s" %color.to_html(false)

func _on_add_preset_color_button_pressed():
	GlobalTheme.add_preset_color(color_picker.color)
	var preset_color_array: Array = GlobalTheme.get_preset_color_array()
	if preset_color_array.size() >= MAX_PRESET_COLOR_QUABTITY:
		GlobalTheme.remove_preset_color(MAX_PRESET_COLOR_QUABTITY)
	populate_preset_color()

func _on_hex_line_edit_text_changed(new_text: String) -> void:
	color_picker.color = Color.html(new_text)
	color_rect.self_modulate = Color.html(new_text)

func populate_preset_color() -> void:
	for node in preset_color_card_containr.get_children():
		node.queue_free()
	var preset_color_array: Array = GlobalTheme.get_preset_color_array()
	for preset_color: String in preset_color_array:
		var preset_color_card_scene = PRESET_COLOR_CARD_SCENE.instantiate()
		preset_color_card_containr.add_child(preset_color_card_scene)
		preset_color_card_scene.set_color(Color.html(preset_color))
		preset_color_card_scene.select_color.connect(_on_preset_color_card_select_color)

func _on_preset_color_card_select_color(color: Color) -> void:
	color_picker.color = color
	color_rect.self_modulate = color
	hex_line_edit.text = "#%s" %color.to_html(false)

func _on_ok_button_pressed() -> void:
	color_selected.emit(color_picker.color)
	animation_player.play("Hide")

func _on_focus_exited():
	animation_player.play("Hide")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	visible = not anim_name == "Hide"
