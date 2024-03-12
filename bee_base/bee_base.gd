extends Node2D

class_name bee_base

@onready var bee_body = $BeeBody
@onready var label = $BeeBody/Label
@onready var jitter_timer = $BeeBody/JitterTimer

const JITTER_INTERVAL: float = 0.2

var _orbit_radius: float = 0.4	# 0.25 is a good default
var _max_vel: float = 8	#4 is a good default
var _acc: float = ( (_max_vel / 2) * (_max_vel / 2) ) / _orbit_radius
var _home_point: Vector2 = Vector2.ZERO
var _direction: Vector2 = Vector2.ZERO
var _vel: Vector2 = Vector2.ZERO
var marker1: Sprite2D
var origin_hive: hive_base

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

func update_label() -> void:
	label.text = "%.1f, %.1f\nvel: %.1f" % [bee_body.global_position.x, bee_body.global_position.y, _vel.length()]

func set_direction() -> void:
	_direction = bee_body.global_position.direction_to(_home_point)

func adjust_velocity(delta: float) -> void:
	_vel = (_vel + delta * _acc * _direction).limit_length(_max_vel)

func adjust_position(delta: float) -> void:
	bee_body.global_position = bee_body.global_position + _vel * delta

func add_jitter() -> void:
	var flight_jitter = _max_vel / 2
	var jitter_dir = Vector2.from_angle(randf_range(deg_to_rad(-180),deg_to_rad(180)))
	_vel = _vel + jitter_dir * flight_jitter

func set_home(point: Vector2) -> void:
	_home_point = point

func set_hive(hive: hive_base) -> void:
	origin_hive = hive

func get_hive() -> hive_base:
	return origin_hive

func _on_jitter_timer_timeout():
	add_jitter()
	jitter_timer.wait_time = randf_range(JITTER_INTERVAL - JITTER_INTERVAL / 2, JITTER_INTERVAL + JITTER_INTERVAL / 2)
