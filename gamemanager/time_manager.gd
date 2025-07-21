extends Node
@onready var firsttext = $time_ui/timetext/first
@onready var secondtext = $time_ui/timetext/second
@onready var timer:Timer = $Timer

var seconds :int= 0
var minutes :int= 0
#func _process(_delta):
var boss_seconds:int = 0
var boss_miliseconds:int = 0
var boss_cardtime = 0
#func get_time_passed():
var display = null

#	return timer.wait_time - timer.time_left
func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta: float) -> void:
	if display:
		display.call()
func format_display(first,second):
	firsttext.text = str(first)
	secondtext.text = "%02d" % second

func format_boss_display():
	firsttext.text = "%02d" % (boss_cardtime-boss_seconds)
	secondtext.text = "%02d" % boss_miliseconds

func set_boss_timer(card_time):
	timer.stop()
	if timer.is_connected("timeout",_on_timer_timeout):
		timer.timeout.disconnect(_on_timer_timeout)
		timer.timeout.connect(_on_boss_timer_timeout)
	display = format_boss_display
	boss_cardtime = card_time
	boss_seconds = 0
	boss_miliseconds = 0
	timer.start()

func _on_timer_timeout():
	seconds += 1
	player_var.time_secs = seconds
	minutes = floor(seconds/60.0)
	format_display(minutes,floor(seconds - 60 * minutes))

func _on_boss_timer_timeout():

	boss_seconds += 1
	boss_miliseconds = 0
	player_var.time_secs = seconds
	#create_tween().tween_property($".",boss_miliseconds,99,0.99)
	create_tween().tween_method(setmili,99,0,0.99)
func setmili(mili:int):
	boss_miliseconds = mili
