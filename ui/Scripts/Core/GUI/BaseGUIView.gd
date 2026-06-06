extends Node
class_name BaseGUIView

var config: GUIViewConfig
var viewInstanceId: int = -1


func _open() -> void:
	pass


func _close() -> void:
	pass


func open() -> void:
	_open()


func close() -> void:
	_close()


func close_self() -> void:
	G.get_gui_view_manager().close_view(viewInstanceId)
