extends Node

@export var bgm = {}
@export var sfx = {}

@onready var bgm_player = $BGMPlayer
@onready var background_bgm_player = $Background_bgm
@onready var sfx_player_playing_pair = {}
func _ready():
	pass

func play_background_bgm(bgm_name:String) -> void:
	if(bgm.has(bgm_name)):
		background_bgm_player.stream = load(bgm[bgm_name])
		background_bgm_player.play()
func stop_background_bgm() -> void:

		background_bgm_player.stop()

func play_bgm(bgm_name:String) -> void:
	if(bgm.has(bgm_name)):
		background_bgm_player.set_stream_paused(true)
		bgm_player.stream = load(bgm[bgm_name])
		bgm_player.play()

func bgm_over():
	bgm_player.stop()
	background_bgm_player.set_stream_paused(false)
	
func play_sfx(sfx_name:String) -> void:
	if(!sfx_player_playing_pair.has(sfx_name)):
		var new_player = AudioStreamPlayer.new()
		$SFXPlayerPool.add_child(new_player)
		sfx_player_playing_pair[sfx_name] = new_player
	if(sfx.has(sfx_name)):	
		sfx_player_playing_pair[sfx_name].stream = load(sfx[sfx_name])
		sfx_player_playing_pair[sfx_name].play()


