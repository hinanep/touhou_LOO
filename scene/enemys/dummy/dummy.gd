extends enemy_base
var sumdamage = 0.0
var dpstick = 0.2
var damage_array = []
func _ready():

	$dps.wait_time = dpstick

	super._ready()


func _physics_process(_delta):
	hp = mob_info.health
	pass
#弹幕攻击方法，待实例实现
func bullet_attack():
	pass
func take_damage(damage):
	if invincible:
		return
	damage_num_display(damage)
	hp -= damage
	progress_bar.value = hp/mob_info.health * 100
	sumdamage += damage
	$dps_reset.start()
#体术攻击方法，可重新实现
#func melee_attack(playernode):
#	playernode.take_damage(player_var.enemy_make_damage(basic_melee_damage))


var count = 0
func _on_dps_timeout():


	damage_array.push_front(sumdamage)
	sumdamage = 0
	damage_array.resize(25)
	var result = damage_array.reduce(func(a,num):
		if num == null:
			return a+0
		return a + num;
		)

	$dps2.text = String.num(result/5,2)
	pass # Replace with function body.


func _on_dps_reset_timeout():
	sumdamage = 0

	pass # Replace with function body.
func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	#navi.avoidance_enabled = true
	pass # Replace with function body.
