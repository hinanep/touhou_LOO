extends Node
@export var sasa : PackedScene
var preset_map = {

	"bullet_reimu": preload("res://scene/bullets/reimu_bullet/reimu_bullet.tscn"),
	"bullet_laser":preload("res://scene/bullets/laser_bullet/laser.tscn"),
	"bullet_alice":preload("res://scene/bullets/alice_bullet/alice_bullet.tscn"),
	"bullet_beginning":preload("res://scene/bullets/beginning_bullet/beginning_bullet.tscn"),
	"bullet_flyhead":preload("res://scene/bullets/fly_head_bullet/fly_head.tscn"),
	"bullet_riggle":preload("res://scene/bullets/riggle_bullet/riggle_bullet.tscn"),
	"bullet_rumia":preload("res://scene/bullets/rumia_bullet/rumia_bullet.tscn"),
	"bullet_rumia_blackhole":preload("res://scene/bullets/rumia_bullet/black_hole.tscn"),
	"bullet_sanae_small":preload("res://scene/bullets/sanae_bullet/small/sanae_bullet_small.tscn"),
	"bullet_sanae_mid":preload("res://scene/bullets/sanae_bullet/mid/sanae_bullet_mid.tscn"),
	"bullet_sanae_big":preload("res://scene/bullets/sanae_bullet/big/sanae_bullet_big.tscn"),
	"bullet_tamatsukuri":preload("res://scene/bullets/tamatsukuri_bullet/tamatsukuri_bullet.tscn"),
	"bullet_tamatsukuri_bomb":preload("res://scene/bullets/tamatsukuri_bullet/bomb.tscn"),

	"drops_p":preload("res://scene/drops/exp_1.tscn"),
	"drops_plate":preload("res://scene/drops/plate_1.tscn"),

	"card_fairy":preload("res://scene/cards/beginning_card/beginning_card.tscn"),
	"card_masterspark":preload("res://scene/cards/masterapark/masterspark.tscn"),

	'skill':preload("res://scene/skill/skill_class/skill.tscn"),
	'routine':preload("res://scene/routine/routine/routine.tscn"),
	'attack':preload("res://scene/attack/attack/attack.tscn"),
	#"skill_reimu":preload("res://scene/skill/reimu/reimu_weapon.tscn"),
	#"skill_alice":preload("res://scene/skill/alice_weapon/alice_weapon.tscn"),
	#"skill_beginning_range":preload("res://scene/skill/beginning_weapon/beginning_ranged_attack/beginning_ranged_attack.tscn"),
	#"skill_beginning_melee":preload("res://scene/skill/weapon_base/melee_base/melee_weapon_base.tscn"),
	#"skill_sekibanki":preload("res://scene/skill/sekibanki/sekibanki_weapon.tscn"),
	#"skill_riggle":preload("res://scene/skill/riggle/riggle_weapon.tscn"),
	#"skill_rumia":preload("res://scene/skill/rumia/rumia_weapon.tscn"),
	#"skill_sanae":preload("res://scene/skill/sanae/sanae_weapon.tscn"),
	#"skill_tamatsukuri":preload("res://scene/skill/tamatsukuri/tamatsukuri.tscn"),

	"passive_pachuli":preload("res://scene/passive/pachuli/pachuli.tscn"),

	"particle_explosion":preload("res://scene/particle/explosion.tscn"),

	"modifier_rumia":preload("res://scene/modifier/on_hit/rumia/rumia_on_hit.tscn"),
	"modidier_reima":preload("res://scene/modifier/on_hit/on_hit.tscn"),
	"modidier_reitama":preload("res://scene/modifier/on_destroy/on_destroy.tscn"),

	"enemy_boss_aq":preload("res://scene/enemys/aq_boss/aq_boss.tscn"),
	"aq_punch":preload("res://scene/enemys/aq_boss/bullet/random_bullet.tscn"),
	"enemy_zako_bat_blue":preload("res://scene/enemys/bat_blue/bat_blue.tscn"),
	"enemy_zako_bat_purple":preload("res://scene/enemys/bat_purple/bat_purple.tscn"),
	"enemy_zako_bug_orange":preload("res://scene/enemys/bug_orange/bug_orange.tscn"),
	"enemy_zako_bug_pink":preload("res://scene/enemys/bug_pink/bug_pink.tscn"),
	"enemy_zako_ghost":preload("res://scene/enemys/ghost/ghost.tscn"),
	"enemy_zako_kedama":preload("res://scene/enemys/kedama/kedama.tscn"),
	"enemy_zako_slime_blue":preload("res://scene/enemys/slime_blue/slime_blue.tscn"),
	"enemy_zako_slime_green":preload("res://scene/enemys/slime_green/slime_green.tscn"),
	"enemy_elite_slime":preload("res://scene/enemys/elite_slime/elite_slime.tscn"),

	"enemy_spawner":preload("res://scene/enemys/spawner.tscn"),

	"music_sfx_cp":preload("res://asset/music/sfx/cp.wav"),
	"music_sfx_error":preload("res://asset/music/sfx/error.mp3"),
	"music_sfx_explosion":preload("res://asset/music/sfx/explosion.wav"),
	"music_sfx_hurt":preload("res://asset/music/sfx/hurt.mp3"),
	"music_sfx_laser":preload("res://asset/music/sfx/laser.wav"),
	"music_sfx_masterspark":preload("res://asset/music/sfx/masterspark.mp3"),
	"music_sfx_spellcard":preload("res://asset/music/sfx/spellcard.mp3"),
	"music_sfx_shoot":preload("res://asset/music/sfx/tap.wav"),
	"music_sfx_pickup":preload("res://asset/music/sfx/pickup.wav"),
	"music_sfx_levelup":preload("res://asset/music/sfx/levelup.wav"),

	"music_bgm_saga":preload("res://asset/music/Japanese Saga.mp3"),
	"music_bgm_oldworld":preload("res://asset/music/令人怀念的东方之血 ~ Old World.mp3"),
	"music_bgm_ff":preload("res://asset/music/祖堅正慶 - 神なき世界.mp3"),

	"ui_select_button":preload("res://scene/ui/LevelUp/select_button.tscn"),
	"ui_card_texture":preload("res://scene/ui/Hud/card_texture.tscn"),
	"ui_cp_and_skill_texture":preload("res://scene/ui/Hud/cp_and_skill_texture.tscn"),
	"ui_test_skillbutton":preload("res://scene/ui/TestScene/buttons/test_skillbutton.tscn"),

	"image_card_fairy":preload("res://asset/pic/crystal/大妖精.png"),
	"image_ski_basemagic":preload("res://asset/pic/crystal/大妖精.png"),
	"image_ski_basephysics":preload("res://asset/pic/crystal/大妖精.png"),
	"image_card_marisa":preload("res://asset/pic/crystal/魔理沙.png"),
	"image_ski_reimu":preload("res://asset/pic/crystal/灵梦.png"),
	"image_ski_alice":preload("res://asset/pic/crystal/爱丽丝.png"),
	"image_ski_sekibanki":preload("res://asset/pic/crystal/赤蛮奇.png"),
	"image_ski_wriggle":preload("res://asset/pic/crystal/莉格露.png"),
	"image_ski_rumia":preload("res://asset/pic/crystal/露米娅.png"),
	"image_ski_sanae":preload("res://asset/pic/crystal/早苗.png"),
	"image_ski_sakuya":preload("res://asset/pic/crystal/早苗.png"),
	"image_ski_misumaru":preload("res://asset/pic/crystal/魅须丸.png"),
	"image_passive_pachuli":preload("res://asset/pic/crystal/帕秋莉.png"),
	"image_cp_reima":preload("res://asset/pic/crystal/灵梦×魔理沙.png"),
	"image_cp_reitama":preload("res://asset/pic/crystal/灵丸.png"),
	'img_atk_basemagic_base':preload("res://asset/pic/bullet/子弹.png"),
	'img_atk_reimu_base':preload("res://asset/pic/bullet/符札弹.png"),
	'img_atk_sanae_type1_base':preload("res://asset/pic/bullet/小风.png"),
	'img_atk_sanae_type2_base':preload("res://asset/pic/bullet/中风1.png"),
	'img_atk_sanae_type3_base':preload("res://asset/pic/bullet/大风.png"),
	'img_atk_rumia_base':preload("res://asset/pic/bullet/子弹.png"),
	'img_atk_wriggle_base':preload("res://asset/pic/bullet/firefly.png"),
	'img_atk_sekibanki_base':preload("res://asset/pic/bullet/头.png"),
	'img_atk_misumaru_base':preload("res://asset/pic/bullet/yinyangorb.png"),


}


func _ready():
	#for name in path_map:
		#preset_map[name] =
	pass
func getpre(prename : String):
	return preset_map[prename]
