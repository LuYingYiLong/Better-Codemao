extends MarginContainer

@onready var button = %Button

signal pressed(word: String)

var word: String

func set_word(_word: String) -> void:
	word = _word
	button.text = "   " + word

func _on_button_pressed() -> void:
	pressed.emit(word)
