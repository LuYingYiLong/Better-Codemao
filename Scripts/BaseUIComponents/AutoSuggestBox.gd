extends PanelContainer

@export var text: String:
	set(value):
		text = value
		line_edit.text = text
@export var placeholder_text: String

@onready var line_edit = %LineEdit

@onready var clear_button = %ClearButton
@onready var search_button = %SearchButton

@onready var focus_entered_line = %FocusEnteredLine

signal search_pressed(text: String)

func _ready():
	line_edit.placeholder_text = placeholder_text

func _on_line_edit_text_changed(new_text: String) -> void:
	clear_button.visible = !new_text.is_empty()

func _on_line_edit_focus_entered() -> void:
	focus_entered_line.show()

func _on_line_edit_focus_exited() -> void:
	focus_entered_line.hide()

func _on_line_edit_text_submitted(new_text: String) -> void:
	search_pressed.emit(new_text)

func _on_clear_button_pressed() -> void:
	line_edit.clear()
	clear_button.hide()

func _on_search_button_pressed() -> void:
	search_pressed.emit(line_edit.text)
