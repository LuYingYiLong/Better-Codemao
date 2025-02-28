extends Node

func _ready() -> void:
	var dir_access: DirAccess = DirAccess.open("user://")
	dir_access.make_dir("Plugins")

func get_plugins() -> Array:
	var plugins: Array = []
	var plugins_dir: DirAccess = DirAccess.open("user://Plugins")
	if plugins_dir:
		plugins_dir.list_dir_begin()
		var plugin_name = plugins_dir.get_next()
		while plugin_name != "":
			if plugins_dir.current_is_dir():
				var plugin_path: String = "user://Plugins/%s" %plugin_name
				if plugins_dir.file_exists(plugin_path + "/Plugin.cfg"):
					var plugin_cfg = ConfigFile.new()
					var error = plugin_cfg.load("user://Plugins/%s/Plugin.cfg" %plugin_name)
					if error == OK:
						var cfg_dict: Dictionary = {}
						cfg_dict["name"] = plugin_cfg.get_value("plugin", "name", "--")
						cfg_dict["description"] = plugin_cfg.get_value("plugin", "description", "--")
						cfg_dict["author"] = plugin_cfg.get_value("plugin", "author", "--")
						cfg_dict["version"] = plugin_cfg.get_value("plugin", "version", "--")
						if plugins_dir.file_exists(plugin_path + "/Icon.svg"):
							cfg_dict["icon"] = Image.load_from_file(plugin_path + "/Icon.svg")
						plugins.append(cfg_dict)
			plugin_name = plugins_dir.get_next()
		return plugins
	else: return []
