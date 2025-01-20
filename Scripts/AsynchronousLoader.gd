extends Node

# 异步加载器

var tips_index: int
var is_loading: bool = false
var scene_path: String
var data: Dictionary

func _ready():
	Application.async_load_scene.connect(async_load_scene)

func async_load_scene(_scene_path: String, _data: Dictionary) -> void:
	if is_loading: return
	scene_path = _scene_path
	data = _data
	ResourceLoader.load_threaded_request(scene_path)
	is_loading = true

func _process(_delta) -> void:
	if is_loading:
		if ResourceLoader.load_threaded_get_status(scene_path) == ResourceLoader.THREAD_LOAD_LOADED:
			var scene = ResourceLoader.load_threaded_get(scene_path).instantiate()
			add_child(scene)
			if scene.has_method("set_data"):
				scene.set_data(data)
			is_loading = false
		elif ResourceLoader.load_threaded_get_status(scene_path) == ResourceLoader.THREAD_LOAD_FAILED:
			Application.emit_system_error_message("加载过程中发生了错误，导致失败")
			is_loading = false
