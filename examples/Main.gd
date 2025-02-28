extends Node

func _ready():
	var my_plugin = MyPlugin.new(self)
	my_plugin.on_forum_posts_changed.connect(_on_forum_posts_changed)

func _on_forum_posts_changed(posts: Array) -> void:
	print(posts)

class MyPlugin extends Interface:
	static func get_interface_name() -> StringName:
		return &"MyPlugin"
