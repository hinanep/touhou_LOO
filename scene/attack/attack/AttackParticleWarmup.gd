class_name AttackParticleWarmup
extends RefCounted

## 在场景树子节点中收集 Routine 并依次预热其攻击粒子池（开局 / 新技能后调用）


## 等待一帧后预热 root 下所有 Routine 的攻击池
## @param root 通常为 player 或单个 Skill 节点
func warmup_under(root: Node) -> void:
	if root == null or not is_instance_valid(root):
		return
	var tree := root.get_tree()
	if tree == null:
		return
	await _wait_idle_frame(tree)
	var routines: Array[Routine] = []
	_collect_routines(root, routines)
	for routine in routines:
		var prev_mode := routine.process_mode
		routine.process_mode = Node.PROCESS_MODE_ALWAYS
		await routine.warmup_attack_pools_once()
		routine.process_mode = prev_mode


## 递归收集 Routine 子节点
## @param node 遍历起点
## @param out 输出列表
func _collect_routines(node: Node, out: Array[Routine]) -> void:
	for child in node.get_children():
		if child is Routine:
			out.append(child as Routine)
		_collect_routines(child, out)


## 树暂停时仍可推进一帧（供预热 await 使用）
## @param tree 当前场景树
func _wait_idle_frame(tree: SceneTree) -> void:
	await tree.create_timer(0.0, true, false, false).timeout
