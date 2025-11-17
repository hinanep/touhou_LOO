extends Node

var preset_map = {



	"drops_p":"res://scene/drops/exp_1.tscn",
	"drops_plate":"res://scene/drops/plate/plate_1.tscn",
	'drops_mana':"res://scene/drops/mana.tscn",
	'drops_point':"res://scene/drops/point/point.tscn",
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
	'enm_mempeace':"res://scene/enemys/enm_mempeace.tscn",
	'enm_keine_ns1_1':"res://scene/enemys/boss/keine/enm_keine_ns1_1.tscn",
	'enm_keine_ns1_2':"res://scene/enemys/boss/keine/enm_keine_ns1_2.tscn",
	'enm_keine_sc1':"res://scene/enemys/boss/keine/enm_keine_sc1.tscn",
	'keine':"res://scene/enemys/boss/keine/keine.tscn",
	'enm_yuurei':"res://scene/enemys/enm_yuurei.tscn",
	'enm_onibi':"res://scene/enemys/enm_onibi.tscn",
	'enm_book':"res://scene/enemys/enm_book.tscn",
	'enm_eltkedama':"res://scene/enemys/enm_elite_kedama.tscn",
	'enm_kedama':"res://scene/enemys/enm_kedama.tscn",

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
	'music_keine_intro':"res://asset/music/keine/intro.wav",
	'music_keine_loop':"res://asset/music/keine/loop.wav",

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
	"img_ski_sanae":"res://asset/pic/crystal/主动技能/东风谷早苗.png",
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

	'img_enm_memhappy':"res://asset/pic/enemy/greenrock/moving/记忆幻影-alllllllll_000.png",
	'img_enm_mempeace':"res://asset/pic/enemy/bluerock/moving/bm_000.png",
	'img_enm_memsad':"res://asset/pic/enemy/redrock/moving/rm_000.png",

	'img_enm_yuurei':"res://asset/pic/enemy/yuurei/移动/鬼魂-alll_00.png",
	'img_enm_onibi':"res://asset/pic/enemy/onibi/移动/移动_00.png",
	'img_enm_book':"res://asset/pic/enemy/book/移动/移动_00.png",
	'img_enm_eltkedama':"res://asset/pic/enemy/elite_kedama/毛玉-animation_00.png",
	'img_enm_kedama':"res://asset/pic/enemy/kedama/表情1 移动/毛玉-jumping-w_00.png",

	'root_menu':"res://ui/game.tscn",
	'start_menu':"res://ui/StartMenu/StartMenu.tscn",
	'property_text':"res://ui/LevelUp/property_text.tscn",
}

# --- 加载遮罩与进度条（仅在加载阶段存在） ---
var _loading_layer
var _loading_root
var _loading_bar

func _ensure_loading_overlay() -> void:
	if is_instance_valid(_loading_layer):
		return
	_loading_layer = CanvasLayer.new()
	_loading_layer.layer = 128
	_loading_root = Control.new()
	_loading_root.name = "PresetLoadingOverlay"
	_loading_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_loading_root.anchor_right = 1.0
	_loading_root.anchor_bottom = 1.0
	var blocker = ColorRect.new()
	blocker.color = Color(0,0,0,0.6)
	blocker.anchor_right = 1.0
	blocker.anchor_bottom = 1.0
	_loading_root.add_child(blocker)
	_loading_bar = ProgressBar.new()
	_loading_bar.min_value = 0.0
	_loading_bar.max_value = 1.0
	_loading_bar.value = 0.0
	_loading_bar.anchor_left = 0.25
	_loading_bar.anchor_right = 0.75
	_loading_bar.anchor_top = 0.47
	_loading_bar.anchor_bottom = 0.53
	_loading_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_loading_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_loading_root.add_child(_loading_bar)
	_loading_layer.add_child(_loading_root)
	get_tree().root.add_child(_loading_layer)

func _set_loading_progress(p: float) -> void:
	if is_instance_valid(_loading_bar):
		_loading_bar.value = clamp(p, 0.0, 1.0)

func _remove_loading_overlay() -> void:
	if is_instance_valid(_loading_layer):
		_loading_layer.queue_free()
	_loading_layer = null
	_loading_root = null
	_loading_bar = null

func _ready():
	# 启动多线程加载，并显示遮罩与进度条阻塞交互
	_ensure_loading_overlay()
	var paths := []
	for pname in preset_map:
		var p = preset_map[pname]
		ResourceLoader.load_threaded_request(p,'',true)
		paths.append(p)
	# 轮询真实进度
	while true:
		var total := paths.size()
		if total == 0:
			break
		var sum := 0.0
		var done := 0
		for p in paths:
			var prog := []
			var st = ResourceLoader.load_threaded_get_status(p, prog)
			var v := 0.0
			if prog.size() > 0:
				v = float(prog[0])
			if st == ResourceLoader.THREAD_LOAD_LOADED or st == ResourceLoader.THREAD_LOAD_FAILED:
				v = 1.0
				done += 1
			sum += v
		_set_loading_progress(sum / float(total))
		if done >= total:
			break
		await get_tree().process_frame
	# 取出已加载的资源
	for pname in preset_map:
		preset_map[pname] = ResourceLoader.load_threaded_get(preset_map[pname])
	# 移除遮罩
	_remove_loading_overlay()


func getpre(prename : String):
	if preset_map.has(prename) :
		if preset_map[prename]==null:
			pass
		else:
			return preset_map[prename]
	if(prename.contains('img')):
		printerr('img  '+prename+'  not found!')
		return preset_map.img_p
	if(prename.contains('enm')):
		printerr('enm  '+prename+'  not found!')
		return preset_map.enemy
	if(prename.contains('sum')):
		printerr('sum  '+prename+'  not found!')
		return preset_map.summon

	printerr('pre  '+prename+'  not found!')
	return null
