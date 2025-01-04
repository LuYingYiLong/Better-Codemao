@tool
extends PanelContainer

@export var text: String
@export var description: String
@export var go_to: String
@export var jump_to: String
@export var link: String
@export var dir: String

@onready var icon = %Icon

@onready var text_label = %TextLabel
@onready var description_label = %DescriptionLabel

@onready var arrow_texture = %ArrowTexture
@onready var link_texture = %LinkTexture
@onready var copy_button = %CopyButton
@onready var combo_box = %ComboBox

@onready var blackground_panel = %BlackgroundPanel
@onready var blackground_texture = %BlackgroundTexture
@onready var file_dialog = %FileDialog

@onready var animation_player = %AnimationPlayer

var _data: Dictionary

func _process(_delta):
	text_label.text = text
	description_label.visible = !description.is_empty()
	description_label.text = description
	arrow_texture.visible = !go_to.is_empty() or !jump_to.is_empty()
	link_texture.visible = !link.is_empty() or !dir.is_empty()

func set_option_box_data(data: Dictionary):
	_data = data
	if data.has("icon"):
		icon.texture = load(data.get("icon"))
		icon.show()
	text = data.get("text", "")
	description = data.get("description", "")
	go_to = data.get("go_to", "")
	link = data.get("link", "")
	dir = data.get("dir", "")
	jump_to = data.get("jump_to", "")
	if data.has("combo_box"):
		combo_box.load_popup_item_from_json(data.get("combo_box"))
		var selected = data.get("combo_box").get("selected")
		if selected is int: combo_box.selected = selected
		if selected is String and is_command(selected): combo_box.selected = process_command(selected)
		combo_box.show()
	if data.has("change_settings_config"):
		var path: String = data.get("change_settings_config").get("path")
		var key: String = data.get("change_settings_config").get("key")
		match [path, key]:
			["personalization", "blackground"]:
				if !Settings.blackground.is_empty():
					var image = Image.new()
					image.load(Settings.blackground)
					var texture = ImageTexture.create_from_image(image)
					blackground_texture.texture = texture
				blackground_panel.show()
			["personalization", "blackground_mode"]:
				var use = data.get("change_settings_config").get("use")
				if use is String and use == "$ combo_box->items->selected->metadata":
					combo_box.item_changed.connect(use_combo_box_set_blackground_mode)
			["language", "language"]:
				var use = data.get("change_settings_config").get("use")
				if use is String and use == "$ combo_box->items->selected->metadata":
					combo_box.item_changed.connect(use_combo_box_set_language)

func _on_gui_input(event):
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		if !go_to.is_empty(): Application.append_address.emit(_data.get("text", ""), \
					"res://Scenes/Settings/SettingsMenu.tscn", \
					{"go_to": go_to})
		
		elif !jump_to.is_empty(): Application.append_address.emit(_data.get("text", ""), \
					jump_to, \
					{})
		elif !link.is_empty(): OS.shell_open(link)

		elif !dir.is_empty(): OS.shell_open(ProjectSettings.globalize_path(_data.get("dir")))

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

func is_command(command: String):
	return command.begins_with("$ ")

func process_command(command: String):
	if !is_command(command): return
	command = command.trim_prefix("$ ")
	var sections: PackedStringArray = command.split("->")
	match sections[0]:
		"settings_config":
			if sections.size() >= 3:
				match [sections[1], sections[2]]:
					["personalization", "blackground_mode"]:
						return Settings.blackground_mode
					["language", "language"]:
						if sections.size() >= 4:
							match Settings.language:
								"ch": return 0
								"en": return 1
						else:
							return Settings.language

func _on_mouse_entered():
	animation_player.play("MouseEntered")

func _on_mouse_exited():
	animation_player.play("MouseExited")

func use_combo_box_set_blackground_mode(item: PopupItem) -> void:
	var metadata: int = item.metadata
	Settings.blackground_mode = metadata
	Settings.save_settings_config()

func use_combo_box_set_language(item: PopupItem) -> void:
	var metadata: String = item.metadata
	Settings.language = metadata
	Settings.save_settings_config()
