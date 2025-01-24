extends PanelContainer

@export_multiline var text: String:
	set(value):
		text = value
		code_edit.text = text
		code_edit.text_changed.emit()
@export var type: String:
	set(value):
		type = value
		if SCRIPT_NAME.has(type): type_label.text = SCRIPT_NAME.get(type)
		else: type_label.text = type

@onready var type_label = %TypeLabel
@onready var copy_button = %CopyButton
@onready var timer = %Timer
@onready var code_edit = %CodeEdit

const SCRIPT_NAME: Dictionary = {
	"python": "Python",
	"java": "Java",
	"c": "C",
	"c++": "C++",
	"c#": "C#",
	"java_script": "JavaScript",
	"type_script": "TypeScript",
	"ruby": "Ruby",
	"php": "PHP",
	"go": "Go",
	"swift": "Swift",
	"kotlin": "Kotlin",
	"rust": "Rust",
	"html": "HTML",
	"css": "CSS",
	"sql": "SQL",
	"bash": "Bash",
	"perl": "Perl",
	"lua": "Lua",
	"gdscript": "GDScript",
	"gdshader": "GDShader"
}


func _on_copy_button_pressed() -> void:
	if !timer.is_stopped(): timer.stop()
	DisplayServer.clipboard_set(text)
	copy_button.text = TranslationServer.translate("COPIED_NAME")
	timer.start()

func _on_timer_timeout() -> void:
	copy_button.text = TranslationServer.translate("COPY_NAME")

func _on_code_edit_text_changed():
	code_edit.syntax_highlighter.update_cache()
