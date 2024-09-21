extends Node

@export var bgm = {}
@export var sfx = {}

@onready var bgm_player = $BGMPlayer
@onready var sfx_player = $SFXPlayer
func _ready():
	pass

func play_bgm(bgm_name:String) -> void:
	bgm_player.stream = load(bgm[bgm_name])
	bgm_player.play()
	
func play_sfx(sfx_name:String) -> void:
	sfx_player.stream = load(sfx[sfx_name])
	sfx_player.play()

