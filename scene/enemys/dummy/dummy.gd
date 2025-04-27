extends enemy_base
var sumdamage = 0.0
var dpstick = 0.2
var damage_array = []
func _ready():

	$dps.wait_time = dpstick
	$buff.brittle_modify = 1
	super._ready()
	drops_path = "drops_plate"

func _physics_process(_delta):
	hp = mob_info.health
	pass

func mob_take_damage(damage):
	if invincible:
		return
	#damage_num_display(damage)
	#hp -= damage
	#if hp <= 0:
		#died()
	#progress_bar.value = hp/mob_info.health * 100
	#sumdamage += damage
	#$dps_reset.start()


func died(disppear = false):
	drop()

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
