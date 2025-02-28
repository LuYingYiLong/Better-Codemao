extends PanelContainer

@onready var handbook_texture = %HandbookTexture
@onready var name_label = %NameLabel

signal pressed(id: int)

const SPEED: float = 10.0

var id: int

var is_mouse_inside = false

func _ready() -> void:
	var card_material: ShaderMaterial = ShaderMaterial.new()
	card_material.shader = load("res://Shaders/Hover3D.gdshader")
	card_material.set_shader_parameter("_tilt_Scale", 0.2)
	card_material.set_shader_parameter("_isSpecularLight", true)
	card_material.set_shader_parameter("_speularLightPower", 5.0)
	handbook_texture.material = card_material
	handbook_texture.set_process_input(true)

func _process(delta: float) -> void:
	if handbook_texture.material is ShaderMaterial and !is_mouse_inside:
		var error = handbook_texture.material.get_shader_parameter("_mousePos")
		if error is Vector2:
			var mouse_pos: Vector2 = error
			if mouse_pos != Vector2.ZERO:
				var target_pos: Vector2 = mouse_pos.lerp(Vector2.ZERO, delta * SPEED)
				handbook_texture.material.set_shader_parameter("_mousePos", target_pos)

func set_faction_card_data(data: Dictionary) -> void:
	id = int(data.get("id", 0))
	handbook_texture.load_image(data.get("handbook_image", ""), data.get("name"))
	name_label.text = data.get("name")

func _on_card_pressed() -> void:
	pressed.emit(id)

func _input(event) -> void:
	if event is InputEventMouseMotion and is_mouse_inside:
		var mouse_position = event.position
		var relative_mouse_position = mouse_position - position
		handbook_texture.material.set_shader_parameter("_mousePos", relative_mouse_position / scale - size / 2.0)

func _on_handbook_texture_mouse_entered() -> void:
	is_mouse_inside = true

func _on_handbook_texture_mouse_exited() -> void:
	is_mouse_inside = false
