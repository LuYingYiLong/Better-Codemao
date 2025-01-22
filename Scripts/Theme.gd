extends Node

const PRESET_COLOR_JSON: String = "user://Preset-color.json"

func get_preset_color_array() -> Array:
	var preset_color_json: Dictionary = Application.load_json_file(PRESET_COLOR_JSON)
	return preset_color_json.get("preset_color", [])

func add_preset_color(color: Color) -> void:
	var preset_color_json: Dictionary = Application.load_json_file(PRESET_COLOR_JSON)
	var preset_color: Array = preset_color_json.get("preset_color", [])
	preset_color.insert(0, color.to_html(false))
	preset_color_json["preset_color"] = preset_color
	Application.save_json_file(PRESET_COLOR_JSON, preset_color_json)

func remove_preset_color(pos: int) -> void:
	var preset_color_json: Dictionary = Application.load_json_file(PRESET_COLOR_JSON)
	var preset_color: Array = preset_color_json.get("preset_color", [])
	preset_color.remove_at(pos)
	preset_color_json["preset_color"] = preset_color
	Application.save_json_file(PRESET_COLOR_JSON, preset_color_json)

#浅色&深色模式调色板
var light_mode_palette: String = "#1b1b1b"
var light_mode_translucent_palette: String = "#0f0f0f7d"
var dark_mode_palette: String = "#ffffff"
var dark_mode_translucent_palette: String = "#ccccce"

#浅色&深色模式下的字体颜色
var light_mode_font_color: String = "#1b1b1b"
var dark_mode_font_color: String = "#ffffff"

#浅色&深色模式下的地址栏字体颜色
var light_mode_address_tab_bar_font_selected_color: String = "#1b1b1b"
var light_mode_address_tab_bar_font_unselected_color: String = "#747474"
var dark_mode_address_tab_bar_font_selected_color: String = "#ffffff"
var dark_mode_address_tab_bar_font_unselected_color: String = "#ccccce"

#浅色&深色模式下的图标颜色
var light_mode_icon_color: String = "#1b1b1b"
var light_mode_translucent_icon_color: String = "#0f0f0f7d"
var dark_mode_icon_color: String = "#ffffff"
var dark_mode_translucent_icon_color: String = "#ffffff7d"

#工作室标签等级颜色
var work_shop_level_0_tag_color: String = "#ac9093"
var work_shop_level_1_tag_color: String = "#e5b499"
var work_shop_level_2_tag_color: String = "#cfdff2"
var work_shop_level_3_tag_color: String = "#ffd454"
var work_shop_level_4_tag_color: String = "#ffc987"

#作者标签等级颜色
var author_level_2_tag_color: String = "#92a7be"
var author_level_3_tag_color: String = "#7aa0ec"
var author_level_4_tag_color: String = "#fed135"
var author_level_5_tag_color: String = "#9600d3"

#置顶颜色
var top_color: String = "#6eff72"

#系统消息颜色
var system_ok_message_color: String = "#0067c0"
var system_warning_message_color: String = "#ffb300"
var system_error_message_color: String = "#cc2929"

var default_ok_color: String = "#2e8b57"
var default_warning_color: String = "#ffb300"
var default_error_color: String = "#cc2929"

var progress_running_color: String = "#0067c0"
var progress_paused_color: String = "#9d5d00"
var progress_error_color: String = "#c42b1c"
