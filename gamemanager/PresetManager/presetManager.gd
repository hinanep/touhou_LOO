extends Node

var preset_map = {



	"drops_p":"res://scene/drops/exp_1.tscn",
	"drops_plate":"res://scene/drops/plate/plate_1.tscn",
	'drops_mana':"res://scene/drops/mana.tscn",

	'skill':"res://scene/skill/skill_class/skill.tscn",
	'routine':"res://scene/routine/routine/routine.tscn",
	'attack':"res://scene/attack/attack/attack.tscn",
	'notfoundatk':"res://scene/attack/attack_ins/notfindattack.tscn",
	'summon':"res://scene/summon/summon.tscn",
	'card':"res://scene/cards/card/card.tscn",
	'passive':"res://scene/passive/base_passive/Passive.tscn",
	'cp':"res://scene/cp/cp.tscn",

	'boss_routine':"res://scene/enemys/boss/boss_routine.tscn",

	"particle_explosion":"res://scene/particle/explosion.tscn",
	'sum_alice':"res://scene/summon/summon_ins/sum_alice.tscn",


	'enemy':"res://scene/enemys/enemy_base/enemy_base.tscn",
	"enemy_spawner":"res://scene/enemys/spawner.tscn",
	'enm_memhappy':"res://scene/enemys/enm_memhappy.tscn",
	'enm_memsad':"res://scene/enemys/enm_memsad.tscn",
	'enm_keine_ns1_1':"res://scene/enemys/enm_keine_ns1_1.tscn",
	'enm_keine_ns1_2':"res://scene/enemys/enm_keine_ns1_2.tscn",
	'enm_keine_sc1':"res://scene/enemys/enm_keine_sc1.tscn",
	'keine':"res://scene/enemys/aq_boss/aq_boss.tscn",
	'd4c':"res://scene/DanmaC/DC.tscn",
	'danma':"res://scene/DanmaC/danma/danma.tscn",

	"music_sfx_cp":"res://asset/music/sfx/cp.wav",
	"music_sfx_error":"res://asset/music/sfx/error.mp3",
	"music_sfx_explosion":"res://asset/music/sfx/explosion.wav",
	"music_sfx_hurt":"res://asset/music/sfx/hurt.mp3",
	"music_sfx_laser":"res://asset/music/sfx/laser.wav",
	"music_sfx_masterspark":"res://asset/music/sfx/masterspark.wav",
	"music_sfx_spellcard":"res://asset/music/sfx/spellcard.mp3",
	"music_sfx_shoot":"res://asset/music/sfx/tap.wav",
	"music_sfx_pickup":"res://asset/music/sfx/pickup.wav",
	"music_sfx_levelup":"res://asset/music/sfx/levelup.wav",
	"music_sfx_clear":"res://asset/music/sfx/clear.wav",
	"music_sfx_die":"res://asset/music/sfx/dead.wav",
	'music_sfx_break':"res://asset/music/sfx/break.wav",

	"music_bgm_saga":"res://asset/music/Japanese Saga.mp3",
	"music_bgm_oldworld":"res://asset/music/ChillKeine.wav",


	"ui_select_button":"res://ui/LevelUp/select_button.tscn",
	"ui_card_texture":"res://ui/Hud/card_texture.tscn",
	"ui_cp_and_skill_texture":"res://ui/Hud/cp_and_skill_texture.tscn",
	"ui_test_skillbutton":"res://ui/TestScene/buttons/test_skillbutton.tscn",

	'img_skill_icon':"res://asset/pic/ui/skill.png",
	'img_card_icon':"res://asset/pic/ui/card.png",
	'img_passive_icon':"res://asset/pic/ui/passive.png",
	'img_p':"res://asset/pic/p.png",

	'img_rice':"res://asset/pic/bullet/enemy/米弹.png",
	'img_tama':"res://asset/pic/bullet/enemy/中玉.png",
	'img_laser':"res://asset/pic/bullet/enemy/激光.png",
	'img_laserpre':"res://asset/pic/bullet/enemy/激光预警线.png",


	"img_sc_marisa":"res://asset/pic/crystal/符卡/魔理沙.png",
	"img_sc_youmu":"res://asset/pic/crystal/符卡/魂魄妖梦.png",
	"img_sc_daiyousei":"res://asset/pic/crystal/符卡/大妖精.png",

	"img_ski_basemagic":"res://asset/pic/crystal/大妖精.png",
	"img_ski_basephysics":"res://asset/pic/crystal/大妖精.png",
	"img_ski_reimu":"res://asset/pic/crystal/主动技能/博丽灵梦.png",
	"img_ski_alice":"res://asset/pic/crystal/主动技能/爱丽丝.png",
	"img_ski_sekibanki":"res://asset/pic/crystal/主动技能/赤蛮奇.png",
	"img_ski_wriggle":"res://asset/pic/crystal/主动技能/莉格露.png",
	"img_ski_rumia":"res://asset/pic/crystal/主动技能/露米娅.png",
	"img_ski_sanae":"res://asset/pic/crystal/早苗.png",
	"img_ski_sakuya":"res://asset/pic/crystal/主动技能/十六夜咲夜.png",
	"img_ski_misumaru":"res://asset/pic/crystal/主动技能/玉造魅须丸.png",

	"img_psv_patchouli":"res://asset/pic/crystal/被动技能/帕秋莉.png",
	"img_psv_saki":"res://asset/pic/crystal/被动技能/骊驹早鬼.png",
	"img_psv_narumi":"res://asset/pic/crystal/被动技能/矢田寺成美.png",
	"img_psv_junko":"res://asset/pic/crystal/被动技能/纯狐.png",
	"img_psv_kisumi":"res://asset/pic/crystal/被动技能/琪斯美.png",
	"img_psv_momoyo":"res://asset/pic/crystal/被动技能/姬虫百百世.png",

	"img_cp_reimu_marisa":"res://asset/pic/crystal/灵梦×魔理沙.png",
	"img_cp_reimu_sanae":"res://asset/pic/crystal/灵梦×早苗.png",
	"img_cp_reimu_misumaru":"res://asset/pic/crystal/灵梦×魅须丸.png",
	"img_cp_marisa_alice":"res://asset/pic/crystal/魔理沙×爱丽丝.png",
	"img_cp_marisa_patchouli":"res://asset/pic/crystal/魔理沙×帕秋莉.png",
	"img_cp_alice_patchouli":"res://asset/pic/crystal/爱丽丝×帕秋莉.png",
	"img_cp_marisa_alice_patchouli":"res://asset/pic/crystal/三魔女.png",
	"img_cp_marisa_narumi":"res://asset/pic/crystal/魔理沙×成美.png",



	'img_atk_basemagic':"res://asset/pic/bullet/子弹.png",
	'img_atk_reimu':"res://asset/pic/bullet/符札弹.png",
	'img_atk_sanae_type1':"res://asset/pic/bullet/小风.png",
	'img_atk_sanae_type2':"res://asset/pic/bullet/中风1.png",
	'img_atk_sanae_type3':"res://asset/pic/bullet/大风.png",
	'img_atk_rumia':"res://asset/pic/bullet/子弹.png",
	'img_atk_wriggle':"res://asset/pic/bullet/firefly.png",
	'img_atk_sekibanki':"res://asset/pic/bullet/头.png",
	'img_atk_misumaru':"res://asset/pic/bullet/yinyangorb.png",

	'root_menu':"res://ui/game.tscn",
	'start_menu':"res://ui/StartMenu/StartMenu.tscn",
}


func _ready():
	for pname in preset_map:
		ResourceLoader.load_threaded_request(preset_map[pname],'',true)


func _process(delta: float) -> void:
	if(ResourceLoader.load_threaded_get_status(preset_map['img_atk_misumaru']) == 3):
		for pname in preset_map:
			preset_map[pname] = ResourceLoader.load_threaded_get(preset_map[pname])
		process_mode = PROCESS_MODE_DISABLED

func getpre(prename : String):
	if preset_map.has(prename) :
	#	return ResourceLoader.load_threaded_get(preset_map[prename])
		return preset_map[prename]
	if(prename.contains('enm')):
		print('pre  '+prename+'  not found!')
		return preset_map.enemy
	if(prename.contains('img')):
		print('pre  '+prename+'  not found!')
		return preset_map.img_p
	if(prename.contains('sum')):
		print('pre  '+prename+'  not found!')
		return preset_map.summon

	print('pre  '+prename+'  not found!')
	return null
