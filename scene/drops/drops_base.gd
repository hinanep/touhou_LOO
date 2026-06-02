class_name drop extends Area2D
@onready var player_node: player = get_tree().get_first_node_in_group("player") as player
@onready var game_manager: Node = get_tree().get_first_node_in_group("GameManager")

var value: int = 1
var experience: int = 1
var score: int = 1
var mana: int = 1
var move: bool = false
var speed_ratio: float = 600
var point_ratio: bool = false
var not_fusioning: bool = true
func _ready() -> void:
	set_physics_process(false)
	var t: Tween = create_tween()
	RunSession.underrecycle_tween.append(t)
	t.tween_interval(0.1)
	t.tween_callback(find_fusion)
func _physics_process(delta: float) -> void:
	if player_node:
		position +=  global_position.direction_to(player_node.global_position) * delta * speed_ratio

func _on_body_entered(_body: Node2D) -> void:
	AudioManager.play_sfx("music_sfx_pickup")
	player_var.player_exp += (experience*value)
	player_var.point += (score*value)
	player_var.mana += (mana*value)
	if point_ratio:
		player_var.point_ratio += 0.01
	queue_free()

func fly_to_player(exp_buff: float = 1.0, mana_buff: float = 1.0, score_buff: float = 1.0, point_ratio_buff: bool = false) -> void:
	$".".collision_mask = 1
	experience *= exp_buff
	mana *= mana_buff
	score *= score_buff
	if point_ratio_buff:
		point_ratio = point_ratio_buff
	set_physics_process(true)

func fusion(v: int, e: int, s: int, m: int) -> void:

	experience = v * e + value * experience

	score = v * s+ value * score
	mana = v * m+ value * mana

	value = 1
	not_fusioning= true
	$AnimatedSprite2D.scale = Vector2(log(experience+1)/3.0+0.2,log(experience+1)/3.0+0.2)

func find_fusion() -> void:
	if not monitoring:
		return
	for area in get_overlapping_areas():
		if not_fusioning and area.has_method('fusion') and area.not_fusioning:
				not_fusioning = false
				area.not_fusioning = false
				var tween: Tween = create_tween()
				RunSession.underrecycle_tween.append(tween)
				tween.tween_property($".",'global_position',area.global_position,0.2)
				await tween.finished
				if area!= null:
					area.fusion(value,experience,score,mana)

					queue_free()
				return
