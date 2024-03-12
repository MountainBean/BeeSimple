extends Node

enum CURSOR_MODE { SELECT, BUILD }

var _selected_hives: Array[hive_base]  = []
var _selected_bees: Array[bee_base] = []
var _cm: CURSOR_MODE
# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_hive_select.connect(on_hive_select)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_to_select_hives(hives: Array[hive_base]) -> void:
	_selected_hives.append_array(hives)
	print("hive selected: %s" % str(_selected_hives[0]))
	
func add_to_select_bees(bees: Array[bee_base]) -> void:
	_selected_bees.append_array(bees)

func show_selected_hives() -> void:
	for hive in _selected_hives:
		hive.selected()

func set_cursor_mode(mode_select: CURSOR_MODE) -> void:
	_cm = mode_select
	print("Mode: %s" % str(CURSOR_MODE.keys()[_cm]))
	SignalManager.on_mode_select.emit()

func on_hive_select(hive: hive_base):
	var hive_list: Array[hive_base] = [hive]
	if _selected_hives.size() > 0:
		if _selected_hives[0] == hive:
			return
		for old_hive in _selected_hives:
			old_hive.deselect()
		_selected_hives.clear()
	add_to_select_hives(hive_list)
	show_selected_hives()

func get_cursor_mode() -> CURSOR_MODE:
	return _cm
