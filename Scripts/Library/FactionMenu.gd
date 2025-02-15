extends Control

@onready var faction_request = %FactionRequest

@onready var handbook_texture = %HandbookTexture
@onready var no_label = %NoLabel
@onready var name_label = %NameLabel
@onready var star_total_label = %StarTotalLabel
@onready var description = %Description

@onready var health_total_label = %HealthTotalLabel
@onready var speed_total_label = %SpeedTotalLabel
@onready var attack_total_label = %AttackTotalLabel
@onready var defense_total_label = %DefenseTotalLabel
@onready var special_attack_total_label = %SpecialAttackTotalLabel
@onready var special_defense_total_label = %SpecialDefenseTotalLabel

func set_data(data: Dictionary) -> void:
	faction_request.request("https://api.codemao.cn/api/sprite/%s" %data.get("id", 0))

func _on_faction_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var data: Dictionary = json.get("data", {})
	var sprite_detail: Dictionary = data.get("sprite_detail")
	handbook_texture.load_image(sprite_detail.get("image", ""), sprite_detail.get("name", "ERROR"))
	no_label.text = "NO.%03d" %int(sprite_detail.get("NO", 0))
	name_label.text = sprite_detail.get("name", "ERROR")
	for _i in range(sprite_detail.get("star", 0)):
		star_total_label.text += ""
	description.text = sprite_detail.get("description", "--")
	health_total_label.text = str(int(sprite_detail.get("hp", "--")))
	speed_total_label.text = str(int(sprite_detail.get("speed", "--")))
	attack_total_label.text = str(int(sprite_detail.get("atk", "--")))
	defense_total_label.text = str(int(sprite_detail.get("def", "--")))
	special_attack_total_label.text = str(int(sprite_detail.get("sp_atk", "--")))
	special_defense_total_label.text = str(int(sprite_detail.get("sp_def", "--")))
