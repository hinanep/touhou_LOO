extends TextureRect

var cardname
var cardid
var level = 0
var upgrade_group

func set_card(card_list):
	set_texture(PresetManager.getpre('img_'+card_list.id))

	cardid = card_list.id
	cardname = table.TID[card_list.id+'_name'][player_var.language]
	$cn.text = cardname
	upgrade_group = card_list.upgrade_group

	SignalBus.del_card.connect(destroy)
	SignalBus.upgrade_group.connect(upgrade)

func upgrade(upname):
	if upgrade_group == upname:
		level += 1
		$cn.text = cardname + 'LV.' + str(level)

func destroy(id):
	if id == cardid:
		queue_free()
