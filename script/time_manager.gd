extends Node
@onready var rich_text_label = $time_ui/MarginContainer/RichTextLabel
@onready var timer = $Timer

func _process(_delta):
	format_display(get_time_passed())
func get_time_passed():
	
	return timer.wait_time - timer.time_left
	
func format_display(seconds):
		var minutes = floor(seconds/60)
		var sec = floor(seconds - 60 * minutes)
		rich_text_label.text = str(minutes) + ":" + ("%02d" % sec)
