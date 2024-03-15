extends Node


enum CURSOR_MODE { SELECT, BUILD }

var _selected_hives: Array[hive_base]  = []
var _selected_bees: Array[bee_base] = []
var _cm: CURSOR_MODE
# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_hive_click.connect(on_hive_click)
	SignalManager.on_bees_grabbed.connect(on_bees_grabbed)
	SignalManager.on_deselect_all.connect(on_deselect_all)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func add_to_select_hives(hives: Array[hive_base]) -> void:
	_selected_hives.append_array(hives)
	print("hive selected: %s" % str(_selected_hives[0]))
	
func add_to_select_bees(bees: Array[bee_base]) -> void:
	_selected_bees.append_array(bees)


func select_hives() -> void:
	for hive in _selected_hives:
		hive.on_select()
		hive.select_child_bees(1.0) # select 100% of the hive's bees

func select_bees() -> void:
	for bee in _selected_bees:
		bee.on_select()

func clear_selected_bees() -> void:
	for bee in _selected_bees:
		bee.on_deselect()
	_selected_bees.clear()

func clear_selected_hives() -> void:
	for hive in _selected_hives:
		hive.on_deselect()
	_selected_hives.clear()

func set_cursor_mode(mode_select: CURSOR_MODE) -> void:
	if mode_select == _cm:
		return
	var _cm_last_frame: CURSOR_MODE = _cm
	_cm = mode_select
	print("Mode: %s" % str(CURSOR_MODE.keys()[_cm]))
	SignalManager.on_mode_select.emit(_cm_last_frame)

func on_hive_click(hive: hive_base):
	if _cm == CURSOR_MODE.BUILD:
		return
	var hive_list: Array[hive_base] = [hive]
	if _selected_hives.size() > 0:
		if _selected_hives[0] == hive:
			return
		for old_hive in _selected_hives:
			old_hive.on_deselect()
		_selected_hives.clear()
	add_to_select_hives(hive_list)
	select_hives()

func on_bees_grabbed(bees: Array[bee_base]) -> void:
	clear_selected_bees()
	add_to_select_bees(bees)
	select_bees()

func on_deselect_all() -> void:
	clear_selected_hives()
	clear_selected_bees()

func get_cursor_mode() -> CURSOR_MODE:
	return _cm
