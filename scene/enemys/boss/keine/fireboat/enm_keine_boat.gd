extends enemy_base

var lines_withboat = []
var fire = false
var fired = false
func _ready():
	mob_info = {
	"id": "enm_boat",
	"type": "zako",
	"movement": "static",

	"physical_damage": 0.0,
	"magical_damage": 0.0,
	"health": 1000.0,
	"speed": 0.0
  }
	$buff.brittle_modify = 0
	super._ready()
func _physics_process(delta):
	d+=delta


	if not global_position.is_equal_approx(last_position):
		player_var.SpawnManager.update_enemy_position_in_grid(self, last_position, global_position)
		# 更新上一帧的位置
		last_position = global_position
	if fire and not fired:
		fired = true
		on_fire()

func _on_fireball_rec_body_entered(body:  Node2D) -> void:
	if body.is_in_group('fire'):
		on_fire()

func on_fire():
	print('我火辣')
	for line in lines_withboat:
		line.on_fire_from($".")
	SignalBus.d4c_create.emit('dcrt_keine_sc2_2',global_position,$".",30)
