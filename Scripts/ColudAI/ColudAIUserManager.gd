extends Node

signal login_data_update(new_login_data: Dictionary)
signal user_data_update(new_user_data: Dictionary)
signal ca_update(new_ca: String)

# 保存登录数据
func save_login_data(data: Dictionary) -> void:
	var login_data: Dictionary = Application.load_json_file(Application.LOGIN_DATA_PATH)
	var coludai: Dictionary = login_data.get("coludai", {})
	coludai["login_data"] = data
	login_data["coludai"] = coludai
	Application.save_json_file(Application.LOGIN_DATA_PATH, login_data)
	login_data_update.emit(data)

# 获取登录数据
func get_login_data() -> Dictionary:
	var login_data: Dictionary = Application.load_json_file(Application.LOGIN_DATA_PATH)
	var coludai: Dictionary = login_data.get("coludai", {})
	return coludai.get("login_data", {})

# 保存 Cookie
func save_cookie(cookie: String) -> void:
	var login_data: Dictionary = Application.load_json_file(Application.LOGIN_DATA_PATH)
	var coludai: Dictionary = login_data.get("coludai", {})
	coludai["cookie"] = cookie
	login_data["coludai"] = coludai
	Application.save_json_file(Application.LOGIN_DATA_PATH, login_data)

# 获取 Cookie
func get_cookie() -> String:
	var login_data: Dictionary = Application.load_json_file(Application.LOGIN_DATA_PATH)
	var coludai: Dictionary = login_data.get("coludai", {})
	return coludai.get("cookie", "")

# 保存用户数据
func save_user_data(data: Dictionary) -> void:
	var user_data: Dictionary = Application.load_json_file(Application.USER_DATA_PATH)
	var coludai: Dictionary = user_data.get("coludai", {})
	coludai["user_data"] = data
	user_data["coludai"] = coludai
	Application.save_json_file(Application.USER_DATA_PATH, user_data)
	user_data_update.emit(data)

# 获取用户数据
func get_user_data() -> Dictionary:
	var user_data: Dictionary = Application.load_json_file(Application.USER_DATA_PATH)
	var coludai: Dictionary = user_data.get("coludai", {})
	return coludai.get("user_data", {})

# 保存 CA
func save_ca(ca: String) -> void:
	var login_data: Dictionary = Application.load_json_file(Application.LOGIN_DATA_PATH)
	var coludai: Dictionary = login_data.get("coludai", {})
	coludai["ca"] = ca
	login_data["coludai"] = coludai
	Application.save_json_file(Application.LOGIN_DATA_PATH, login_data)
	ca_update.emit(ca)

# 获取 CA
func get_ca() -> String:
	var login_data: Dictionary = Application.load_json_file(Application.LOGIN_DATA_PATH)
	var coludai: Dictionary = login_data.get("coludai", {})
	return coludai.get("ca", "c9b3f395-f8e6-47f4-98c0-64b5ac6fc1f0")

# 退出登录
func sign_out() -> void:
	var login_data: Dictionary = Application.load_json_file(Application.LOGIN_DATA_PATH)
	var login_to_coludai: Dictionary = login_data.get("coludai", {})
	login_to_coludai = {}
	Application.save_json_file(Application.LOGIN_DATA_PATH, login_data)
	var user_data: Dictionary = Application.load_json_file(Application.USER_DATA_PATH)
	var user_to_coludai: Dictionary = user_data.get("coludai", {})
	user_to_coludai = {}
	Application.save_json_file(Application.USER_DATA_PATH, user_data)
	login_data_update.emit(login_to_coludai)
	user_data_update.emit(user_to_coludai)
