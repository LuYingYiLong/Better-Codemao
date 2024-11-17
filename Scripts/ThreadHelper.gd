class_name ThreadHelper extends RefCounted

var _thread = Thread.new()
var _function: Array
var _holder: Node

#初始化
func _init(holder: Node):
	_holder = holder
	_holder.tree_exited.connect(end)

#加入函数
func join_function(function: Callable):
	_function.append(function)

#开始
func start():
	assert(_holder, "holder 必须存在")
	if _thread.is_alive():
		return
		
	if _thread.is_started():
		_thread.wait_to_finish()
	_thread.start(_start_thread)

#返回该线程是否正在进行
func is_running():
	return _thread.is_alive()

#结束线程
func end():
	_end_thread()

#开始线程
func _start_thread():
	while true:
		if not _function:
			break
		var function = _function.pop_front()
		function.call()

#结束线程
func _end_thread():
	_function.clear()
	if _thread.is_started():
		_thread.wait_to_finish()
