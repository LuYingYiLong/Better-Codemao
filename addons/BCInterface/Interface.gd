class_name Interface extends Object

const _NAME: StringName = &"Interface"

var _object: Object

func _init(object: Object) -> void:
	if !object: return
	_object = object
	_object.set_meta(_NAME + get_interface_name(), self)
	if object is Node:
		(object as Node).ready.connect(_on_object_ready)

func get_object() -> Object:
	return _object

static func get_interface_name() -> StringName:
	return &"Base"

static func get_interface(object: Object, type: StringName = get_interface_name()):
	return object.get_meta(_NAME + type, null)

static func has_interface(object: Object) -> bool:
	return get_interface(object) != null

signal on_forum_posts_changed(posts: Array)
func forum_posts_changed(posts: Array):
	on_forum_posts_changed.emit(posts)

func _on_object_ready() -> void:
	on_ready()

func on_ready() -> void: pass

class BCInterface extends Interface:
	static func get_interface_name() -> StringName:
		return &"BCInterface"
	
	static func get_interface(object: Object, type: StringName = get_interface_name()) -> BCInterface:
		return super(object, type) as BCInterface
	
	#定义抽象方法
	static func version() -> String: return "1.0"
