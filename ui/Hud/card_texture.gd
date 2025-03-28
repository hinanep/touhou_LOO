extends TextureRect

var cardname
var describe
var cardid
var card_texture
var manacost
var level = 0
var upgrade_group

func set_card(card_info):
	card_texture = PresetManager.getpre('img_'+card_info.id)
	set_texture(card_texture)

	cardid = card_info.id
	cardname = table.TID[card_info.id+'_name'][player_var.language]
	describe = cardname
	upgrade_group = card_info.upgrade_group
	manacost = card_info.mana
	SignalBus.del_card.connect(destroy)
	SignalBus.upgrade_group.connect(upgrade)

func upgrade(upname):
	if upgrade_group == upname:
		level += 1
		describe = cardname + 'LV.' + str(level)

func destroy(id):
	if id == cardid:
		queue_free()
