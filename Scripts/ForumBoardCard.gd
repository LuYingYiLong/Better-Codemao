extends PanelContainer

@onready var icon_request = %IconRequest

@onready var icon_texture = %IconTexture
@onready var name_label = %NameLabel
@onready var is_hot = %IsHot

@onready var animation_player = %AnimationPlayer

var id: String

var thread_helper: ThreadHelper

func _ready():
	thread_helper = ThreadHelper.new(self)

func set_forum_board_card_data(data: Dictionary):
	id = data.get("id")
	icon_request.request_completed.connect(on_icon_received)
	icon_request.request(data.get("icon_url"))
	name_label.text = data.get("name")
	if data.get("is_hot", false):
		is_hot.self_modulate = Color.html("#f76e68")
	else:
		is_hot.self_modulate = Color.html("#3268e9")

func on_icon_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("无法下载图像。尝试一个不同的图像。")
	thread_helper.join_function(func(): load_icon_texture_from_thread(body))
	thread_helper.start()

func load_icon_texture_from_thread(buffer: PackedByteArray):
	var image = Image.new()
	var error = image.load_jpg_from_buffer(buffer)
	if error != OK:
		error = image.load_png_from_buffer(buffer)

	var texture = ImageTexture.create_from_image(image)
	icon_texture.call_deferred("set_texture", texture)

func _on_mouse_entered():
	animation_player.play("Focus")

func _on_mouse_exited():
	animation_player.play_backwards("Focus")
