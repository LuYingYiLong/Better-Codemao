extends PanelContainer

@onready var message_count_request = %MessageCountRequest

@onready var message_button = %MessageButton
@onready var user_button = %UserButton
@onready var avatar_texture = %AvatarTexture

@onready var animation_player = %AnimationPlayer

var expanded: bool

func _ready() -> void:
	Application.user_avatar_update.connect(on_user_avatar_update)
	if FileAccess.file_exists(ProjectSettings.globalize_path("user://UserData.json")):
		var user_data: Dictionary = Application.load_json_file("user://UserData.json")
		user_button.text = user_data.get("nickname", "")
	if FileAccess.file_exists(ProjectSettings.globalize_path("user://UserAvatar.png")):
		var image: Image = Image.load_from_file("user://UserAvatar.png")
		avatar_texture.texture = ImageTexture.create_from_image(image)

func _process(_delta) -> void:
	if get_viewport().get_window().size.x >= 1400 and !expanded:
		expanded = true
		animation_player.play("Expand")
	elif get_viewport().get_window().size.x < 1400 and expanded:
		expanded = false
		animation_player.play("Fold")

func on_user_avatar_update() -> void:
	avatar_texture.texture = Application.user_avatar
	if Application.user_id <= 0:
		user_button.text = "VISITOR_NAME"
		avatar_texture.popup_item[3].text = "LOGIN_NAME"
		return
	else:
		avatar_texture.popup_item[3].text = "SIGN_OUT_NAME"
		message_count_request.request("https://api.codemao.cn/web/message-record/count", [Application.generate_cookie_header()], HTTPClient.METHOD_GET)
	if FileAccess.file_exists(ProjectSettings.globalize_path("user://UserData.json")):
		var user_data: Dictionary = Application.load_json_file("user://UserData.json")
		user_button.text = user_data.get("nickname")

func _on_home_button_pressed() -> void:
	Application.set_root_address.emit("HOME_NAME", \
			"res://Scenes/Home/HomeMenu.tscn", \
			{})

func _on_workshop_tab_pressed() -> void:
	Application.set_root_address.emit("WORKSHOP_NAME", \
			"res://Scenes/Workshop/WorkshopMenu.tscn", \
			{})

func _on_forum_tab_pressed() -> void:
	Application.set_root_address.emit("FORUM_NAME", \
			"res://Scenes/Forum/ForumlMenu.tscn", \
			{})

func _on_library_tab_pressed() -> void:
	Application.set_root_address.emit("LIBRARY_NAME", \
			"res://Scenes/Library/LibraryMenu.tscn", \
			{})

func _on_message_button_pressed() -> void:
	message_button.infobadge_value = 0
	message_button.infobadge_visible = false
	Application.set_root_address.emit("MESSAGE_NAME", \
			"res://Scenes/Message/MessageMenu.tscn", \
			{})

func _on_settings_button_pressed() -> void:
	Application.set_root_address.emit("SETTINGS_NAME", \
			"res://Scenes/Settings/SettingsMenu.tscn", \
			{"go_to": "root_options"})

func _on_user_button_pressed() -> void:
	Application.set_root_address.emit("USER_NAME", \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": Application.user_id})

func _on_avatar_texture_popup_menu_callback(id: int) -> void:
	if id == 3:
		if Application.logged_in: Application.sign_out()
		else: Application.show_login_menu.emit()

func _on_message_count_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json_class: JSON = JSON.new()
	if json_class.parse('{"query":%s}' %body.get_string_from_utf8()) != OK:
		Application.emit_system_error_message("JSON parsing failed")
		return
	var json: Dictionary = json_class.data
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	var count: int = 0
	for query: Dictionary in json.get("query"):
		count += query.get("count", 0)
	if count > 0:
		message_button.infobadge_value = count
		message_button.infobadge_visible = true
	else: message_button.infobadge_visible = false
