extends TextureRect

var cardid
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.del_card.connect(destroy)



func destroy(id):
	if id == cardid:
		queue_free()
