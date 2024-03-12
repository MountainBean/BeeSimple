extends Node

enum CURSOR_MODE { SELECT, BUILD }

var _cm: CURSOR_MODE
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_cursor_mode(mode_select: CURSOR_MODE) -> void:
	_cm = mode_select
	print("Mode: %s" % str(CURSOR_MODE.keys()[_cm]))
	SignalManager.on_mode_select.emit()


func get_cursor_mode() -> CURSOR_MODE:
	return _cm
