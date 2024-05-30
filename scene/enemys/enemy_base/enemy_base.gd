class_name enemy_base extends CharacterBody2D
@onready var player= get_tree().get_first_node_in_group("player")
var max_hp = 200
var hp = max_hp
var speed = 40
var basic_melee_damage = 10
var basic_bullet_damage = 10

@onready var progress_bar = $ProgressBar

@onready var melee_damage_area = $melee_damage_area
@onready var melee_attack_cd = $melee_damage_area/melee_attack_cd


@onready var bullet_damage_area = $bullet_damage_area
@onready var bullet_attack_cd = $bullet_damage_area/bullet_attack_cd

func _ready():
	pass
	

func _physics_process(delta):
	move_to_player()
	pass


#移动方式：走向玩家
func move_to_player():
	velocity = get_diretion_to_player() * speed
	
	#近身减速防止模型重叠的神秘bug（，过近远离
	if get_distance_to_player() < 20:
		velocity *=  (get_distance_to_player() - 10)/20
	
	move_and_slide()

#受伤
func take_damage(damage):
	hp -= damage
	progress_bar.value = hp/max_hp * 100
	if hp <= 0:
		died()
#似了
func died():
	print("died")
	queue_free()
	
#弹幕攻击方法，待实例实现
func bullet_attack():
	pass
#体术攻击方法，可覆盖
func melee_attack(playernode):
	player_var.player_take_melee_damage(playernode,player_var.enemy_make_damage(basic_melee_damage))
	
	
#体术攻击准备就绪，体术攻击敌人ready中调用
func melee_battle_ready():
	melee_damage_area.monitoring = true
	melee_damage_area.monitorable = true
	melee_damage_area.body_entered.connect(melee_damage_area_body_entered)
	melee_attack_cd.timeout.connect(melee_attack_cd_timeout)
#弹幕攻击准备就绪，弹幕攻击敌人ready中调用
func bullet_battle_ready():
	bullet_damage_area.monitoring = true
	bullet_damage_area.monitorable = true
	bullet_damage_area.body_entered.connect(bullet_damage_area_body_entered)
	bullet_attack_cd.timeout.connect(bullet_attack_cd_timeout)
	
func melee_damage_area_body_entered(body):
	melee_attack_cd.start()
	
func bullet_damage_area_body_entered(body):	
	bullet_attack_cd.start()
	
func melee_attack_cd_timeout():
	var playerinrange = melee_damage_area.get_overlapping_bodies()
	if playerinrange:
		melee_attack(player)
	else:
		melee_attack_cd.stop()

func bullet_attack_cd_timeout():	
	var playerinrange = bullet_damage_area.get_overlapping_bodies()
	if playerinrange:
		bullet_attack()
	else:
		bullet_attack_cd.stop()

#到玩家方向单位向量
func get_diretion_to_player():
	if player:
		return(player.global_position - global_position).normalized()
	return Vector2.ZERO
#到玩家距离
func get_distance_to_player():
	if player:
		return global_position.distance_to(player.global_position)
	return Vector2.ZERO
