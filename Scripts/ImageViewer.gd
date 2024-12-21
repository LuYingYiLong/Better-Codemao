extends Window

@export var scale: Vector2 = Vector2(1, 1)

@onready var image_texture = %ImageTexture
@onready var animation_player = %AnimationPlayer

const INIT_SIZE: Vector2i = Vector2i(1200, 820)
const SPEED: float = 10.0

var dragging: bool

func _process(delta):
	image_texture.scale = image_texture.scale.lerp(scale, delta * SPEED)

func populate_image(image: Texture):
	image_texture.texture = image
	image_texture.position = size / 2

func show_window():
	scale = Vector2(1, 1)
	image_texture.scale = scale
	size = INIT_SIZE
	show()

func _on_close_requested():
	hide()

func _on_panel_container_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed:
			if event.button_index == 1:
				dragging = event.button_mask
			elif event.button_index == 4:
				scale += Vector2(0.25, 0.25)
				scale = scale.clamp(Vector2(0.1, 0.1), Vector2(10, 10))
			elif event.button_index == 5:
				scale += Vector2(-0.25, -0.25)
				scale = scale.clamp(Vector2(0.1, 0.1), Vector2(10, 10))
	if event is InputEventMouseMotion and dragging:
		var velocity: Vector2 = event.velocity
		image_texture.position = image_texture.position + velocity / 100

func _on_rotation_button_pressed():
	var rotation_degrees: int = floori(image_texture.rotation_degrees)
	match rotation_degrees:
		0:
			animation_player.play("RotationTo90")
		90:
			animation_player.play("RotationTo180")
		179:
			animation_player.play("RotationTo270")
		270:
			animation_player.play("RotationTo360")
			await animation_player.animation_finished
			image_texture.rotation = 0.0
