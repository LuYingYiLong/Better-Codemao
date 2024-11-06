extends MarginContainer

@onready var animation_player = %AnimationPlayer

signal animation_finished(anim_name: String)

func load_scene(scene_path: String, data: Dictionary = {}):
	var scene = load(scene_path).instantiate()
	add_child(scene)
	if scene.has_method("set_data"):
		scene.set_data(data)

func _show(anim: String):
	animation_player.play(anim)

func _hide(anim: String):
	animation_player.play(anim)

func _on_animation_player_animation_finished(anim_name):
	animation_finished.emit(anim_name)
