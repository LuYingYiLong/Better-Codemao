extends PanelContainer

@export var session_id: String
@export var session_name: String:
	set(value):
		session_name = value
		_set_session_name()
@export var delete: bool:
	set(value):
		delete = value
		delete_button.visible = !delete
		undo_button.visible = delete

@onready var session_id_label = %SessionIDLabel
@onready var line_edit = %LineEdit
@onready var delete_button = %DeleteButton
@onready var undo_button = %UndoButton

func _set_session_name() -> void:
	session_id_label.text = session_name

func _rename() -> void:
	line_edit.text = session_name
	session_id_label.hide()
	line_edit.show()
	line_edit.grab_focus()
	
func _on_line_edit_text_submitted(new_text: String) -> void:
	session_name = new_text
	session_id_label.show()
	line_edit.hide()
	ColudAIUserManager.rename_session_name(session_id, session_name)

func _on_delete_button_pressed() -> void:
	delete = true

func _on_undo_button_pressed() -> void:
	delete = false
