extends Control

@export_enum("Running", "Paused", "Error") var progress_state: int:
	set(value):
		progress_state = value
		if animation_player.is_playing(): await animation_player.animation_finished
		if progress_state == 0: animation_player.play("Running")
		if progress_state == 1 or progress_state == 2:
			if current_anim_finished_name == "Paused&Error":
				animation_player.play("Paused&Error")

@onready var line = %Line
@onready var line2 = %Line2

@onready var animation_player = %AnimationPlayer

var progress_color: Color
var current_anim_finished_name: String

func _ready() -> void:
	progress_color = GlobalTheme.progress_running_color
	animation_player.play("Running")
	Settings.settings_config_update.connect(_on_settings_config_update)
	_on_settings_config_update()

func _process(delta) -> void:
	line.color = line.color.lerp(progress_color, delta * 16)
	line2.color = line2.color.lerp(progress_color, delta * 16)

func _on_animation_player_animation_finished(anim_name: String) -> void:
	match anim_name:
		"Running":
			if progress_state == 0:
				if Settings.get_dark_mode(): progress_color = Color.html("#4cc2ff")
				else: progress_color = Color.html(GlobalTheme.progress_running_color)
				animation_player.play("Running")
			elif progress_state == 1:
				progress_color = Color.html(GlobalTheme.progress_paused_color)
				animation_player.play("Paused&Error")
			elif progress_state == 2:
				progress_color = Color.html(GlobalTheme.progress_error_color)
				animation_player.play("Paused&Error")
	current_anim_finished_name = anim_name

func _on_draw() -> void:
	animation_player.play("Running")

func _on_hidden() -> void:
	animation_player.stop()
	progress_color = Color.html(GlobalTheme.progress_running_color)
	current_anim_finished_name = "Running"

func _on_settings_config_update() -> void:
	if Settings.get_dark_mode():
		progress_color = Color.html("#4cc2ff")
