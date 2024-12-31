extends PanelContainer

@onready var address_tab_bar = %AddressTabBar
@onready var pages = %Pages

const ARROW_TEXTURE = preload("res://Resources/Textures/Arrow.svg")
const PAGE_CONTAINER_SCENE = preload("res://Scenes/PageContainer.tscn")

const MAX_STRING_LENGTH: int = 16

var address: Dictionary
var address_size: int

var last_selected_id: int = -1
var now_selected_id: int

var is_playing: bool

func _ready():
	Application.append_address.connect(append_address)
	Application.set_root_address.connect(set_root_address)

func set_root_address(address_name: String, scene_path: String = "", data: Dictionary = {}):
	address.clear()
	is_playing = false
	if address_name.length() > MAX_STRING_LENGTH:
		address_name = "%s..." %address_name.erase(MAX_STRING_LENGTH, address_name.length() - MAX_STRING_LENGTH)
	address["0"] = {"name": address_name, "selected": true}
	address_size = 1
	address_tab_bar.clear_tabs()
	address_tab_bar.add_tab(address_name)
	#保留第一页，删除其他页面
	var count: int = -1
	for node in pages.get_children():
		count += 1
		if count > 0: node.queue_free()

	#获取第一页并播放向左推出动画后删除
	var scene_node = pages.get_node("0")
	if scene_node != null:
		scene_node.name = "-1"
		scene_node.queue_free()

	var page_container_scene = PAGE_CONTAINER_SCENE.instantiate()
	pages.add_child(page_container_scene)
	page_container_scene.name = str(address_size - 1)
	await get_tree().create_timer(0.025).timeout
	page_container_scene._show("PushInTop")
	if !scene_path.is_empty(): page_container_scene.load_scene(scene_path, data)

func append_address(address_name: String, scene_path: String = "", data: Dictionary = {}):
	if is_playing: return
	address[str(address_size)] = {"name": address_name, "selected": false}
	address_size += 1
	if address_name.length() > MAX_STRING_LENGTH:
		address_name = "%s..." %address_name.erase(MAX_STRING_LENGTH, address_name.length() - MAX_STRING_LENGTH)
	address_tab_bar.add_tab(address_name, ARROW_TEXTURE)
	var page_container_scene = PAGE_CONTAINER_SCENE.instantiate()
	pages.add_child(page_container_scene)
	page_container_scene.name = str(address_size - 1)
	if !scene_path.is_empty(): page_container_scene.load_scene(scene_path, data)
	address_tab_bar.current_tab = address_size - 1

func _on_address_tab_bar_tab_selected(tab: int):
	if is_playing: return
	is_playing = true
	var queue_free_ids: Array
	var last_scene_node
	var now_scene_node

	now_selected_id = tab

	for id: String in address:
		var address_data: Dictionary = address.get(id)

		#查找上一次选择的页面ID并记录
		if id.to_int() < tab:
			address_data["selected"] = false
			last_scene_node = pages.get_node(id)

		#查找现在选择的页面ID并记录
		elif id.to_int() == tab:
			address_data["selected"] = true
			now_scene_node = pages.get_node(id)

		#如果该页面ID位于现在选择的页面ID后面，则标记为要清除的页面
		elif id.to_int() > tab:
			if last_selected_id == -1:
				last_selected_id = id.to_int()
				last_scene_node = pages.get_node(id)
			queue_free_ids.append(id)

	#对比位置关系做出相应的动画
	if last_selected_id < now_selected_id:
		if last_scene_node != null:
			last_scene_node._hide("PushOutLeft")
			await last_scene_node.animation_finished
		if now_scene_node != null: now_scene_node._show("PushInLeft")

	elif last_selected_id > now_selected_id:
		last_scene_node = pages.get_node(str(last_selected_id))
		if last_scene_node != null:
			last_scene_node._hide("PushOutRight")
			await last_scene_node.animation_finished
		if now_scene_node != null: now_scene_node._show("PushInRight")

	last_selected_id = now_selected_id
	last_scene_node = pages.get_node(str(last_selected_id))
	#清除标记的页面
	for id in queue_free_ids:
		address_tab_bar.remove_tab(address_tab_bar.current_tab + 1)
		address.erase(id)
		address_size -= 1
		var node = pages.get_node(id)
		if node != null: node.queue_free()
	is_playing = false
