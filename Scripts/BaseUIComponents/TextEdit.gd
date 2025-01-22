extends TextEdit

@onready var unfocused_line = %UnfocusedLine
@onready var focused_line = %FocusedLine

func _on_focus_entered():
	unfocused_line.hide()
	focused_line.show()

func _on_focus_exited():
	unfocused_line.show()
	focused_line.hide()
