extends PanelContainer

@onready var check_updates_request = %CheckUpdatesRequest

@onready var ok_icon = %OKIcon

@onready var checking_panel = %CheckingPanel
@onready var is_latest_version_panel = %IsLatestVersionPanel
@onready var has_latest_version_panel = %HasLatestVersionPanel
@onready var a_new_version_is_available_label = %ANewVersionIsAvailableLabel
@onready var last_check_time_label = %LastCheckTimeLabel
@onready var get_updates_panel = %GetUpdatesPanel

@onready var check_for_updates_button = %CheckForUpdatesButton

func _ready():
	var user_data: Dictionary = Application.load_json_file(Application.USER_DATA_PATH)
	print_last_check_time(user_data.get("last_check_time", {}))

func _on_check_for_updates_button_pressed() -> void:
	check_for_updates_button.disabled = true
	check_updates_request.request("https://api.github.com/repos/LuYingYiLong/Better-Codemao/issues/1")
	ok_icon.hide()
	checking_panel.show()
	is_latest_version_panel.hide()

func _on_check_updates_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	check_for_updates_button.disabled = false
	var json_class: JSON = JSON.new()
	if json_class.parse(body.get_string_from_utf8()) != OK:
		Application.emit_system_error_message("JSON parsing failed")
		return
	var json: Dictionary = json_class.data
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	var user_data: Dictionary = Application.load_json_file(Application.USER_DATA_PATH)
	var current_version: PackedStringArray = ProjectSettings.get_setting("application/config/version").split(".")
	var latest_version: PackedStringArray = json.get("body").split(".")
	var has_lastest_version: bool
	if latest_version.size() > current_version.size():
		has_lastest_version = true
	else:
		var index: int = 0
		for i: String in latest_version:
			if i.to_int() > current_version[index].to_int():
				has_lastest_version = true
				break
			index += 1
	checking_panel.hide()
	if has_lastest_version:
		a_new_version_is_available_label.text = TranslationServer.translate("A_NEW_VERSION_IS_AVAILABLE_DESCRIPTION").format([latest_version, current_version])
		has_latest_version_panel.show()
		get_updates_panel.show()
	else:
		print_last_check_time(user_data.get("last_check_time", {}))
		is_latest_version_panel.show()
	user_data["last_check_time"] = Time.get_datetime_dict_from_system()
	Application.save_json_file(Application.USER_DATA_PATH, user_data)
	ok_icon.show()

func print_last_check_time(date_dict: Dictionary) -> void:
	if !date_dict.is_empty():
		last_check_time_label.text = "%s: %s%s%s%s%s%s %s:%s" %[
			TranslationServer.translate("LAST_CHECK_TIME_NAME"),
			date_dict.get("year", "--"),
			TranslationServer.translate("YEAR_NAME"),
			date_dict.get("month", "--"),
			TranslationServer.translate("MONTH_NAME"),
			date_dict.get("day", "--"),
			TranslationServer.translate("DAY_NAME1"),
			date_dict.get("hour"),
			date_dict.get("minute")
		]
	last_check_time_label.visible = !date_dict.is_empty()
