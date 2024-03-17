extends Node2D

@onready var hives = $Hives
@onready var bees = $Bees
@onready var camera_2d = $Camera2D

const MIN_X: int = -4096
const MIN_Y: int = -2048
const MAX_X: int = 4096
const MAX_Y: int = 2048
const ZOOM_MIN: float = 0.1
const ZOOM_MAX: float = 8.0
const ZOOM_FACTOR: float = 0.1
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
					bee.set_home(get_global_mouse_position())
	
	if Input.is_action_just_pressed("SendHome"):
		for bee in bees.get_children():
			bee.set_cur_hive(bee.get_origin_hive())
			bee.set_home(bee.get_origin_hive().global_position)
	if Input.is_action_just_pressed("Esc"):
		SignalManager.on_deselect_all.emit()
		GameManager.set_cursor_mode(GameManager.CURSOR_MODE.SELECT)

func is_mouse_over_hive(hive: hive_base) -> bool:
	var hive_radius: float = hive.body_collision.get_shape().get_radius()
	var mouse_offset: Vector2 = hive.global_position - get_global_mouse_position()
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
		clampf(_screen_start.x + vector.x, MIN_X, MAX_X - get_window().size.x / camera_2d.zoom.x), 
		clampf(_screen_start.y + vector.y, MIN_Y, MAX_Y - get_window().size.y / camera_2d.zoom.y)
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
		zoom_camera(ZOOM_FACTOR)
	if Input.is_action_just_pressed("ScrollDown") == true:
		zoom_camera(-ZOOM_FACTOR)

func zoom_camera(zoom_factor: float) -> void:
	var zoom: float = camera_2d.zoom.x * zoom_factor
	var vmp: Vector2 = get_viewport().get_mouse_position()
	var xratio: float = vmp.x / get_viewport().size.x
	var yratio: float = vmp.y / get_viewport().size.y
	var old_size: Vector2 = Vector2(get_viewport().size.x / camera_2d.zoom.x, get_viewport().size.y / camera_2d.zoom.y)
	camera_2d.zoom = (camera_2d.zoom + Vector2(zoom, zoom)).clamp(Vector2(ZOOM_MIN,ZOOM_MIN), Vector2(ZOOM_MAX,ZOOM_MAX))
	print("new viewport size: %.2f" % ( get_viewport().size.x / camera_2d.zoom.x ) )
	var new_size: Vector2 = Vector2(get_viewport().size.x / camera_2d.zoom.x, get_viewport().size.y / camera_2d.zoom.y)
	var total_pixels_less: Vector2 = old_size - new_size
	var cam_pan: Vector2 = Vector2(xratio * total_pixels_less.x, yratio * total_pixels_less.y)
	camera_2d.global_position = Vector2(
		clampf(camera_2d.global_position.x + cam_pan.x, MIN_X, MAX_X - get_viewport().size.x / camera_2d.zoom.x),
		clampf(camera_2d.global_position.y + cam_pan.y, MIN_Y, MAX_Y - get_viewport().size.y / camera_2d.zoom.y)
	)



func calculate_cursor_mode() -> void:
	if Input.is_action_just_pressed("BuildMode") == true:
		if GameManager.get_cursor_mode() == GameManager.CURSOR_MODE.BUILD:
			return
		SignalManager.on_deselect_all.emit()
		show_ghost_object(HIVE_BASE)
		GameManager.set_cursor_mode(GameManager.CURSOR_MODE.BUILD)
	if Input.is_action_just_pressed("SelectMode") == true:
		if GameManager.get_cursor_mode() == GameManager.CURSOR_MODE.SELECT:
			return
		GameManager.set_cursor_mode(GameManager.CURSOR_MODE.SELECT)
