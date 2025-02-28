class_name Implementer

func _init() -> void:
	BCInterface.new(self)

class BCInterface extends Interface.BCInterface:
	static func version() -> String:
		return "1.0"
