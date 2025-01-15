extends SyntaxHighlighter

var python_keywords = [
	"def", 
	"class", 
	"if", 
	"else", 
	"elif", 
	"for", 
	"while", 
	"return", 
	"break", 
	"continue"
]

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var text_edit = get_text_edit()
	var line_text = text_edit.get_line(line)
	var color_map = {}

	# 高亮注释
	var comment_pos = line_text.find("#")
	if comment_pos != -1:
		for i in range(comment_pos, line_text.length()):
			color_map[i] = {"color": Color(0.5, 0.5, 1.0)}  # 蓝灰色

	# 高亮字符串
	var in_string = false
	var string_char = '"'
	for i in range(line_text.length()):
		if (in_string and line_text[i] == string_char) or (not in_string and (line_text[i] == '"' or line_text[i] == "'")):
			in_string = not in_string
			string_char = line_text[i]
		if in_string:
			color_map[i] = {"color": Color(1.0, 0.5, 0.5)}  # 粉红色

	# 高亮关键字
	var words = line_text.split(" ")
	var current_pos = 0
	for word in words:
		var trimmed_word = word.replace(" ", "")  # 使用 trim 方法去除空白字符
		if trimmed_word in python_keywords:
			for i in range(current_pos, current_pos + trimmed_word.length()):
				color_map[i] = {"color": Color(1.0, 0.0, 0.0)}  # 红色
		current_pos += word.length() + 1  # 加1是因为split会去掉空格

	return color_map
