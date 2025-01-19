extends Node

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	parse_user_args(OS.get_cmdline_user_args())

func parse_user_args(user_args: PackedStringArray) -> void:
	if user_args.is_empty() or user_args.size() < 2: return
	match user_args[0]:
		"--action":
			match user_args[1]:
				"go_to": go_to(user_args)
		"--post":
			var json: Dictionary = parse_json_text(user_args[1])
			if json.is_empty() or !json.has("id"): return
			Application.append_address.emit("POST_NAME", "res://Scenes/Forum/PostMenu.tscn", json)
		"--shop":
			var json: Dictionary = parse_json_text(user_args[1])
			if json.is_empty() or !json.has("id"): return
			Application.append_address.emit("WORKSHOP_NAME", "res://Scenes/Workshop/ShopMenu.tscn", json)
		"--work":
			var json: Dictionary = parse_json_text(user_args[1])
			if json.is_empty() or !json.has("id"): return
			Application.append_address.emit("WORK_NAME", "res://Scenes/Work/WorkMenu.tscn", json)
		"--user":
			var json: Dictionary = parse_json_text(user_args[1])
			if json.is_empty() or !json.has("id"): return
			Application.append_address.emit("USER_NAME", "res://Scenes/User/UserDetailsMenu.tscn", json)

func _notification(what) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		var clipboard_get: String = DisplayServer.clipboard_get()
		if Application.is_valid_url(clipboard_get): shell_open(clipboard_get)
		elif clipboard_get.begins_with("-- "):
			parse_user_args(clipboard_get.trim_prefix("-- ").split(" "))
			DisplayServer.clipboard_set("")

func shell_open(url: String) -> void:
	if Application.is_valid_url(url):
		var honst: String = Application.extract_host_from_url(url)
		if honst != "https://shequ.codemao.cn": return
		var path: String = Application.extract_path_from_url(url)
		if path.begins_with("/user/"):
			Application.append_address.emit(TranslationServer.translate("USER_NAME"), \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": path.trim_prefix("/user/").to_int()})
		elif path.begins_with("/community/"):
			Application.append_address.emit(TranslationServer.translate("POST_NAME"), \
			"res://Scenes/Forum/PostMenu.tscn", \
			{"id": path.trim_prefix("/community/").to_int()})
		elif path.begins_with("/work/"):
			Application.append_address.emit(TranslationServer.translate("WORK_NAME"), \
			"res://Scenes/Work/WorkMenu.tscn", \
			{"id": path.trim_prefix("/work/").to_int()})
		elif path.begins_with("/workshop/"):
			Application.append_address.emit(TranslationServer.translate("WORKSHOP_NAME"), \
			"res://Scenes/Workshop/ShopMenu.tscn", \
			{"id": path.trim_prefix("/workshop/").to_int()})
		DisplayServer.clipboard_set("")

func go_to(user_args: PackedStringArray) -> void:
	if user_args.size() != 8: return
	if user_args[2] == "--name" and \
			user_args[4] == "--scene_path" and \
			user_args[6] == "--data":
		var json: Dictionary = parse_json_text(user_args[7])
		Application.append_address.emit(user_args[3], user_args[5], json)

func parse_json_text(json_text: String) -> Dictionary:
	var json_class: JSON = JSON.new()
	if json_class.parse(json_text) != OK: return {}
	else: return json_class.data
	
