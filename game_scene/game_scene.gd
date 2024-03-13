extends Node2D

@onready var hives = $Hives


const HIVE_BASE = preload("res://hive_base/hive_base.tscn")
const BEE_BASE = preload("res://bee_base/bee_base.tscn")

var select_box: Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.set_cursor_mode(GameManager.CURSOR_MODE.SELECT)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	calculate_cursor_mode()
	match GameManager.get_cursor_mode():
		GameManager.CURSOR_MODE.BUILD:
			if Input.is_action_just_pressed("MouseClick"):
				for hive in hives.get_children():
					var hive_radius: float = hive.collision_shape_2d.get_shape().get_radius()
					var mouse_offset: Vector2 = hive.global_position - get_viewport().get_mouse_position()
					if mouse_offset.length() < hive_radius:
						print("already got a hive here...")
						return
				hive_at_mouse(get_viewport().get_mouse_position())
		GameManager.CURSOR_MODE.SELECT:
			if Input.is_action_just_pressed("RightClick"):
				for hive in hives.get_children():
					var hive_radius: float = hive.collision_shape_2d.get_shape().get_radius()
					var mouse_offset: Vector2 = hive.global_position - get_viewport().get_mouse_position()
					if mouse_offset.length() < hive_radius:
						print("assigning bees -> %s" % str(hive))
						for bee in GameManager._selected_bees:
							bee.set_cur_hive(hive)
							bee.set_home(hive.global_position)
						return
				for bee in GameManager._selected_bees:
					bee.set_home(get_viewport().get_mouse_position())
	
	if Input.is_action_just_pressed("SendHome"):
		for hive in hives.get_children(true):
			for bee in hive.get_bees():
				bee.set_home(bee.get_origin_hive().global_position)
	if Input.is_action_just_pressed("Esc"):
		SignalManager.on_deselect_all.emit()


func hive_at_mouse(pos: Vector2) -> void:
	var hive = HIVE_BASE.instantiate()
	hive.global_position = pos
	hives.add_child(hive)


func calculate_cursor_mode() -> void:
	if Input.is_action_just_pressed("BuildMode") == true:
		SignalManager.on_deselect_all.emit()
		GameManager.set_cursor_mode(GameManager.CURSOR_MODE.BUILD)
	if Input.is_action_just_pressed("SelectMode") == true:
		GameManager.set_cursor_mode(GameManager.CURSOR_MODE.SELECT)
