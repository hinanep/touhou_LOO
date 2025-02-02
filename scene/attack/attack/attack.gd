extends Node2D
class_name attack

@export var level =0
#击杀目标发出的信号
signal kill(global_position)

@export var attack_modifier = {
	"on_hit":[],
	"on_flying":[],
	"on_emit":[],
	"on_destroy":[]
}
@export var damage_source :String
@export var attack_info = {
	  }
#已伤害目标，用于防止非dot多次伤害？暂时没必要
#var damaged_bodies = []

#已穿透目标
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


func _ready():

	if attack_info.upgrade_group != 'none':
		add_to_group(attack_info.upgrade_group)
	if attack_info.effective_condition != 'none':
		add_to_group(attack_info.effective_condition)
	add_to_group(attack_info.attack_name)

	rotation_degrees = attack_info.ri
	$duration_timer.wait_time = attack_info.duration
	kill.connect(on_kill)
	$bullet_erase_area.set_monitoring(attack_info.bullet_eraseing)
	$damage_area.connect("body_entered",_on_damage_area_body_entered)
	$duration_timer.connect("timeout",destroy.bind('timeout'))
	if attack_info.reflection.has('enemy'):
		$".".collision_mask += 1
	if attack_info.reflection.has('enemy'):
		$".".collision_mask += 2
	damage_source = get_parent().damage_source

	set_shape(attack_info.shape)
	set_scale(Vector2(1,1) * player_var.range_add_ratio/2)

	if node_active:
		$duration_timer.start()
		if attack_info.reference_system == 'world':
			top_level = true
		else:
			global_position = position

	lock_compo = LockComponent.new($".",attack_info.locking_type,lock_routine)
	move_compo = MoveComponent.new($".",attack_info,lock_compo,diretion_routine)




	set_active(node_active)

func _physics_process(delta):
	move_compo.update(delta)


func set_shape(cshape):

	match cshape:
		'circle':
			cshape = CircleShape2D.new()

			cshape.radius = attack_info.size[0]
			$VisibleOnScreenNotifier2D.scale = Vector2(1,1)* attack_info.size[0]
			$damage_area/CollisionShape2D.position = Vector2(0,0)
			$bullet_erase_area/CollisionShape2D.position = Vector2(0,0)
		'rectangle_center':

			cshape = RectangleShape2D.new()
			cshape.size = Vector2(attack_info.size[0],attack_info.size[1])
			$VisibleOnScreenNotifier2D.rect = Rect2(-cshape.size/2,cshape.size)
		'rectangle_edge':
			cshape = RectangleShape2D.new()
			cshape.size = Vector2(attack_info.size[0],attack_info.size[1])
			$VisibleOnScreenNotifier2D.rect = Rect2(-Vector2(attack_info.size[0]/2,attack_info.size[1]),cshape.size)
			$damage_area/CollisionShape2D.position = Vector2(0,-attack_info.size[1]/2)
			$bullet_erase_area/CollisionShape2D.position = Vector2(0,0-attack_info.size[1]/2)

	$damage_area/CollisionShape2D.shape = cshape
	$bullet_erase_area/CollisionShape2D.shape = cshape
	$CollisionShape2D.shape = cshape

#dot伤害
func dot():
	while(dot_on):
			await get_tree().create_timer(0.25).timeout
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
	visible = active
	set_process(active)
	set_physics_process(active)
	$damage_area.monitoring = active
	$bullet_erase_area.monitoring = active
	dot_on = active
	if active and attack_info.damage_times == 'dot' and is_inside_tree():
		dot()



#func upgrade_attack():
	#level += 1
	#print('upgrade_attack')

#设置等级
func set_upgrade(nlevel:int):
	level = nlevel
	pass

#击中时触发器
func _on_hit():
	for hit_gen in attack_info.hitting_routine_creation:
		get_tree().call_group(hit_gen,'attacks',true,global_position,rotation)



#敌人进入攻击范围
func _on_damage_area_body_entered(body):
	#if body in damaged_bodies:
		#return
	if body.has_method("take_damage"):
		_on_hit()
		#damaged_bodies.append(body)

		damage(body,attack_info.damage)
		penetration += 1
		if penetration > attack_info.penetration:
			destroy('pene')

#摧毁本攻击
func destroy(message:String):
	#print(message)
	for destroy_gen in attack_info.destroying_routine_creation:
		get_tree().call_group(destroy_gen,'attacks',true,global_position,rotation)

	lock_compo.queue_free()
	move_compo.queue_free()
	queue_free()


#激活cp效果
func cp_active():
	if attack_info.type == 'boost':
		#todo
		get_parent().get_child(0).attack_info += attack_info

#施加debuff
func give_debuff(body):
	if attack_info.debuff.is_empty():
		return
	else:
		for i in attack_info.debuff.size():
			body.set_debuff(attack_info.debuff[i])


#消弹
func _on_bullet_erase_area_body_entered(body):
	body.queue_free()
	drop_item(attack_info.eraseing_item_creation,attack_info.eraseing_item_creation_value,body.global_position)

#击杀时触发器
func on_kill(target_position):
	if attack_info.defeating_item_creation:
		drop_item(attack_info.defeating_item_creation,attack_info.defeating_item_creation_value,global_position)

#掉落
func drop_item(item,value,dposition):
	var drop = PresetManager.getpre(item).instantiate()
	drop.global_position = dposition
	drop.value = value
	G.get_game_root().add_child(drop)




func _on_visible_on_screen_notifier_2d_screen_exited():
	destroy('cannot vis')
