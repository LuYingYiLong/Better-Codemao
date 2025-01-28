extends PanelContainer

@export_enum("My", "Other") var who: int = 0:
	set(value):
		who = value
		other_mask.visible = who == 1
		my_mask.visible = who == 0
		if who == 0:
			bubble.add_theme_stylebox_override("panel", MY_CHAT_BUBBLE_LIGHT)
		elif who == 1: bubble.add_theme_stylebox_override("panel", OTHER_CHAT_BUBBLE_LIGHT)
		theme_painter.update_theme()
@export var avatar: Texture = preload("res://Resources/Textures/Photo.svg"):
	set(value):
		avatar = value
		other_avatar_texture.texture = avatar
		my_avatar_texture.texture = avatar
@export_multiline var content: String:
	set(value):
		content = value
		rich_content.init_contents(content)

@onready var other_mask = %OtherMask
@onready var other_avatar_texture = %OtherAvatarTexture
@onready var bubble = %Bubble
@onready var theme_painter = %ThemePainter
@onready var rich_content = %RichContent
@onready var my_mask = %MyMask
@onready var my_avatar_texture = %MyAvatarTexture

const MY_CHAT_BUBBLE_LIGHT = preload("res://Resources/Themes/MyChatBubble-Light.tres")
const OTHER_CHAT_BUBBLE_LIGHT = preload("res://Resources/Themes/OtherChatBubble-Light.tres")
