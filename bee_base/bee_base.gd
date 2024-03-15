extends Node2D

class_name bee_base

@onready var bee_body = $BeeBody
@onready var label = $BeeBody/Label
@onready var jitter_timer = $BeeBody/JitterTimer
@onready var sprite_2d = $BeeBody/Sprite2D

const JITTER_INTERVAL: float = 0.2

var _orbit_radius: float = 0.5	# 0.25 is a good default
var _max_vel: float = 8	#4 is a good default
var _acc: float = ( (_max_vel / 2) * (_max_vel / 2) ) / _orbit_radius
var _flight_jitter = 2 * sqrt(_max_vel)
var _home_point: Vector2 = Vector2.ZERO
var _direction: Vector2 = Vector2.ZERO
var _vel: Vector2 = Vector2.ZERO
var _origin_hive: hive_base
var _cur_hive: hive_base
var _selected: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# set random initial direction and speed
	_direction = Vector2.from_angle(randf_range(deg_to_rad(-180),deg_to_rad(180)))
	_vel = _direction * _max_vel
	
	# set home
	set_home(global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	update_label()
	set_direction()
	adjust_velocity(delta)
	adjust_position(delta)
	
	bee_body.global_position += _vel

func _get_class_name() -> String:
	return "bee_base"

func update_label() -> void:
	label.text = "%.1f, %.1f\nvel: %.1f" % [bee_body.global_position.x, bee_body.global_position.y, _vel.length()]

func set_direction() -> void:
	_direction = bee_body.global_position.direction_to(_home_point)

func adjust_velocity(delta: float) -> void:
	_vel = (_vel + delta * _acc * _direction).limit_length(_max_vel)

func adjust_position(delta: float) -> void:
	bee_body.global_position = bee_body.global_position + _vel * delta

func add_jitter() -> void:
	var jitter_dir = Vector2.from_angle(randf_range(deg_to_rad(-180),deg_to_rad(180)))
	_vel = _vel + jitter_dir * _flight_jitter

func on_select() -> void:
	sprite_2d.self_modulate = Color("ff9193")
	_selected = true

func on_deselect() -> void:
	sprite_2d.self_modulate = Color("ffffff")
	_selected = false

func set_home(point: Vector2) -> void:
	_home_point = point

func set_origin_hive(hive: hive_base) -> void:
	_origin_hive = hive
	
func set_cur_hive(hive: hive_base) -> void:
	_cur_hive = hive

func get_origin_hive() -> hive_base:
	return _origin_hive
	
func get_cur_hive() -> hive_base:
	return _cur_hive

func _on_jitter_timer_timeout():
	add_jitter()
	jitter_timer.wait_time = randf_range(JITTER_INTERVAL - JITTER_INTERVAL / 2, JITTER_INTERVAL + JITTER_INTERVAL / 2)
