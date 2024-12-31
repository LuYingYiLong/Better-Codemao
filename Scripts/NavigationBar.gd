extends PanelContainer

@onready var user_button = %UserButton
@onready var avatar_texture = %AvatarTexture

@onready var animation_player = %AnimationPlayer

var expanded: bool

func _ready() -> void:
	Application.user_avatar_update.connect(on_user_avatar_update)
	if FileAccess.file_exists(ProjectSettings.globalize_path("user://UserData.json")):
		var user_data: Dictionary = Application.load_json_file("user://UserData.json")
		user_button.text = user_data.get("nickname", "")
	if FileAccess.file_exists(ProjectSettings.globalize_path("user://UserAvatar.png")):
		var image: Image = Image.load_from_file("user://UserAvatar.png")
		avatar_texture.texture = ImageTexture.create_from_image(image)

func _process(_delta) -> void:
	if get_viewport().get_window().size.x >= 1400 and !expanded:
		expanded = true
		animation_player.play("Expand")
	elif get_viewport().get_window().size.x < 1400 and expanded:
		expanded = false
		animation_player.play("Fold")

func on_user_avatar_update() -> void:
	avatar_texture.texture = Application.user_avatar
	if Application.user_id <= 0:
		user_button.text = "VISITOR_NAME"
		return
	if FileAccess.file_exists(ProjectSettings.globalize_path("user://UserData.json")):
		var user_data: Dictionary = Application.load_json_file("user://UserData.json")
		user_button.text = user_data.get("nickname")

func _on_workshop_tab_pressed() -> void:
	Application.set_root_address.emit(TranslationServer.translate("WORKSHOP_NAME"), \
			"res://Scenes/Workshop/WorkshopMenu.tscn", \
			{})

func _on_forum_tab_pressed() -> void:
	Application.set_root_address.emit(TranslationServer.translate("FORUM_NAME"), \
			"res://Scenes/Forum/ForumlMenu.tscn", \
			{})

func _on_library_tab_pressed() -> void:
	Application.set_root_address.emit(TranslationServer.translate("LIBRARY_NAME"), \
			"res://Scenes/Library/LibraryMenu.tscn", \
			{})

func _on_message_button_pressed() -> void:
	Application.set_root_address.emit(TranslationServer.translate("MESSAGE_NAME"), \
			"res://Scenes/Message/MessageMenu.tscn", \
			{})

func _on_settings_button_pressed() -> void:
	Application.set_root_address.emit(TranslationServer.translate("SETTINGS_NAME"), \
			"res://Scenes/Settings/SettingsMenu.tscn", \
			{"go_to": "root_options"})

func _on_user_button_pressed() -> void:
	Application.set_root_address.emit(TranslationServer.translate("USER_NAME"), \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": Application.user_id})

func _on_avatar_texture_popup_menu_callback(id: int) -> void:
	if id == 3:
		Application.sign_out()
