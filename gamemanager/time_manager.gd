extends Node
@onready var rich_text_label = $time_ui/MarginContainer/RichTextLabel
@onready var timer = $Timer

var seconds :int= 0
var minutes :int= 0
#func _process(_delta):

#func get_time_passed():

#	return timer.wait_time - timer.time_left

func format_display():
		var sec :int= floor(seconds - 60 * minutes)
		rich_text_label.text = str(minutes) + ":" + ("%02d" % sec)


func _on_timer_timeout():
	seconds += 1
	player_var.time_secs = seconds
	minutes = floor(seconds/60.0)
	format_display()
	pass # Replace with function body.
