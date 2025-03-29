extends BaseGUIView


@export_group("UI")
@export var name_text : Label
@export var nickname : Label
@export var content : Label
@export var left_avatar : TextureRect
@export var right_avatar : TextureRect

@export_group("Dialogue")
@export var dialogue_group : DialogueGroup

var dialogue_index := 0
var tween : Tween


func _ready() -> void:
	get_tree().paused = true
	display_next_dialogue()


func _input(event):
	if event.is_action_pressed("next_dialogue"):
		display_next_dialogue()


func display_next_dialogue():
	if dialogue_index >= len(dialogue_group.group):
		if not dialogue_group.bgm.is_empty():
			AudioManager.play_bgm(dialogue_group.bgm)

		get_tree().paused = false
		close_self()
		return

	var dialogue := dialogue_group.group[dialogue_index]

	if tween and tween.is_running():
		tween.kill()
		content.text = dialogue.content
		dialogue_index += 1
	else:
		name_text.text = dialogue.name
		nickname.text = dialogue.nickname

		if dialogue.stop:
			AudioManager.bgm_over()
			AudioManager.stop_background_bgm()

		if not dialogue.bgm.is_empty():
			AudioManager.stop_background_bgm()
			get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_callback(func(): AudioManager.play_background_bgm(dialogue.bgm)).set_delay(3)

		tween = get_tree().create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		content.text = ""
		for character in dialogue.content:
			tween.tween_callback(append_character.bind(character)).set_delay(0.05)
		tween.tween_callback(func(): dialogue_index += 1)

		if dialogue.right:
			left_avatar.texture = null
			right_avatar.texture = dialogue.avatar
		else:
			left_avatar.texture = dialogue.avatar
			right_avatar.texture = null


func append_character(character : String):
	content.text += character
