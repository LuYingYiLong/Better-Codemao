@tool
extends PanelContainer

@export var text: String
@export var description: String
@export var go_to: String
@export var link: String

@onready var text_label = %TextLabel
@onready var description_label = %DescriptionLabel

@onready var arrow_texture = %ArrowTexture
@onready var link_texture = %LinkTexture
@onready var copy_button = %CopyButton

@onready var blackground_panel = %BlackgroundPanel
@onready var blackground_texture = %BlackgroundTexture
@onready var file_dialog = %FileDialog

var _data: Dictionary

func _process(_delta):
	text_label.text = text
	description_label.visible = !description.is_empty()
	description_label.text = description
	arrow_texture.visible = !go_to.is_empty()
	link_texture.visible = !link.is_empty()

func set_option_box_data(data: Dictionary):
	_data = data
	text = TranslationServer.translate(data.get("text", ""))
	description = TranslationServer.translate(data.get("description", ""))
	go_to = data.get("go_to", "")
	link = data.get("link", "")
	if _data.has("change_settings_config"):
		var path: String = _data.get("change_settings_config").get("path")
		var key: String = _data.get("change_settings_config").get("key")
		match [path, key]:
			["personalization", "blackground"]:
				if !Settings.blackground.is_empty():
					var image = Image.new()
					image.load(Settings.blackground)
					var texture = ImageTexture.create_from_image(image)
					blackground_texture.texture = texture
				blackground_panel.show()

func _on_gui_input(event):
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		if _data.has("go_to"):
			if not _data.get("go_to") is String: return
			if _data.get("go_to").is_empty(): return
			Application.append_address.emit(TranslationServer.translate(_data.get("text", "")), \
			"res://Scenes/Settings/SettingsMenu.tscn", \
			{"go_to": _data.get("go_to")})

		elif _data.has("link"):
			if not _data.get("link") is String: return
			if _data.get("link").is_empty(): return
			OS.shell_open(_data.get("link"))

		elif _data.has("change_settings_config"):
			var path: String = _data.get("change_settings_config").get("path")
			var key: String = _data.get("change_settings_config").get("key")
			match [path, key]:
				["personalization", "blackground"]:
					file_dialog.visible = true

func _on_file_dialog_file_selected(path: String):
	var get_extension: String = path.get_extension()
	DirAccess.copy_absolute(path, ProjectSettings.globalize_path("user://Personalization/Blackground.%s" %get_extension))
	Settings.blackground = "user://Personalization/Blackground.%s" %get_extension
	var image = Image.new()
	image.load(Settings.blackground)
	var texture = ImageTexture.create_from_image(image)
	blackground_texture.texture = texture
	Settings.save_settings_config()
