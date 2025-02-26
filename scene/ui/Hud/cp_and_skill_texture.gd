extends TextureRect

var selfname = ''
var level = 0
var upgrade_group
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func destroy(delname):
	if selfname == delname:
		queue_free()

	pass
func upgrade(upname):
	if upgrade_group == upname:
		level += 1
		$RichTextLabel.text = selfname + 'LV.' + str(level)
