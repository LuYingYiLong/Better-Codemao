extends Control

@onready var panel_container = %PanelContainer
@onready var message_label = %MessageLabel

@onready var animation_player = %AnimationPlayer
@onready var timer = %Timer

func set_system_message_data(message: String, color: String = "#cc2929", time: float = 3.0):
	panel_container.self_modulate = Color.html(color)
	message_label.text = message
	timer.wait_time = clampf(time, 1.0, 10.0)
	animation_player.play("Show")
	timer.start()

func _on_timer_timeout():
	animation_player.play("Hide")
	await animation_player.animation_finished
	queue_free()
