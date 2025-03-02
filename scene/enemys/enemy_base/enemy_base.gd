class_name enemy_base extends CharacterBody2D
@onready var player_node = get_tree().get_first_node_in_group("player")
var curse = player_var.curse
#var modi = player_var.time_secs /1800.0
var mob_id :int
var modi = 0
var max_hp = curse * (1+modi)
var hp = max_hp
var speed = 40
var basic_melee_damage = curse
var basic_bullet_damage = curse
var drops_path = "drops_p"
var target
var invincible = false
signal die(id)
var mob_info = {
	"id": "enm_mempeace",
	"type": "zako",
	"movement": "default",
	"danma": "",
	"barrage_parameter": [],
	"shoot_interval": 0.0,
	"physical_damage": 5.0,
	"magical_damage": 0.0,
	"health": 100.0,
	"speed": 50.0
  }
var debuff = {
	"speed":1.0,
	"target_rediretion":player_node
}
@onready var progress_bar = $ProgressBar

@onready var melee_damage_area = $melee_damage_area
@onready var melee_attack_cd = $melee_damage_area/melee_attack_cd
var damageNum = preload("res://scene/enemys/enemy_base/damageNum.tscn")

@onready var bullet_damage_area = $bullet_damage_area
@onready var bullet_attack_cd = $bullet_damage_area/bullet_attack_cd
@onready var navi = $NavigationAgent2D
func _ready():
	set_modulate(modulate-Color(0, 1, 1, 0)*modi*4)
	set_z_index(1)
	set_z_as_relative(false)
	name = mob_info.id
	speed = mob_info.speed
	navi.max_speed = mob_info.speed
	max_hp = mob_info.health
	hp = max_hp
	basic_melee_damage = mob_info.physical_damage
	basic_bullet_damage = mob_info.magical_damage
	$ProgressBar._set_size(Vector2(144,20))
	collision_layer = 2
	collision_mask = 1
	navi.target_position = player_node.global_position
	melee_battle_ready()
	bullet_battle_ready(true)
	debuff["target_rediretion"] = player_node
	#await get_tree().create_timer(0.5).timeout
	#navi.get_next_path_position()


func on_compute_safevelocity(safevelocity):
	velocity = safevelocity

	#move_and_collide(velocity*0.016)

func _physics_process(_delta):
	move_to_target()

#移动方式：走向玩家
func move_to_target():

	if navi.avoidance_enabled:
		if NavigationServer2D.map_get_iteration_id(navi.get_navigation_map()) == 0:
			return

		navi.get_next_path_position()
		navi.set_velocity(global_position.direction_to(player_node.global_position) * speed)

	else:

		velocity =  global_position.direction_to(player_node.global_position) * speed

	move_and_slide()
func creep():
	pass


func damage_num_display(num):
	var d = damageNum.instantiate()
	d.get_child(1).text = String.num_int64(num)
	#d.global_position = global_position
	d.position = Vector2(2*randf()-1,randf())*5

	#$".".call_deferred("add_child",d)
	$".".add_child(d)


#受伤
func take_damage(damage):
	if invincible:
		return
	damage_num_display(damage)
	hp -= damage
	progress_bar.value = hp/max_hp * 100
	if hp <= 0:
		died()
		#call_deferred("died")


#似了
func died():
	drop()
	queue_free()
	emit_signal('die',mob_id)

func drop():
	var drops = PresetManager.getpre(drops_path).instantiate()
	get_parent().call_deferred("add_child",drops)


	drops.global_position = global_position
	pass







#体术攻击准备就绪，体术攻击敌人ready中调用
func melee_battle_ready(disable = false):
	if disable:
		$melee_damage_area.queue_free()
		return
	melee_damage_area.monitoring = true

	melee_damage_area.body_entered.connect(melee_damage_area_body_entered)
	melee_attack_cd.timeout.connect(melee_attack_cd_timeout)
	melee_damage_area.body_exited.connect(_on_melee_damage_area_body_exited)

func melee_damage_area_body_entered(_body):
	if not _body is player:
		return

	melee_attack(_body)
	melee_attack_cd.start()


func _on_melee_damage_area_body_exited(body):
	if not body is player:
		return

	melee_attack_cd.stop()


func melee_attack_cd_timeout():
	melee_attack(player_node)


#体术攻击方法，可覆盖
func melee_attack(playernode):
	player_var.player_take_melee_damage(playernode,player_var.enemy_make_damage(basic_melee_damage))


#弹幕攻击准备就绪，弹幕攻击敌人ready中调用
func bullet_battle_ready(disable = false):
	if disable:
		$bullet_damage_area.queue_free()
		return
	bullet_damage_area.monitoring = true
	bullet_damage_area.body_entered.connect(bullet_damage_area_body_entered)
	bullet_damage_area.body_exited.connect(_on_bullet_damage_area_body_exited)
	bullet_attack_cd.timeout.connect(bullet_attack_cd_timeout)


func bullet_damage_area_body_entered(_body):
	if not _body is player:
		return
	bullet_attack()
	bullet_attack_cd.start()


func _on_bullet_damage_area_body_exited(body):
	if not body is player:
		return

	bullet_attack_cd.stop()


#弹幕攻击方法，待实例实现
func bullet_attack():
	pass


func bullet_attack_cd_timeout():
	bullet_attack()


#到玩家方向单位向量
func get_diretion_to_target():
	if debuff["target_rediretion"]!=null:
		return(debuff["target_rediretion"].global_position - global_position).normalized()
	else:
		return(player_node.global_position - global_position).normalized()

#到玩家距离
func get_distance_to_player():
	if player_node:
		return global_position.distance_to(player_node.global_position)
	return Vector2.ZERO


func get_distance_squared_to_player():
	if player_node:
		return global_position.distance_squared_to(player_node.global_position)
	return Vector2.ZERO


func setbuff(multi):
	max_hp *= multi
	hp *= multi
	basic_bullet_damage *= multi
	basic_melee_damage *= multi


func set_debuff(param_name,multi=1,time=1):
	return
	$debuff_time.wait_time = time
	$debuff_time.start()
	await get_tree().create_timer(time).timeout
	if param_name == "speed":
		debuff["speed"] = multi
	if param_name == "target_rediretion":
		debuff["target_rediretion"] = multi


func _on_debuff_time_timeout():
	debuff["speed"] = 1.0
	debuff["target_rediretion"] = player_node
	pass # Replace with function body.


func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	navi.avoidance_enabled = true
	pass # Replace with function body.


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	navi.avoidance_enabled = false
	pass # Replace with function body.
