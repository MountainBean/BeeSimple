extends Node2D

@onready var hives = $Hives
@onready var bees = $Bees
@onready var camera_2d = $Camera2D


const HIVE_BASE = preload("res://hive_base/hive_base.tscn")

var _ghost_object: Node

var _dragging: bool
var _screen_start: Vector2
var _screen_drag_start: Vector2
var _screen_dragged_vector: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.set_cursor_mode(GameManager.CURSOR_MODE.SELECT)
	SignalManager.on_mode_select.connect(on_mode_select)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_camera()
	calculate_cursor_mode()
	match GameManager.get_cursor_mode():
		GameManager.CURSOR_MODE.BUILD:
			_ghost_object.position = get_global_mouse_position()
			if Input.is_action_just_pressed("MouseClick"):
				for hive in hives.get_children():
					if is_mouse_over_hive(hive):
						print("already got a hive here...")
						return
				hive_at_mouse(get_global_mouse_position())
		GameManager.CURSOR_MODE.SELECT:
			if Input.is_action_just_pressed("RightClick"):
				for hive in hives.get_children():
					if is_mouse_over_hive(hive):
						print("assigning bees -> %s" % str(hive))
						for bee in GameManager._selected_bees:
							bee.set_cur_hive(hive)
							bee.set_home(hive.global_position)
						return
				for bee in GameManager._selected_bees:
					bee.set_home(get_viewport().get_mouse_position())
	
	if Input.is_action_just_pressed("SendHome"):
		for bee in bees.get_children():
			bee.set_cur_hive(bee.get_origin_hive())
			bee.set_home(bee.get_origin_hive().global_position)
	if Input.is_action_just_pressed("Esc"):
		SignalManager.on_deselect_all.emit()
		GameManager.set_cursor_mode(GameManager.CURSOR_MODE.SELECT)

func is_mouse_over_hive(hive: hive_base) -> bool:
	var hive_radius: float = hive.body_collision.get_shape().get_radius()
	var mouse_offset: Vector2 = hive.global_position - get_viewport().get_mouse_position()
	return mouse_offset.length() < hive_radius

func hive_at_mouse(pos: Vector2) -> void:
	var hive = HIVE_BASE.instantiate()
	hive.global_position = pos
	hives.add_child(hive)
	hive.spawn_timer.start()

func show_ghost_object(scene: PackedScene) -> void:
	_ghost_object = scene.instantiate()
	_ghost_object.set_process(false)
	add_child(_ghost_object)
	_ghost_object.modulate = (Color("ffffff90"))


func hide_ghost_object() -> void:
	_ghost_object.queue_free()

func on_mode_select(cm_last_frame: GameManager.CURSOR_MODE) -> void:
	if cm_last_frame == GameManager.CURSOR_MODE.BUILD:
		hide_ghost_object()

func update_camera_drag() -> void:
	var vector = (_screen_drag_start - get_viewport().get_mouse_position()) / camera_2d.zoom
	camera_2d.global_position = Vector2(
		clampf(_screen_start.x + vector.x, 0, camera_2d.limit_right - get_window().size.x / camera_2d.zoom.x), 
		clampf(_screen_start.y + vector.y, 0, camera_2d.limit_bottom - get_window().size.y / camera_2d.zoom.y)
	)
	print("drag mouse: %.1f, %.1f" % [vector.x, vector.y])
	

func process_camera() -> void:
	if Input.is_action_just_pressed("MiddleClick") == true:
		_screen_drag_start = get_viewport().get_mouse_position()
		_screen_start = camera_2d.global_position
		print("start drag: %.1f, %.1f" % [_screen_drag_start.x, _screen_drag_start.y])
	if Input.is_action_pressed("MiddleClick") == true:
		update_camera_drag()
	if Input.is_action_just_pressed("ScrollUp") == true:
		camera_2d.zoom = (camera_2d.zoom + Vector2(0.1,0.1)).clamp(Vector2(0.25,0.25), Vector2(2,2))
		print("zoom in: %.2f" % camera_2d.zoom.x)
	if Input.is_action_just_pressed("ScrollDown") == true:
		camera_2d.zoom =  (camera_2d.zoom - Vector2(0.1,0.1)).clamp(Vector2(0.25,0.25), Vector2(2,2))
		print("zoom out: %.2f" % camera_2d.zoom.x)
		

func calculate_cursor_mode() -> void:
	if Input.is_action_just_pressed("BuildMode") == true:
		SignalManager.on_deselect_all.emit()
		show_ghost_object(HIVE_BASE)
		GameManager.set_cursor_mode(GameManager.CURSOR_MODE.BUILD)
	if Input.is_action_just_pressed("SelectMode") == true:
		GameManager.set_cursor_mode(GameManager.CURSOR_MODE.SELECT)
