extends Control

@onready var installed_plugin_card_container = %InstalledPluginCardContainer

const PLUGIN_CARD_SCENE = preload("res://Scenes/Plugin/PluginCard.tscn")

func _ready():
	update_installed_plugin()

func update_installed_plugin() -> void:
	for node: Node in installed_plugin_card_container.get_children():
		node.queue_free()
	var plugins: Array = PluginManager.get_plugins()
	for plugin: Dictionary in plugins:
		var plugin_card_scene = PLUGIN_CARD_SCENE.instantiate()
		plugin_card_scene.new_instantiate(installed_plugin_card_container, plugin)
