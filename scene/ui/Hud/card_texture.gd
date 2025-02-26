extends TextureRect

var cardid
var level = 0
var upgrade_group
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$cn.text = cardid


func upgrade(upname):
	if upgrade_group == upname:
		level += 1
		$cn.text = cardid + 'LV.' + str(level)

func destroy(id):
	if id == cardid:
		queue_free()
