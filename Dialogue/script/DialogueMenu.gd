extends BaseGUIView


@export_group('UI')
@export var character : Label
@export var title : Label
@export var content : Label
@export var left_tachie : TextureRect
@export var right_tachie : TextureRect

@export_group('Dialogues')
@export var dialogues : Dictionary

var i := 1
var tween : Tween
var dialogue : Dictionary


func _ready() -> void:
	get_tree().paused = true
	dialogues = table.dialogues.duplicate(true)
	display_next_dialogue()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('next_dialogue'):
		display_next_dialogue()


func display_next_dialogue():
	if i > len(dialogues):
		close_self()
		get_tree().paused = false
		return
	
	if tween and tween.is_running():
		tween.kill()
		content.text = dialogue.content
		i += 1
	else:
		dialogue = dialogues.get(str(i))
	
		#dialogue.get_or_add('position')
		
		dialogue.get_or_add('content', '')
		dialogue.get_or_add('left_tachie')
		dialogue.get_or_add('right_tachie')
		dialogue.get_or_add('character', '')
		dialogue.get_or_add('title', '')
		
		if dialogue.content != '':
			dialogue.content = table.TID.get(dialogue.content).CHS
		
		if dialogue.character != '':
			dialogue.character = table.TID.get(dialogue.character).CHS
		
		if dialogue.title != '':
			dialogue.title = table.TID.get(dialogue.title).CHS
			
		character.text = dialogue.character
		title.text = dialogue.title

		if dialogue.has('bgm'):
			AudioManager.stop_background_bgm()
			
			if dialogue.bgm != 'STOP':
				var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_callback(func(): AudioManager.play_background_bgm(dialogue.bgm)).set_delay(3)
				tw = null

		tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		content.text = ''
		for letter in dialogue.content:
			tween.tween_callback(append_letter.bind(letter)).set_delay(0.05)
		tween.tween_callback(func(): i += 1)

		#if dialogue.position == 'left':
		left_tachie.texture = PresetManager.getpre(dialogue.left_tachie)
		right_tachie.texture = PresetManager.getpre(dialogue.right_tachie)
		#else:
		#	left_tachie.texture = dialogue.tachie
		#	right_tachie.texture = null


func append_letter(letter : String):
	content.text += letter
