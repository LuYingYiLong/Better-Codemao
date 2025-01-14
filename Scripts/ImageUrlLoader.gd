extends TextureRect

@export var popup_item: Array[PopupItem]

@onready var image_request = %ImageRequest

@onready var name_panel = %NamePanel
@onready var name_label = %NameLabel

signal pressed
signal popup_menu_callback(id: int)

const SUFFIX_TYPES: Dictionary = {
	".jpeg": "jpg",
	".jpg": "jpg",
	".cover": "jpg",
	".png": "png",
	".dll": "gif",
	".gif": "gif"
}

var _url: String
var _name: String
var thread_helper: ThreadHelper
var popup_menu: Window = Application.get_popup_menu()
var file_dialog: FileDialog = Application.get_file_dialog()

var menu

func _ready() -> void:
	thread_helper = ThreadHelper.new(self)

func load_image(url: String, _name_: String = "") -> void:
	if url.is_empty(): return
	_url = url
	_name = _name_
	var has_suffix: bool
	for key: String in SUFFIX_TYPES.keys():
		has_suffix = url.ends_with(key)
		if has_suffix: break
	if has_suffix:
		image_request.request(url)
	else:
		image_request.request(url, ["Content-Type: image/png"])

func _on_image_request_request_completed(result: int, _response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Could not get data")
	else:
		if _url.ends_with(".gif") or _url.ends_with(".dll"):
			var animated_sprite_2d := AnimatedSprite2D.new()
			texture = null
			add_child(animated_sprite_2d)
			var my_size: Vector2 = size
			thread_helper.join_function(func(): _load_gif_from_thread(animated_sprite_2d, body, my_size))
			thread_helper.start()
		else:
			thread_helper.join_function(func(): _load_image_from_thread(body, headers))
			thread_helper.start()

func _load_image_from_thread(buffer: PackedByteArray, headers: PackedStringArray) -> void:
	if buffer.is_empty(): return
	var image = Image.new()
	var error
	if headers.has("Content-Type: image/jpeg"):
		error = image.load_jpg_from_buffer(buffer)
	elif headers.has("Content-Type: image/png"):
		error = image.load_png_from_buffer(buffer)

	if error != OK and !_name.is_empty():
		call_deferred("set_texture", null)
		name_panel.call_deferred("set_visible", true)
		name_label.call_deferred("set_text", _name[0])
	else:
		if image.is_empty(): return
		var _texture = ImageTexture.create_from_image(image)
		call_deferred("set_texture", _texture)

func _load_gif_from_thread(animated_sprite_2d: AnimatedSprite2D, buffer: PackedByteArray, my_size: Vector2) -> void:
	var sprite_frames: SpriteFrames = GifManager.sprite_frames_from_buffer(buffer)
	if sprite_frames == null: return
	animated_sprite_2d.call_deferred_thread_group("set_sprite_frames", sprite_frames)
	var texture_2d: Texture2D = sprite_frames.get_frame_texture("gif", 1)
	if texture_2d == null: return
	var texture_size = Vector2(texture_2d.get_width(), texture_2d.get_height())
	var scale_x = my_size.x / texture_size.x
	var scale_y = my_size.y / texture_size.y
	animated_sprite_2d.call_deferred_thread_group("set_scale", Vector2(scale_x, scale_y))
	animated_sprite_2d.call_deferred_thread_group("play", "gif")
	animated_sprite_2d.call_deferred_thread_group("set_position", my_size / 2)

func _on_gui_input(event) -> void:
	if event is InputEventMouseButton and event.is_pressed:
		if event.button_index == 1 and event.button_mask == 1:
			pressed.emit()
		elif event.button_index == 2 and event.button_mask == 2:
			#if popup_menu == null: popup_menu = Application.get_popup_menu()
			#popup_menu.populate_items(popup_item)
			#popup_menu.set_pos(DisplayServer.mouse_get_position())
			#popup_menu.index_pressed.connect(on_popup_menu_index_pressed)
			#popup_menu.focus_exited.connect(on_popup_menu_focus_exited)
			menu = NativeMenu.create_menu()
			var count: int = 0
			for item in popup_item:
				if item != null: NativeMenu.add_item(menu, TranslationServer.translate(item.text), _menu_callback, Callable(), str(count))
				else: NativeMenu.add_separator(menu)
				count += 1
			NativeMenu.popup(menu, DisplayServer.mouse_get_position())

func on_popup_menu_index_pressed(index: int) -> void:
	match index:
		0:
			Application.view_the_image(texture)
		1:
			if file_dialog == null: file_dialog = Application.get_file_dialog()
			file_dialog.get_line_edit().text = Time.get_datetime_string_from_system(false, true).replace(":", "-")
			file_dialog.clear_filters()
			file_dialog.add_filter("*.png")
			file_dialog.add_filter("*.jpg")
			file_dialog.visible = true
			
			var current_file: String = file_dialog.current_file
			var file_extension: String = current_file.get_extension()
			if current_file.is_empty(): return
			var image: Image = texture.get_image()
			if file_extension == "png": image.save_png(current_file)
			elif file_extension == "jpg": image.save_jpg(current_file)

func _menu_callback(item_id: String) -> void:
	var id: int = item_id.to_int()
	if id == 0:
		Application.view_the_image(texture)
	elif id == 1:
		if file_dialog == null: file_dialog = Application.get_file_dialog()
		file_dialog.get_line_edit().text = Time.get_datetime_string_from_system(false, true).replace(":", "-")
		file_dialog.clear_filters()
		file_dialog.add_filter("*.png")
		file_dialog.add_filter("*.jpg")
		file_dialog.visible = true
		
		var current_file: String = file_dialog.current_file
		var file_extension: String = current_file.get_extension()
		if current_file.is_empty(): return
		var image: Image = texture.get_image()
		if file_extension == "png": image.save_png(current_file)
		elif file_extension == "jpg": image.save_jpg(current_file)
	else:
		popup_menu_callback.emit(id)

func on_popup_menu_focus_exited() -> void:
	if popup_menu.is_connected("index_pressed", on_popup_menu_index_pressed): popup_menu.disconnect("index_pressed", on_popup_menu_index_pressed)
	if popup_menu.is_connected("focus_exited", on_popup_menu_focus_exited): popup_menu.disconnect("focus_exited", on_popup_menu_focus_exited)
