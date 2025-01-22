extends VBoxContainer

const CONTENT_LABEL_SCENE = preload("res://Scenes/Forum/ContentLabel.tscn")
const IMAGE_URL_LOADER_SCENE = preload("res://Scenes/ImageUrlLoader.tscn")
const CODE_VIEWER_SCENE = preload("res://Scenes/Forum/CodeViewer.tscn")

var code_language: String

# 初始化富内容
func init_contents(rich_text: String) -> void:
	for node in get_children():
		node.queue_free()
	var bbcode_content: String = Application.html_to_bbcode(rich_text)
	populate_content(bbcode_content)

# 递归装载富内容
func populate_content(bbcode_content: String) -> void:
	var content_label_scene = CONTENT_LABEL_SCENE.instantiate()
	var image_url_loader = IMAGE_URL_LOADER_SCENE.instantiate()
	var code_viewer_scene = CODE_VIEWER_SCENE.instantiate()
	var regex = RegEx.new()
	regex.compile("(\\[.+?\\])")

	for result in regex.search_all(bbcode_content):
		var get_string: String = result.get_string()

		if get_string.begins_with("[language=") and get_string.ends_with("]"):
			code_language = get_string.trim_prefix("[language=").trim_suffix("]")
			var pos: int = bbcode_content.find(get_string)
			var result_length: int = get_string.length()
			for i: int in range(result_length):
				bbcode_content[pos] = ""
		elif get_string == "[/language]":
			code_language = ""
			var pos: int = bbcode_content.find(get_string)
			var result_length: int = get_string.length()
			for i: int in range(result_length):
				bbcode_content[pos] = ""

		# 添加图像
		elif get_string.begins_with("[image=") and get_string.ends_with("]"):
			var split: PackedStringArray = bbcode_content.split(get_string)
			add_child(content_label_scene)
			content_label_scene.append_text(split[0])
			
			add_child(image_url_loader)
			image_url_loader.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			image_url_loader.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
			image_url_loader.load_image(get_string.trim_prefix("[image=").trim_suffix("]"))
			
			if split.size() >= 2:
				populate_content(split[1])
				return

		if get_string == "[code]":
			var split: PackedStringArray = bbcode_content.split("[code]")
			split.append(split[1].get_slice("[/code]", 1))
			split.set(1, split[1].get_slice("[/code]", 0))
			
			add_child(content_label_scene)
			content_label_scene.append_text(split[0])
			
			add_child(code_viewer_scene)
			code_viewer_scene.text = split[1]
			code_viewer_scene.type = code_language
			if split.size() >= 3: populate_content(split[2])
			return

	add_child(content_label_scene)
	content_label_scene.append_text(bbcode_content)
