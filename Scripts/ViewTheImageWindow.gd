extends Window

@onready var image_texture = %ImageTexture

const INIT_SIZE: Vector2i = Vector2i(1200, 820)

func populate_image(image: Texture):
	image_texture.texture = image

func show_window():
	size = INIT_SIZE
	show()

func _on_close_requested():
	hide()
