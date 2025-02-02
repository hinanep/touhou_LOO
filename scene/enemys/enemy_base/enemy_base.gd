class_name enemy_base extends CharacterBody2D
@onready var player= get_tree().get_first_node_in_group("player")
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
var debuff = {
	"speed":1.0,
	"target_rediretion":player
}
@onready var progress_bar = $ProgressBar

@onready var melee_damage_area = $melee_damage_area
@onready var melee_attack_cd = $melee_damage_area/melee_attack_cd
var damageNum = preload("res://scene/enemys/enemy_base/damageNum.tscn")

@onready var bullet_damage_area = $bullet_damage_area
@onready var bullet_attack_cd = $bullet_damage_area/bullet_attack_cd

func _ready():
	set_modulate(modulate-Color(0, 1, 1, 0)*modi*4)
	set_z_index(1)
	set_z_as_relative(false)
	$ProgressBar._set_size(Vector2(144,20))
	collision_layer = 2
	collision_mask = 1
	debuff["target_rediretion"] = player


func _physics_process(_delta):
	move_to_target()


#移动方式：走向玩家
func move_to_target():

	velocity = get_diretion_to_target() * speed * debuff["speed"]
	#近身减速防止模型重叠的神秘bug（，过近远离
	#if get_distance_squared_to_player() < pow(10,2):
		#velocity *=  (get_distance_squared_to_player() - 100)/10
	move_and_slide()


func damage_num_display(num):
	var d = damageNum.instantiate()
	d.get_child(1).text = String.num_int64(num)
	#d.global_position = global_position
	d.position = Vector2(0,0)
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

	melee_attack(player)
	melee_attack_cd.start()


func _on_melee_damage_area_body_exited(body):
	if not body is player:
		return

	melee_attack_cd.stop()


func melee_attack_cd_timeout():
	melee_attack(player)


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
		return(player.global_position - global_position).normalized()

#到玩家距离
func get_distance_to_player():
	if player:
		return global_position.distance_to(player.global_position)
	return Vector2.ZERO


func get_distance_squared_to_player():
	if player:
		return global_position.distance_squared_to(player.global_position)
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
	debuff["target_rediretion"] = player
	pass # Replace with function body.
