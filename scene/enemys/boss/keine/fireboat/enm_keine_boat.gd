extends enemy_base

var lines_withboat = []
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
	drops_path = 'drops_point'
	await  get_tree().create_timer(3.8).timeout
	player_var.SpawnManager.register_mob($".")

func _physics_process(delta):
	pass


func _on_fireball_rec_body_entered(body:  Node2D) -> void:
	if body.is_in_group('fire'):
		body.destroy.emit(body)
		call_deferred('on_fire')
		pass


func on_fire():

	if fired:
		return
	fired = true
	for line in lines_withboat:
		if line:
			line.on_fire_from($".")
	SignalBus.d4c_create.emit('dcrt_keine_sc2_2',global_position,$".",30)

func _on_outscreen_disppear_timeout() -> void:
	pass
