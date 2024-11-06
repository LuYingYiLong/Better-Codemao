extends PanelContainer

@onready var avatar_texture = %AvatarTexture

func _ready():
	Application.user_avatar_update.connect(on_user_avatar_update)

func on_user_avatar_update():
	avatar_texture.texture = Application.user_avatar

func _on_forum_tab_pressed():
	Application.set_root_address.emit(TranslationServer.translate("FORUM_NAME"), \
			"res://Scenes/ForumlMenu.tscn", \
			{})

func _on_message_button_pressed():
	Application.set_root_address.emit(TranslationServer.translate("MESSAGE_NAME"), \
			"res://Scenes/MessageMenu.tscn", \
			{})

func _on_user_button_pressed():
	Application.set_root_address.emit(TranslationServer.translate("USER_NAME"), \
			"res://Scenes/UserMenu.tscn", \
			{"id": Application.user_id})
