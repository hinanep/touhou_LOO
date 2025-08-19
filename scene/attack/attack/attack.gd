extends Node2D
class_name attack

var level =0
#击杀目标发出的信号
signal kill(global_position)
signal start
#所属对象池的索引
var index = 0
signal over(this_node)
@export var damage_source :String
@export var attack_info = {
	  }


#已伤害目标，用于防止非dot多次伤害？暂时没必要
#var damaged_bodies = []

#已穿透目标数量
var penetration = 0
#节点活动性
var node_active = true
var batch_num = 0
#招式可能传入的索敌与方向
var lock_routine
var diretion_routine = Vector2(0,0)
#dot开启状态
var dot_on = false
#组件
var lock_compo
var move_compo
var recycling = false
func first_init():
	const cont = 2
	name = attack_info.id
	if attack_info.type == 'base':
		SignalBus.atk_boost.connect(recive_boost,cont)
	elif attack_info.type == 'boost':
		SignalBus.cp_active.connect(boost_active.bind(true),cont)
		SignalBus.cp_del.connect(boost_active.bind(false),cont)
		return
	$damage_area.connect("body_entered",_on_damage_area_body_entered,cont)
	$duration_timer.connect("timeout",destroy.bind('timeout'),cont)

	kill.connect(on_kill,cont)
	SignalBus.upgrade_group.connect(upgrade_attack,cont)
	SignalBus.boss_stage.connect(set_bossing)
	if not (attack_info.bullet_eraseing):
		$bullet_erase_area.queue_free()

	if attack_info.has('reflection'):
		if attack_info.reflection.has('enemy'):
			$".".collision_mask += 2
		if attack_info.reflection.has('wall'):
			$".".collision_mask += 4
	set_shape(attack_info.shape)
	if attack_info.has('buff'):
		$damage_area.collision_mask = 1
	damage_source = attack_info.damage_belong


var	future_world_position = Vector2.ZERO


@export var particles :Array[Node]= []
func spawn(true_level:int) -> void:
	penetration = 0
	recycling = false
	if not attack_info.has("upgrade_group") or level == true_level:
		return
	upgrade_to_level(attack_info.upgrade_group,true_level)

func reinit(position:Vector2):
	move_compo.reinit(position)
	if attack_info.has('duration') and attack_info.duration>0.1:
		if attack_info.has('duration_dependence') :
				$duration_timer.wait_time = player_var.dep.operate_dep(attack_info.duration_dependence,attack_info.duration)
		else:
				$duration_timer.wait_time = attack_info.duration
	if node_active:
		$duration_timer.start()
		start.emit()
		#if not attack_info.reference_system == 'world':
		global_position = position
	$lock_component.set_frame(0)
	for particle in particles:
		particle.restart()
#初始化
var first_ready = true
func _ready():
	if not first_ready:
		reinit(future_world_position)
		return
	first_ready = false
	if attack_info.has('duration') and attack_info.duration>0.1:

		if attack_info.has('duration_dependence') :

				$duration_timer.wait_time = player_var.dep.operate_dep(attack_info.duration_dependence,attack_info.duration)
		else:

				$duration_timer.wait_time = attack_info.duration

	set_active(node_active)
	if node_active:
		$duration_timer.start()
		start.emit()
		if attack_info.reference_system == 'world':
			top_level = true
		else:
			global_position = position
	lock_compo = $lock_component.init($".",attack_info.get('locking_type'),lock_routine)
	move_compo = $move_component.init($".",attack_info,lock_compo,diretion_routine)



#运动组件更新
func _physics_process(delta):

	move_compo.update(delta)


#初始化攻击形状
func set_shape(cshape):
	var addi = 1
	if attack_info.has('size_dependence'):
		addi = player_var.dep.operate_dep(attack_info.size_dependence,addi)
	var texture = $lock_component
	match cshape:
		'circle':
			cshape = CircleShape2D.new()

			cshape.radius = attack_info.size[0]
			texture.scale *= attack_info.size[0]/20

			$VisibleOnScreenNotifier2D.scale = Vector2(1,1)* attack_info.size[0]
			$damage_area/CollisionShape2D.position = Vector2(0,0)
			$bullet_erase_area/CollisionShape2D.position = Vector2(0,0)
			$move_component.position = Vector2(0,0)
		'rectangle_center':

			cshape = RectangleShape2D.new()
			cshape.size = Vector2(attack_info.size[0],attack_info.size[1])
			texture.scale *= Vector2(attack_info.size[1]/20,attack_info.size[0]/20)

			$VisibleOnScreenNotifier2D.rect = Rect2(-cshape.size/2,cshape.size)
		'rectangle_edge':
			cshape = RectangleShape2D.new()
			cshape.size = Vector2(attack_info.size[0],attack_info.size[1])
			$VisibleOnScreenNotifier2D.rect = Rect2(-Vector2(attack_info.size[0]/2,attack_info.size[1]),cshape.size)
			#矩形中心点
			$damage_area/CollisionShape2D.position = Vector2(0,-attack_info.size[1]/2)
			$bullet_erase_area/CollisionShape2D.position = Vector2(0,-attack_info.size[1]/2)
			$move_component.position = Vector2(0,-attack_info.size[1]/2)
			texture.scale *= Vector2(attack_info.size[0]/20,attack_info.size[1]/20)

	$damage_area/CollisionShape2D.shape = cshape
	$bullet_erase_area/CollisionShape2D.shape = cshape
	$move_component.shape = cshape

	set_scale(Vector2(2,2) * player_var.range_add_ratio*addi)
	texture.scale *= player_var.range_add_ratio*addi

#dot伤害
func dot():
	if dot_on :
			#print('dot')
			if $damage_area.has_overlapping_bodies():

				_on_hit()
				for b in $damage_area.get_overlapping_bodies():
					if b.has_method("mob_take_damage"):
						damage(b,attack_info.damage)
					elif b.has_method('player_take_damage'):
						if attack_info.has('buff'):
							for i in attack_info.buff.size():
								SignalBus.player_add_buff.emit(attack_info.buff[i],attack_info.buff_value_factor[i],attack_info.id)
#对body造成伤害
func damage(body,damagei,damage_s = damage_source):

	if attack_info.damage_type == 'danma':

		body.mob_take_damage(player_var.player_make_bullet_damage(damagei*attack_info.magical_addition_efficiency,damage_s))
	else:

		body.mob_take_damage(player_var.player_make_melee_damage(damagei*attack_info.physical_addition_efficiency,damage_s))

	give_debuff(body)
	if body.hp <= 0:
		emit_signal("kill",body.global_position)

#设置攻击的活动与否
func set_active(active:bool):
	if active and attack_info.damage_times == 'dot' and is_inside_tree():
		dot_on = active
		var timer = Timer.new()
		add_child(timer)
		timer.wait_time = 0.25
		timer.timeout.connect(dot)
		timer.start()
	visible = active
	$lock_component.visible = active
	for child in $lock_component.get_children():
		child.visible = active
	set_process(active)
	set_physics_process(active)
	# 使用call_deferred避免在物理查询刷新期间修改monitoring
	call_deferred("set_area_monitoring", active)

# 延迟设置Area2D监控状态
func set_area_monitoring(active: bool):
	$damage_area.monitoring = active
	if has_node('bullet_erase_area'):
		$bullet_erase_area.monitoring = active


#击中时触发器
func _on_hit():
	if attack_info.has('hitting_routine_creation'):
		for hit_gen in attack_info.hitting_routine_creation:
			SignalBus.trigger_routine_by_id.emit(hit_gen,true,global_position,rotation,null)

#敌人进入攻击范围时触发
func _on_damage_area_body_entered(body):
	if attack_info.has('buff'):
		for i in attack_info.buff.size():
			SignalBus.player_add_buff.emit(attack_info.buff[i],attack_info.buff_value_factor[i],attack_info.id)
		return
	if body.has_method("mob_take_damage"):
		_on_hit()

		damage(body,attack_info.damage)
		penetration += 1
		if penetration > attack_info.penetration:
			destroy('pene')

#摧毁本攻击
func destroy(message:String=''):
	if recycling:
		return
	recycling = true
	if attack_info.has('destroying_routine_creation'):
		for destroy_gen in attack_info.destroying_routine_creation:
			SignalBus.trigger_routine_by_id.emit(destroy_gen,true,global_position,rotation,null)
	get_parent().call_deferred('remove_child',$".")
	await get_tree().physics_frame
	position = Vector2.ZERO
	over.emit($".")


#对body施加debuff
func give_debuff(body):
	if attack_info.has('debuff'):
		if body.has_method('set_debuff'):
			for i in attack_info.debuff.size():
				body.set_debuff(attack_info.debuff[i],attack_info.debuff_intensity[i],attack_info.debuff_duration[i],$".")

#消弹
func _on_bullet_erase_area_body_entered(body):
	body.destroy.emit(body)
	if attack_info.has('eraseing_item_creation'):
		for item in attack_info.eraseing_item_creation:
			drop_item(item,attack_info.eraseing_item_creation_value,body.global_position)

#击杀时触发器
func on_kill(target_position):

	if attack_info.has('defeating_item_creation'):
		for item in attack_info.defeating_item_creation:
			drop_item(item,attack_info.defeating_item_creation_value,target_position)

#掉落
func drop_item(item,value,dposition):
	SignalBus.drop.emit('drops_'+item,dposition,value)


#当本攻击是boost类型且接受到激活信号时触发
func boost_active(cp_info,is_active:bool):
	if cp_info is String:
		cp_info = table.Couple[cp_info]
	if attack_info.has('effective_condition') and attack_info.effective_condition != cp_info.id:
		return
	#TODO:改用信号系统
	for node in get_parent().get_children():
		if node.has_method('recive_boost'):
			node.recive_boost(attack_info,is_active)

#当本攻击接受到boost攻击发出的boost信号时触发
func recive_boost(atk_info,is_active):

	if atk_info.routine_group != attack_info.routine_group:
		return

	for key in atk_info:
		if key == 'id' or key == 'type' or key =='routine_group' or key =='effective_condition':
			continue
		if atk_info[key] is bool:
			continue
		if not is_active:
			match typeof(atk_info[key]):
				TYPE_ARRAY:
					for element in atk_info[key]:
						attack_info[key].erase(element)
				_:
					attack_info[key] -= atk_info[key]
			continue
		if not attack_info.has(key):
			attack_info[key] = atk_info[key]
		else:
			attack_info[key] += atk_info[key]
#根据group升级招式，level1没有属性提升且算法会数组越界所以特判
func upgrade_attack(group):
	if not attack_info.has("upgrade_group"):
		return
	if attack_info.upgrade_group != group:
		return
	if node_active:
		return
	level += 1
	if level == 1:
		return
	upgrade_to_level(group,level)


func upgrade_to_level(group,level:int):
	var oriinfo = table.Attack[attack_info.id]
	self.level = level
	if table.Upgrade[group].has('damage_addition'):
		attack_info.damage = oriinfo.damage * (1+ table.Upgrade[group].damage_addition[level-1])

	if table.Upgrade[group].has('bullet_speed_addition'):
		for i in attack_info.moving_parameter.size():
			if i == 1 and attack_info.moving_rule != 'polar':
				continue
			attack_info.moving_parameter[i] = oriinfo.moving_parameter[i] * (1+table.Upgrade[group].bullet_speed_addition[level-1])
	if table.Upgrade[group].has('duration_addition'):
		attack_info.duration =oriinfo.duration * (1+ table.Upgrade[group].duration_addition[level-1])
	if table.Upgrade[group].has('range_addition'):
		for i in attack_info.size.size():
			attack_info.size[i] =oriinfo.size[i] * (1+ table.Upgrade[group].range_addition[level-1])
#离开屏幕时触发，销毁攻击
func _on_visible_on_screen_notifier_2d_screen_exited():
	$exit_screen_timer.start()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	$exit_screen_timer.stop()


func _on_exit_screen_timer_timeout() -> void:
	destroy('outofscreen')

func set_bossing(is_boss):
	if attack_info.damage_belong.contains('sc'):
		return
	if is_boss:
		modulate.a = 0.15
func _exit_tree() -> void:
	position = Vector2.ZERO
	rotation = 0
