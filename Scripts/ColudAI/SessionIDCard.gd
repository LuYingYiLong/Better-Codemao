extends PanelContainer

@onready var rename_request = %RenameRequest

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

var new_session_name: String

func _set_session_name() -> void:
	session_id_label.text = session_name

func _rename() -> void:
	line_edit.text = session_name
	session_id_label.hide()
	line_edit.show()
	line_edit.grab_focus()
	
func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text == session_name:
		line_edit.hide()
		session_id_label.show()
	else:
		new_session_name = new_text
		line_edit.editable = false
		rename_request.request("https://ai.coludai.cn/api/session/rename", \
				[ColudAIUserManager.get_cookie()], \
				HTTPClient.METHOD_POST, \
				JSON.stringify({"name": new_session_name, "sessionid": session_id}))

func _on_rename_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	line_edit.editable = true
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json.get("message", "") == "ok":
		session_name = new_session_name
		session_id_label.show()
		line_edit.hide()
		ColudAIUserManager.sessions_update.emit()
	else:
		line_edit.text = session_name
		line_edit.select_all()

func _on_delete_button_pressed() -> void:
	delete = true

func _on_undo_button_pressed() -> void:
	delete = false
