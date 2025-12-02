# ObjectPool.gd
class_name ObjectPool extends RefCounted

# 信号：当一个对象被回收时发出
signal object_returned(object)

var prefab: PackedScene
var pool: Array = []
var parent_node: Node # 所有被取出的对象都将成为这个节点的子节点

func _init(p_prefab: PackedScene, p_parent_node: Node):
	self.prefab = p_prefab
	self.parent_node = p_parent_node

# 从池中获取一个对象
func get_object(parent = parent_node) -> Node:
	if not pool.is_empty():
		var obj = pool.pop_back()
		# 确保节点是有效的，以防在其他地方被意外释放
		if is_instance_valid(obj):
			obj.process_mode = Node.PROCESS_MODE_INHERIT
			return obj
	if not is_instance_valid(parent):
		parent = parent_node
	# 如果池是空的，创建一个新的
	if prefab:
		var new_obj = prefab.instantiate()
		parent.add_child(new_obj)

		# 非常重要：让对象知道如何回到池中
		# 假设对象有一个名为 "returned_to_pool" 的信号
		if new_obj.has_signal("returned_to_pool"):
			new_obj.returned_to_pool.connect(return_object)
		return new_obj

	return null
func disable_object(obj:Node):
	obj.process_mode = Node.PROCESS_MODE_DISABLED
# 将对象返回到池中
func return_object(obj: Node):
	if not is_instance_valid(obj):
		return

	# 从场景树中移除，但不要释放它
	#if obj.get_parent() == parent_node:
	if true:
		call_deferred("disable_object",obj)

		obj.hide() # 隐藏起来
		obj.position = Vector2.ZERO
		pool.push_back(obj)
		object_returned.emit(obj)

# 清空对象池，释放所有节点
func clear():
	for obj in pool:
		if is_instance_valid(obj):
			obj.queue_free()
	pool.clear()
