extends TextureRect

@onready var image_request = %ImageRequest

signal pressed

var CONTEXT_MENU: Array = [
	{
		"text": TranslationServer.translate("VIEW_THE_IMAGE_NAME")
	},
	{
		"text": TranslationServer.translate("SAVE_THE_IMAGE_NAME")
	}
]

var _url: String
var thread_helper: ThreadHelper
var popup_menu: Window = Application.get_popup_menu()
var file_dialog: FileDialog = Application.get_file_dialog()

func _ready():
	thread_helper = ThreadHelper.new(self)

func load_image(url: String):
	_url = url
	image_request.request(url)

func _on_image_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Could not get data")
	else:
		thread_helper.join_function(func(): _load_image_from_thread(body))
		thread_helper.start()

func _load_image_from_thread(buffer: PackedByteArray):
	if buffer.is_empty(): return
	var image = Image.new()
	var error
	if _url.ends_with(".jpeg") or _url.ends_with(".jpg"):
		error = image.load_jpg_from_buffer(buffer)
	elif _url.ends_with(".png"):
		error = image.load_png_from_buffer(buffer)

	if error != OK:
		return
	var _texture = ImageTexture.create_from_image(image)
	call_deferred("set_texture", _texture)

func _on_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed:
		if event.button_index == 1 and event.button_mask == 1:
			pressed.emit()
		elif event.button_index == 2 and event.button_mask == 2:
			popup_menu.populate_items(CONTEXT_MENU)
			popup_menu.show_popup(Application.get_mouse_position())
			popup_menu.index_pressed.connect(on_popup_menu_index_pressed)
			popup_menu.focus_exited.connect(on_popup_menu_focus_exited)

func on_popup_menu_index_pressed(index: int):
	match index:
		0:
			Application.view_the_image(texture)
		1:
			file_dialog.get_line_edit().text = Time.get_datetime_string_from_system(false, true).replace(":", "-")
			file_dialog.clear_filters()
			file_dialog.add_filter("*.png")
			file_dialog.add_filter("*.jpg")
			file_dialog.show()
			var current_file: String = file_dialog.current_file
			var file_extension: String = current_file.get_extension()
			if current_file.is_empty(): return
			var image: Image = texture.get_image()
			if file_extension == "png": image.save_png(current_file)
			elif file_extension == "jpg": image.save_jpg(current_file)

func on_popup_menu_focus_exited():
	if popup_menu.is_connected("index_pressed", on_popup_menu_index_pressed): popup_menu.disconnect("index_pressed", on_popup_menu_index_pressed)
	if popup_menu.is_connected("focus_exited", on_popup_menu_focus_exited): popup_menu.disconnect("focus_exited", on_popup_menu_focus_exited)
