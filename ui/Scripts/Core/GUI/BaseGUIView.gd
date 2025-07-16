extends Node
class_name BaseGUIView

var config:GUIViewConfig
var viewInstanceId:int = -1


func _open():
	pass


func _close():
	pass


func open():
	_open()


func close():
	_close()


func close_self():
	G.get_gui_view_manager().close_view(viewInstanceId)
