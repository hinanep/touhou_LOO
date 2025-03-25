extends Node2D
class_name attack

@export var level =0
#击杀目标发出的信号
signal kill(global_position)


@export var damage_source :String
@export var attack_info = {
	  }


#已伤害目标，用于防止非dot多次伤害？暂时没必要
#var damaged_bodies = []

#已穿透目标数量
var penetration = 0
#节点活动性
var node_active = true
#招式可能传入的索敌与方向
var lock_routine
var diretion_routine = Vector2(0,0)
#dot开启状态
var dot_on = false
#组件
var lock_compo : LockComponent
var move_compo : MoveComponent

#初始化
func _ready():

	#if attack_info.has('upgrade_group'):
		#add_to_group(attack_info.upgrade_group)
	#if attack_info.has('effective_condition'):
		#add_to_group(attack_info.effective_condition)
	#add_to_group(attack_info.id)
	name = attack_info.id
	set_active(node_active)
	if attack_info.type == 'base':
		SignalBus.atk_boost.connect(recive_boost)
	elif attack_info.type == 'boost':
		SignalBus.cp_active.connect(boost_active.bind(true))
		SignalBus.cp_del.connect(boost_active.bind(false))
		return


	if attack_info.has('duration_dependence'):
		$duration_timer.wait_time = player_var.dep.operate_dep(attack_info.duration_dependence,attack_info.duration)
	else:
		$duration_timer.wait_time = attack_info.duration
	kill.connect(on_kill)
	$bullet_erase_area.set_monitoring(attack_info.bullet_eraseing)
	$damage_area.connect("body_entered",_on_damage_area_body_entered)
	$duration_timer.connect("timeout",destroy.bind('timeout'))
	if attack_info.has('reflection'):
		if attack_info.reflection.has('enemy'):
			$".".collision_mask += 1
		if attack_info.reflection.has('wall'):
			$".".collision_mask += 2




	set_shape(attack_info.shape)


	if node_active:
		$duration_timer.start()
		if attack_info.reference_system == 'world':
			top_level = true
		else:
			global_position = position
	if attack_info.has('locking_type'):
		lock_compo = LockComponent.new($".",attack_info.locking_type,lock_routine)
	else:
		lock_compo = LockComponent.new($".",null,lock_routine)

	move_compo = MoveComponent.new($".",attack_info,lock_compo,diretion_routine)




#运动组件更新
func _physics_process(delta):
	move_compo.update(delta)


#初始化攻击形状
func set_shape(cshape):
	var addi = 1
	if attack_info.has('size_dependence'):
		addi = player_var.dep.operate_dep(attack_info.size_dependence,addi)
	var texture = $texture
	match cshape:
		'circle':
			cshape = CircleShape2D.new()

			cshape.radius = attack_info.size[0]
			texture.scale *= sqrt( attack_info.size[0]/20)
			$VisibleOnScreenNotifier2D.scale = Vector2(1,1)* attack_info.size[0]
			$damage_area/CollisionShape2D.position = Vector2(0,0)
			$bullet_erase_area/CollisionShape2D.position = Vector2(0,0)
			$CollisionShape2D.position = Vector2(0,0)
		'rectangle_center':

			cshape = RectangleShape2D.new()
			cshape.size = Vector2(attack_info.size[0],attack_info.size[1])
			texture.scale *= Vector2(sqrt(attack_info.size[0]/20),sqrt(attack_info.size[1]/20))
			$VisibleOnScreenNotifier2D.rect = Rect2(-cshape.size/2,cshape.size)
		'rectangle_edge':
			cshape = RectangleShape2D.new()
			cshape.size = Vector2(attack_info.size[0],attack_info.size[1])
			$VisibleOnScreenNotifier2D.rect = Rect2(-Vector2(attack_info.size[0]/2,attack_info.size[1]),cshape.size)
			#矩形中心点
			$damage_area/CollisionShape2D.position = Vector2(0,-attack_info.size[1]/2)
			$bullet_erase_area/CollisionShape2D.position = Vector2(0,-attack_info.size[1]/2)
			$CollisionShape2D.position = Vector2(0,-attack_info.size[1]/2)

			texture.scale *= Vector2(sqrt(attack_info.size[0]/20),sqrt(attack_info.size[1]/20))
	$damage_area/CollisionShape2D.shape = cshape
	$bullet_erase_area/CollisionShape2D.shape = cshape
	$CollisionShape2D.shape = cshape

	set_scale(Vector2(1,1) * player_var.range_add_ratio*addi)
	texture.scale *= sqrt(player_var.range_add_ratio*addi)
#dot伤害
func dot():
	if dot_on :
			if $damage_area.has_overlapping_bodies():
				_on_hit()
				for b in $damage_area.get_overlapping_bodies():
					if b.has_method("take_damage"):
						damage(b,attack_info.damage)

#对body造成伤害
func damage(body,damagei,damage_s = damage_source):

	if attack_info.damage_type == 'danma':
		body.take_damage(player_var.player_make_bullet_damage(damagei*attack_info.magical_addition_efficiency,damage_s))
	else:
		body.take_damage(player_var.player_make_melee_damage(damagei*attack_info.physical_addition_efficiency,damage_s))

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
	$texture.visible = active
	set_process(active)
	set_physics_process(active)
	$damage_area.monitoring = active
	$bullet_erase_area.monitoring = active


#击中时触发器
func _on_hit():
	if attack_info.has('hitting_routine_creation'):
		for hit_gen in attack_info.hitting_routine_creation:
			SignalBus.trigger_routine_by_id.emit(hit_gen,true,global_position,rotation,null)

#敌人进入攻击范围时触发
func _on_damage_area_body_entered(body):

	if body.has_method("take_damage"):
		_on_hit()

		damage(body,attack_info.damage)
		penetration += 1
		if penetration > attack_info.penetration:
			call_deferred("destroy", 'pene')

#摧毁本攻击
func destroy(message:String):

	if attack_info.has('destroying_routine_creation'):
		for destroy_gen in attack_info.destroying_routine_creation:
			SignalBus.trigger_routine_by_id.emit(destroy_gen,true,global_position,rotation,null)

	queue_free()

#激活cp效果 TODO：boost似乎还没有实现
func cp_active():
	if attack_info.type == 'boost':
		#todo
		get_parent().get_child(0).attack_info += attack_info

#对body施加debuff
func give_debuff(body):
	if attack_info.has('debuff'):
		if body.has_method('set_debuff'):
			for i in attack_info.debuff.size():
				body.set_debuff(attack_info.debuff[i],attack_info.debuff_intensity[i],attack_info.debuff_duration[i],$".")

#消弹
func _on_bullet_erase_area_body_entered(body):
	body.queue_free()
	if attack_info.has('eraseing_item_creation'):
		drop_item(attack_info.eraseing_item_creation,attack_info.eraseing_item_creation_value,body.global_position)

#击杀时触发器
func on_kill(target_position):

	if attack_info.has('defeating_item_creation'):
		drop_item(attack_info.defeating_item_creation,attack_info.defeating_item_creation_value,global_position)

#掉落
func drop_item(item,value,dposition):

	var drop = PresetManager.getpre('drops_'+item).instantiate()
	drop.global_position = dposition
	drop.value = value
	G.get_game_root().add_child(drop)

#当本攻击是boost类型且接受到激活信号时触发
func boost_active(cp_info,is_active:bool):
	if cp_info is String:
		cp_info = table.Couple[cp_info].duplicate()
	if attack_info.has('effective_condition') and attack_info.effective_condition != cp_info.id:
		return
	for node in get_parent().get_children():
		node.recive_boost(attack_info,is_active)

#当本攻击接受到boost攻击发出的boost信号时触发
func recive_boost(atk_info,is_active):
	#if atk_info is String:
		#atk_info = table.Couple[atk_info]
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
			print(key)
			attack_info[key] = atk_info[key]
		else:
			attack_info[key] += atk_info[key]

#离开屏幕时触发，销毁攻击 TODO：或许可以计时销毁？
func _on_visible_on_screen_notifier_2d_screen_exited():
	$exit_screen_timer.start()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	$exit_screen_timer.stop()


func _on_exit_screen_timer_timeout() -> void:
	call_deferred("destroy", 'cannot vis')
