extends Node
## AudioManager.gd
##
## 一个用于管理游戏中背景音乐 (BGM) 和音效 (SFX) 的节点。
## 它包含两个独立的 BGM 播放器（一个BGM，一个背景 BGM）和一个音效播放器池。
## 依赖于一个名为 PresetManager 的自动加载项来获取音频流资源。
## 将不同的音频类型分配到不同的音频总线 ('bgm', 'background', 'sfx')，以便进行混音控制。

# BGM 播放器 (播放将暂停背景BGM)
var bgm_player:AudioStreamPlayer
# 背景 BGM 播放器
var background_bgm_player:AudioStreamPlayer
# 用于存放所有动态创建的音效播放器的节点
var SFXPlayerPool
# 用于在切换背景 BGM 时临时存储原始的 AudioStream
var swaping_backbgm:AudioStream
# 存储正在播放的音效及其对应的播放器实例的字典 {sfx_name: AudioStreamPlayer}
# 用于复用特定音效的播放器
@onready var sfx_player_playing_pair = {}
func _ready():
	# 设置处理模式为 ALWAYS，确保即使游戏暂停，音频管理器也能继续处理。
	# 这对于不间断的背景音乐或全局音效很重要。
	process_mode = Node.PROCESS_MODE_ALWAYS
# --- 初始化主 BGM 播放器 ---
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = 'bgm_player' # 设置节点名称，便于调试
	# 将主 BGM 输出到名为 'bgm' 的音频总线
	bgm_player.bus = 'bgm'
	add_child(bgm_player) # 将播放器添加到场景树

	# --- 初始化背景 BGM 播放器 ---
	background_bgm_player = AudioStreamPlayer.new()
	background_bgm_player.name = 'background_bgm_player' # 设置节点名称
	# 将背景 BGM 输出到名为 'background' 的音频总线
	background_bgm_player.bus = 'background'
	add_child(background_bgm_player) # 将播放器添加到场景树

	# --- 初始化 SFX 播放器池节点 ---
	SFXPlayerPool = Node.new()
	SFXPlayerPool.name = 'SFXPlayerPool' # 设置节点名称
	add_child(SFXPlayerPool) # 将池节点添加到场景树


## 播放背景 BGM。
## @param bgm_name: String - 要播放的背景 BGM 的名称（需要 PresetManager 能识别）。
func play_background_bgm(bgm_name: String) -> void:
	# 从 PresetManager 获取音频流
	var stream = PresetManager.getpre(bgm_name)
	if stream:
		background_bgm_player.stream = stream
		background_bgm_player.play()
	else:
		printerr("AudioManager: 未找到背景 BGM 资源 '", bgm_name, "'")


## 停止播放背景 BGM。
func stop_background_bgm() -> void:
	background_bgm_player.stop()


## 播放主 BGM。
## 当主 BGM 播放时，背景 BGM 会被暂停。
## @param bgm_name: String - 要播放的主 BGM 的名称（需要 PresetManager 能识别）。
func play_bgm(bgm_name: String) -> void:
	# 暂停背景 BGM
	background_bgm_player.set_stream_paused(true)

	# 从 PresetManager 获取音频流
	var stream = PresetManager.getpre(bgm_name)
	if stream:
		bgm_player.stream = stream
		bgm_player.play()
	else:
		# 如果主 BGM 资源未找到，则恢复背景 BGM
		background_bgm_player.set_stream_paused(false)
		printerr("AudioManager: 未找到主 BGM 资源 '", bgm_name, "'")

func play_once_loop_bgm(bgm_name_once: String,bgm_name_loop: String):
	# 暂停背景 BGM
	background_bgm_player.set_stream_paused(true)

	# 从 PresetManager 获取音频流
	var stream = PresetManager.getpre(bgm_name_once)
	if stream:
		bgm_player.stream = stream
		bgm_player.play()
	else:
		# 如果主 BGM 资源未找到，则恢复背景 BGM
		background_bgm_player.set_stream_paused(false)
		printerr("AudioManager: 未找到主 BGM 资源 '", bgm_name_once, "'")
	stream = PresetManager.getpre(bgm_name_loop)
	await bgm_player.finished
	if stream:
		bgm_player.stream = stream
		bgm_player.play()
	else:
		# 如果主 BGM 资源未找到，则恢复背景 BGM
		background_bgm_player.set_stream_paused(false)
		printerr("AudioManager: 未找到主 BGM 资源 '", bgm_name_loop, "'")
## 切换背景 BGM。
## 可以切换到新的背景 BGM，或切换回之前被替换掉的背景 BGM。
## 会尝试从当前播放位置继续播放新的或恢复的 BGM。
## @param bgm_name: String (可选) - 要切换到的新背景 BGM 的名称。
##                            如果为 null，则切换回之前存储的背景 BGM。

func swap_backbgm(bgm_name: String = "") -> void:
	# 获取当前的播放位置，以便无缝切换
	var point = background_bgm_player.get_playback_position()

	if bgm_name != "":
		# --- 切换到新的背景 BGM ---
		# 备份当前的背景 BGM 流
		swaping_backbgm = background_bgm_player.stream
		# 从 PresetManager 获取新的音频流
		var new_stream = PresetManager.getpre(bgm_name)
		if new_stream:
			background_bgm_player.stream = new_stream
			background_bgm_player.play(point) # 从之前的位置开始播放新 BGM
		else:
			printerr("AudioManager: 切换背景 BGM 时未找到资源 '", bgm_name, "'")
			# 如果新资源无效，则不进行切换，直接返回
			return
	else:
		# --- 切换回之前存储的背景 BGM ---
		if swaping_backbgm:
			background_bgm_player.stream = swaping_backbgm
			background_bgm_player.play(point) # 从之前的位置开始播放恢复的 BGM
			swaping_backbgm = null # 清除备份引用
		else:
			printerr("AudioManager: 没有可恢复的背景 BGM (swaping_backbgm 为空)")


## 主 BGM 播放完毕或被手动停止时调用。
## 停止主 BGM 播放器，并恢复背景 BGM 的播放。
func bgm_over() -> void:
	bgm_player.stop()
	# 恢复背景 BGM 的播放（如果之前被 play_bgm 暂停了）
	background_bgm_player.set_stream_paused(false)


## 播放音效 (SFX)。
## 如果该音效已有对应的播放器，则复用该播放器；否则创建一个新的播放器。
## @param sfx_name: String - 要播放的音效的名称（需要 PresetManager 能识别）。
func play_sfx(sfx_name: String,volume = 0.0,position = 0) -> void:
	var aplayer: AudioStreamPlayer

	# 检查是否已有该音效的播放器
	if !sfx_player_playing_pair.has(sfx_name):
		# 如果没有，创建一个新的播放器
		aplayer = new_sfx_player()
		# 将新播放器添加到音效池节点下
		SFXPlayerPool.add_child(aplayer)
		# 在字典中记录该音效和其对应的播放器
		sfx_player_playing_pair[sfx_name] = aplayer
	else:
		# 如果有，获取现有的播放器实例
		aplayer = sfx_player_playing_pair[sfx_name]
	aplayer.volume_db = volume
	# 从 PresetManager 获取音效音频流
	var stream = PresetManager.getpre(sfx_name)
	if stream:
		aplayer.stream = stream
		aplayer.play(position) # 播放音效
	else:
		printerr("AudioManager: 未找到音效资源 '", sfx_name, "'")


## 创建并配置一个新的音效播放器实例。
## @return: AudioStreamPlayer - 新创建并配置好的播放器实例。
func new_sfx_player() -> AudioStreamPlayer:
	var new_player = AudioStreamPlayer.new()
	# 将音效输出到名为 'sfx' 的音频总线
	new_player.bus = 'sfx'
	return new_player
