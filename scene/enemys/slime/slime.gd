extends "res://scene/enemys/enemy_base/enemy_base.gd"

func _ready():
	max_hp = 100
	hp = max_hp
	speed = 40
	basic_damage = 10
	pass
func _physics_process(delta):
	move_to_player()



#信号需要在每种敌人中重新连接
func _on_damage_area_body_entered(body):
	damage_area_body_entered(body)
	pass # Replace with function body.

#信号需要在每种敌人中重新连接
func _on_attack_cd_timeout():
	attack_cd_timeout()
	pass # Replace with function body.
