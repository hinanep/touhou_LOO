extends TextureRect

var selfname = ''
var level = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func destroy(delname):
	if selfname == delname:
		queue_free()

	pass
func upgrade(upname):
	if selfname == upname:
		level += 1
		$RichTextLabel.text = selfname + 'LV.' + str(level)
