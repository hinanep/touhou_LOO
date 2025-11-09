extends TextureRect

var cardname
var describe
var cardid
var card_texture
var manacost
var level = 0
var upgrade_group
var cpable = []
func _ready() -> void:
	SignalBus.focus_on.connect(detact_focus)
	SignalBus.focus_off.connect(set_highlight.bind(false))

func set_card(card_info):
	card_texture = PresetManager.getpre('img_'+card_info.id)
	set_texture(card_texture)

	cardid = card_info.id
	cpable = player_var.CpManager.get_cpable_array(cardid)
	cardname = table.TID[card_info.id+'_name'][player_var.language]
	describe = cardname
	upgrade_group = card_info.upgrade_group
	manacost = card_info.mana
	SignalBus.del_card.connect(destroy)
	SignalBus.upgrade_group.connect(upgrade)

func upgrade(upname,cur):
	if upgrade_group == upname and upgrade_group!='none':
		level += 1
		describe = cardname + '\nLV.' + str(level)
		#describe +=  '\nLV.' + str(level)
		$cn.text = 'LV.' + str(level)
func destroy(id):
	if id == cardid:
		queue_free()

func detact_focus(type,id):
	if id in cpable:
		set_highlight(true)
func set_highlight(is_hl):
	if is_hl:
		set_instance_shader_parameter("brightness",0.8)
		set_instance_shader_parameter("width",11.0)

	else:
		set_instance_shader_parameter("brightness",0.0)
		set_instance_shader_parameter("width",0.0)
