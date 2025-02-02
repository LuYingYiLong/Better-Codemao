extends Node

signal sessions_update(sessions: Array)

# 添加会话，返回当前会话索引
func add_session(session_id: String, session_name: String) -> int:
	var sessions: Array = get_sessions()
	sessions.append({"id": session_id, "name": session_name})
	save_sessions(sessions)
	sessions_update.emit(sessions)
	return sessions.size() - 1

# 移除会话
func remove_session(session_id: String) -> void:
	var sessions: Array = get_sessions()
	var index: int = 0
	for session: Dictionary in sessions:
		if session.get("id") == session_id: sessions.remove_at(index)
		index += 1
	sessions_update.emit(sessions)
	save_sessions(sessions)

# 通过会话名字查询会话ID
func find_session_id(session_name: String) -> String:
	var sessions: Array = get_sessions()
	for session: Dictionary in sessions:
		if session.get("name") == session_name: return session.get("id")
	return ""

# 重命名会话名
func rename_session_name(session_id: String, new_name: String) -> void:
	var sessions: Array = get_sessions()
	for session: Dictionary in sessions:
		if session.get("id") == session_id: session["name"] = new_name
	sessions_update.emit(sessions)
	save_sessions(sessions)

# 获取会话列表
func get_sessions() -> Array:
	var user_data: Dictionary = Application.load_json_file(Application.USER_DATA_PATH)
	var couldai: Dictionary = user_data.get("couldai", {})
	var sessions: Array = couldai.get("sessions", [])
	return sessions

func get_session(session_id: String) -> Dictionary:
	var sessions: Array = get_sessions()
	for session: Dictionary in sessions:
		if session.get("id") == session_id: return session
	return {}

# 保存会话列表
func save_sessions(sessions: Array) -> void:
	var user_data: Dictionary = Application.load_json_file(Application.USER_DATA_PATH)
	var couldai: Dictionary = user_data.get("couldai", {})
	couldai["sessions"] = sessions
	user_data["couldai"] = couldai
	Application.save_json_file(Application.USER_DATA_PATH, user_data)

# 获取当前会话
func get_current_session() -> Dictionary:
	var user_data: Dictionary = Application.load_json_file(Application.USER_DATA_PATH)
	var couldai: Dictionary = user_data.get("couldai", {})
	var sessions: Array = couldai.get("sessions", [])
	var current_session_index: int = int(couldai.get("current_session_index", -1))
	if current_session_index < 0 or current_session_index > sessions.size() - 1: return {}
	else: return sessions[current_session_index]

# 设置当前会话
func set_current_session(index: int) -> void:
	var user_data: Dictionary = Application.load_json_file(Application.USER_DATA_PATH)
	var couldai: Dictionary = user_data.get("couldai", {})
	couldai["current_session_index"] = index
