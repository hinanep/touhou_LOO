extends Node


var bgm_player:AudioStreamPlayer
var background_bgm_player:AudioStreamPlayer
var SFXPlayerPool
var swaping_backbgm:AudioStream
@onready var sfx_player_playing_pair = {}
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = 'bgm_player'
	#bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	bgm_player.bus ='bgm'

	background_bgm_player =  AudioStreamPlayer.new()
	background_bgm_player.name = 'background_bgm_player'
	#background_bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	background_bgm_player.bus ='background'

	add_child(bgm_player)
	add_child(background_bgm_player)

	SFXPlayerPool = Node.new()
	SFXPlayerPool.name = 'SFXPlayerPool'
	add_child(SFXPlayerPool)


func play_background_bgm(bgm_name:String) -> void:

	background_bgm_player.stream = PresetManager.getpre(bgm_name)
	background_bgm_player.play()
func stop_background_bgm() -> void:

	background_bgm_player.stop()

func play_bgm(bgm_name:String) -> void:

	background_bgm_player.set_stream_paused(true)
	bgm_player.stream = PresetManager.getpre(bgm_name)
	bgm_player.play()

func swap_backbgm(bgm_name = null):
	if bgm_name == null:
		var point = background_bgm_player.get_playback_position()
		background_bgm_player.stream = swaping_backbgm
		background_bgm_player.play(point)
		return
	swaping_backbgm = background_bgm_player.stream
	var point = background_bgm_player.get_playback_position()
	background_bgm_player.stream = PresetManager.getpre(bgm_name)
	background_bgm_player.play(point)

func bgm_over():
	bgm_player.stop()
	background_bgm_player.set_stream_paused(false)

func play_sfx(sfx_name:String) -> void:
	if(!sfx_player_playing_pair.has(sfx_name)):
		var new_player = AudioStreamPlayer.new()

		SFXPlayerPool.add_child(new_player)
		sfx_player_playing_pair[sfx_name] = new_player

	sfx_player_playing_pair[sfx_name].stream = PresetManager.getpre(sfx_name)
	sfx_player_playing_pair[sfx_name].play()
func new_sfx_player():
	var new_player = AudioStreamPlayer.new()
	new_player.bus = 'sfx'
	return new_player
