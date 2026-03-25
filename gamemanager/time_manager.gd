extends Node
@onready var firsttext = $time_ui/timetext/first
@onready var secondtext = $time_ui/timetext/second
@onready var timer:Timer = $Timer

var seconds :int= 0
var minutes :int= 0
var boss_seconds:int = 0
var boss_miliseconds:int = 0
var boss_cardtime = 0
var pause_boss_hud_time := false
var boss_mili_tween: Tween = null
#func get_time_passed():
var display = null

#	return timer.wait_time - timer.time_left
func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	SignalBus.pause_boss_hud_time.connect(_on_pause_boss_hud_time)

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
	pause_boss_hud_time = false
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
	if pause_boss_hud_time:
		return

	boss_seconds += 1
	boss_miliseconds = 0
	player_var.time_secs = seconds

	if boss_mili_tween and boss_mili_tween.is_valid():
		boss_mili_tween.kill()
	boss_mili_tween = create_tween()
	boss_mili_tween.tween_method(setmili,99,0,0.99)
	player_var.underrecycle_tween.append(boss_mili_tween)
func setmili(mili:int):
	if pause_boss_hud_time:
		return
	boss_miliseconds = mili

func _on_pause_boss_hud_time(is_pause: bool) -> void:
	pause_boss_hud_time = is_pause
	if is_pause and boss_mili_tween and boss_mili_tween.is_valid():
		boss_mili_tween.kill()
