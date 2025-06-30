extends BaseGUIView
var type = "none"
var tname = ""
@onready var spoint = $point/point
func _ready():
	for ucskill in table.Skill:
		var ski = table.Skill[ucskill]
		var skill_button = PresetManager.getpre("ui_test_skillbutton").instantiate()
		$upgrade_layer/skill/skill_container.add_child(skill_button)
		skill_button.set_texture('img_'+ski.id)
		skill_button.set_tooltip_text(ski.id)
		skill_button.selected.connect(on_skillbutton_select.bind(ski.id))
		skill_button.point = spoint

	for uccard in table.SpellCard:
		var cd = table.SpellCard[uccard]
		var card_button = PresetManager.getpre("ui_test_skillbutton").instantiate()
		$upgrade_layer/card/card_container.add_child(card_button)
		card_button.set_texture('img_'+cd.id)
		card_button.set_tooltip_text(cd.id)
		card_button.selected.connect(on_cardbutton_select.bind(cd.id))
		card_button.point = spoint

	for uccp in table.Couple:
		var cps = table.Couple[uccp]
		var cp_button = PresetManager.getpre("ui_test_skillbutton").instantiate()
		$upgrade_layer/cp/cp_container.add_child(cp_button)
		cp_button.set_texture('img_'+cps.id)
		cp_button.set_tooltip_text(cps.id)
		cp_button.selected.connect(on_cpbutton_select.bind(cps.id))
		cp_button.point = spoint

	for psv in table.Passive:
		var psv_info = table.Passive[psv]
		var psv_button = PresetManager.getpre("ui_test_skillbutton").instantiate()
		$upgrade_layer/psv/psv_container.add_child(psv_button)
		psv_button.set_texture('img_'+psv_info.id)
		psv_button.set_tooltip_text(psv_info.id)
		psv_button.selected.connect(on_psvbutton_select.bind(psv_info.id))
		psv_button.point = spoint

	for enm in table.Enemy:
		var enm_info = table.Enemy[enm]
		match enm_info.type:
			'zako':

				var zako_button = PresetManager.getpre("ui_test_skillbutton").instantiate()
				$summon_layer/zako/zako_container.add_child(zako_button)
				zako_button.set_texture('img_'+enm_info.id)
				zako_button.set_tooltip_text(enm_info.id)
				zako_button.selected.connect(on_enmbutton_select.bind(enm_info.id))
				zako_button.point = spoint
			'elite':
				var elite_button = PresetManager.getpre("ui_test_skillbutton").instantiate()
				$summon_layer/elite/elite_container.add_child(elite_button)
				elite_button.set_texture('img_'+enm_info.id)
				elite_button.set_tooltip_text(enm_info.id)
				elite_button.selected.connect(on_enmbutton_select.bind(enm_info.id))
				elite_button.point = spoint
	for i in $summon_layer/boss/boss_stage.get_child_count():
		$summon_layer/boss/boss_stage.get_child(i).pressed.connect(_on_boss_stage_change_pressed.bind(i))

	$summon_layer/boss/boss_container/keine.point = spoint
func on_skillbutton_select(skillname):
	$testhud/Button.grab_focus()
	type = "skill"
	tname = skillname


func on_cardbutton_select(cardname):
	$testhud/Button.grab_focus()
	type = "card"
	tname = cardname

func on_cpbutton_select(cpname):
	$testhud/Button.grab_focus()
	type = "cp"
	tname = cpname

func on_psvbutton_select(psvname):
	$testhud/Button.grab_focus()
	type = "psv"
	tname = psvname
func on_enmbutton_select(enmid):
	$testhud/Button.grab_focus()
	type = "enm"
	tname = enmid

func _on_update_pressed():
	match type:
		"skill":
			SignalBus.try_add_skill.emit(tname)

		"cp":
			player_var.CpManager.add_cp(tname)
			pass
		"psv":
			SignalBus.try_add_passive.emit(tname)
			pass
		"card":
			SignalBus.try_add_card.emit(tname)

		"none":
			pass
	$testhud/Button.grab_focus()



func _on_delete_pressed():
	match type:
		"skill":
			SignalBus.del_skill.emit(tname)

		"cp":
			SignalBus.cp_del.emit(tname)
			pass
		"psv":
			SignalBus.del_passive.emit(tname)

		"card":
			SignalBus.del_card.emit(tname)
		"none":
			pass
	$testhud/Button.grab_focus()


func _on_levelup_pressed():
	player_var.player_exp += player_var.exp_need


func _on_moremana_pressed():
	player_var.mana += (player_var.mana_max)
	$testhud/Button.grab_focus()


func p_o(id):
	var obj = instance_from_id(int(id))
	if obj:
		prints(obj, obj.owner, obj.get_script().get_script_property_list())

func _on_invincible_pressed() -> void:
	player_var.is_invincible = true




func _on_button_2_pressed():
	p_o($testhud/TextEdit.text)



func _on_button_3_pressed():
	print_orphan_nodes()


func _on_upgrade_pressed() -> void:
	$upgrade_layer.visible = true
	$summon_layer.visible = false


func _on_summon_layer_vis_pressed() -> void:
	$upgrade_layer.visible = false
	$summon_layer.visible = true

func _on_summon_pressed() -> void:

	var mob = PresetManager.getpre(tname).instantiate()
	mob.global_position = Vector2(200,0)
	mob.mob_info = table.Enemy[tname].duplicate()

	mob.drop_num = 1.0

	player_var.SpawnManager.add_mob(mob)


func _on_keine_pressed() -> void:

	player_var.boss_coming('keine')


func _on_boss_stage_change_pressed(stage:int) -> void:
	SignalBus.boss_set_stage.emit(stage)
