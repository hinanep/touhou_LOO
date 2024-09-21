class_name melee_weapon_base extends Node2D


@onready var melee_timer = $meleeTimer
@onready var attack_range = $attack_range

const basic_colddown = 1
const kick_range = 50
const kick_basic_damage = 10

var kick_ready = true
var nearest_enemy
func _ready():
	set_range_and_colddown()
	
func _physics_process(delta):
	

	nearest_enemy = get_nearest_enemy_inarea()
	if nearest_enemy:
		
		look_at(nearest_enemy.global_position)
		auto_attack()

func set_range_and_colddown():
	melee_timer.wait_time = basic_colddown * (1 - player_var.colddown_reduce)
	attack_range.set_scale(Vector2(player_var.range_add_ratio,player_var.range_add_ratio))
	
func _on_kick_timer_timeout():
	kick_ready = true

func enemy_near(a,b):
	return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)

func get_nearest_enemy_inarea():
	var enemy_in_range = attack_range.get_overlapping_bodies() #area范围内的物体
	if !enemy_in_range.is_empty():	
		return enemy_in_range.reduce(func(min,val):return val if enemy_near(val,min) else min)
	return null
	

func auto_attack():
	if kick_ready:
		kick()
		kick_ready = false
		melee_timer.start()

func kick():
	var enemy_in_kick_range = attack_range.get_overlapping_bodies()
	

	for enemy in enemy_in_kick_range:
		if enemy.has_method("take_damage"):
			enemy.take_damage(player_var.player_make_melee_damage(kick_basic_damage))

