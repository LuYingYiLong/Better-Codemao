extends PanelContainer

@onready var preview_request = %PreviewRequest

@onready var preview_texture = %PreviewTexture
@onready var work_name_label = %WorkNameLabel
@onready var description_label = %DescriptionLabel

var id: int

var thread_helper: ThreadHelper

func _ready():
	preview_request.request_completed.connect(on_preview_received)
	thread_helper = ThreadHelper.new(self)

func set_work_card_data(json: Dictionary):
	id = json.get("id")
	if json.has("work_name"): work_name_label.text = json.get("work_name")
	elif json.has("name"): work_name_label.text = json.get("name")
	preview_request.request(json.get("preview"))
	description_label.text = json.get("description")

func on_preview_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Could not get data")
	else:
		thread_helper.join_function(func(): load_preview_texture_from_thread(body))
		thread_helper.start()

func load_preview_texture_from_thread(buffer: PackedByteArray):
	var image = Image.new()
	var error = image.load_jpg_from_buffer(buffer)
	if error != OK:
		error = image.load_png_from_buffer(buffer)

	var texture = ImageTexture.create_from_image(image)
	preview_texture.call_deferred("set_texture", texture)
