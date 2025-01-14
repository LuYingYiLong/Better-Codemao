extends Window

@export var scale: Vector2 = Vector2(1, 1)

@onready var panel_container = %PanelContainer
@onready var image_texture = %ImageTexture
@onready var animation_player = %AnimationPlayer

const INIT_SIZE: Vector2i = Vector2i(1200, 820)
const SPEED: float = 10.0

var drag_start: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var scale_speed: float = 0.01# 缩放速度

func populate_image(image: Texture):
	image_texture.texture = image
	image_texture.pivot_offset = image_texture.size / 2
	image_texture.position = size / 2

func show_window():
	panel_container.self_modulate = DisplayServer.get_base_color()
	scale = Vector2(1, 1)
	image_texture.scale = scale
	size = INIT_SIZE
	show()

func _on_close_requested():
	hide()

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			drag_start = event.position - image_texture.position
			is_dragging = true
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = false
	elif event is InputEventMouseMotion and is_dragging:
		image_texture.position = event.position - drag_start
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		zoom_image(1.1)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		zoom_image(0.9)

func zoom_image(scale_factor: float):
	image_texture.scale *= scale_factor

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
