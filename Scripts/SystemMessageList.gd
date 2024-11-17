extends Control

@onready var system_message_container = %SystemMessageContainer

const SYSTEM_MESSAGE_SCENE = preload("res://Scenes/SystemMessage.tscn")

func _ready():
	Application.add_system_message.connect(add_system_message)

func add_system_message(message: String, color: String = "#cc2929", time: float = 3.0):
	var system_message_scene = SYSTEM_MESSAGE_SCENE.instantiate()
	system_message_container.add_child(system_message_scene)
	system_message_scene.set_system_message_data(message, color, time)
