extends BaseGUIView


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	G.get_gui_view_manager().open_view("StartMenu")
	close_self()
	pass # Replace with function body.
