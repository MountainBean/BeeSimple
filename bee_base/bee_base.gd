extends Node2D

class_name bee_base

@onready var bee_body = $BeeBody
@onready var label = $BeeBody/Label
@onready var jitter_timer = $BeeBody/JitterTimer
@onready var sprite_2d = $BeeBody/Sprite2D
@onready var bee_range = $BeeBody/BeeRange

const ORBIT_RADIUS: float = 100	# 1 is a radius of about 125 pixels
const MAX_VEL: float = 250
const JITTER_INTERVAL: float = 0.4

enum BEE_ROLE { QUEEN, DRONE, FORAGER, WORKER }
enum FLIGHT_MODE { IDLE, MOVING, FORAGING, LANDING, GROUNDED }
enum GROUNDED_MODE { FLYING, GATHERING, WALKING, STOPPED }

var _is_garrisoned: bool = true
var _encumbered: bool = false

var _bee_role: BEE_ROLE = BEE_ROLE.DRONE
var _flight_mode: FLIGHT_MODE = FLIGHT_MODE.IDLE
var _grounded_mode: GROUNDED_MODE = GROUNDED_MODE.FLYING

var _orbit_radius: float = ORBIT_RADIUS
var _max_vel: float = MAX_VEL
var _acc: float = ( _max_vel * _max_vel ) / _orbit_radius
var _flight_jitter: float = _max_vel / 2
var _home_point: Vector2 = Vector2.ZERO
var _direction: Vector2 = Vector2.ZERO
var _vel: Vector2 = Vector2.ZERO
var _origin_hive: hive_base
var _cur_hive: hive_base
var _selected: bool = false
var _orbit_tween: Tween
var _vel_tween: Tween
var _cur_flower: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	# set random initial direction and speed
	set_home(global_position)


func _physics_process(delta):
	calculate_flight_mode()
	update_label()
	set_direction()
	adjust_position(delta)
	adjust_velocity(delta)
	

func set_orbit(radius: float) -> void:
	_orbit_radius = radius

func set_max_vel(vel: float) -> void:
	_max_vel = vel

func _get_class_name() -> String:
	return "bee_base"

func update_label() -> void:
	label.text = str(FLIGHT_MODE.keys()[_flight_mode])

func set_direction() -> void:
	_direction = bee_body.global_position.direction_to(_home_point)

func adjust_velocity(delta: float) -> void:
	_vel = (_vel + delta * _acc * _direction).limit_length(_max_vel)

func adjust_position(delta: float) -> void:
	bee_body.global_position = bee_body.global_position + _vel * delta

func add_jitter() -> void:
	var r_list: Array[int] = [ -90, 90 ]
	var jitter_dir = Vector2.from_angle(_direction.angle() + deg_to_rad(r_list[randi() % r_list.size()]))
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

func ungarrison() -> void:
	_cur_hive._garrisoned_bees.erase(self)
	_is_garrisoned = false
	show()

func garrison(hive: hive_base) -> void:
	land_and_stop()
	_is_garrisoned = true
	hive._garrisoned_bees.append(self)
	
	hide()
	if _encumbered == true and _bee_role == BEE_ROLE.FORAGER:
		await get_tree().create_timer(3.0).timeout
		_encumbered = false
		start_flying()

func start_flying() -> void:
	if _is_garrisoned:
		ungarrison()
	if _cur_flower and _cur_flower._busy == true:
		_cur_flower._busy = false
	_cur_flower = null
	_direction = Vector2.from_angle(randf_range(deg_to_rad(-180),deg_to_rad(180)))
	_orbit_radius = ORBIT_RADIUS
	_max_vel = MAX_VEL
	_acc = ( _max_vel * _max_vel ) / _orbit_radius
	jitter_timer.start()
	_vel = _direction * _max_vel / 2
	_grounded_mode = GROUNDED_MODE.FLYING
	_flight_mode = FLIGHT_MODE.MOVING

func start_landing() -> void:
	_flight_mode = FLIGHT_MODE.LANDING
	await get_tree().create_timer(3).timeout
	_flight_jitter = 0

func start_moving() -> void:
	_max_vel = 1.2 * MAX_VEL
	_flight_jitter = _flight_jitter / 2
	_flight_mode = FLIGHT_MODE.MOVING

func start_idle() -> void:
	_max_vel = MAX_VEL
	_flight_jitter = _max_vel / 2
	_flight_mode = FLIGHT_MODE.IDLE

func start_foraging() -> void:
	if _flight_mode == FLIGHT_MODE.IDLE or _flight_mode == FLIGHT_MODE.MOVING:
		_max_vel = MAX_VEL
		_flight_jitter = _max_vel / 2
		_flight_mode = FLIGHT_MODE.FORAGING

func land_and_stop() -> void:
	_max_vel = 0
	_acc = 0
	_vel = Vector2.ZERO
	_flight_mode = FLIGHT_MODE.GROUNDED
	_grounded_mode = GROUNDED_MODE.STOPPED


func gather_nectar() -> void:
	print("%s is gathering." % get_instance_id())
	await get_tree().create_timer(5.0).timeout
	if _flight_mode != FLIGHT_MODE.GROUNDED:
		return
	_cur_flower._busy = false
	_encumbered = true
	return_to_hive()

func return_to_hive() -> void:
	set_home(get_cur_hive().global_position)
	start_flying()

func calculate_flight_mode() -> void:
	match _flight_mode: 
		FLIGHT_MODE.IDLE:
			if _bee_role == BEE_ROLE.FORAGER:
				if _encumbered == true:
					set_home(_cur_hive.marker_2d.global_position)
					start_landing()
				else:
					var hive_claimed_flowers: Array = _cur_hive._claimed_flowers
					set_home(hive_claimed_flowers[randi() % hive_claimed_flowers.size()].marker_2d.global_position)
					start_foraging()
			if bee_body.global_position.distance_to(_home_point) > _orbit_radius * 1.5:
				start_moving()
		FLIGHT_MODE.MOVING:
			if bee_body.global_position.distance_to(_home_point) < _orbit_radius * 0.8:
				start_idle()
		FLIGHT_MODE.FORAGING:
			var nearby_flowers: Array[Area2D] = bee_range.get_overlapping_areas() 
			var valid_flower_found: bool = false
			if nearby_flowers.size() > 0:
				for flower in nearby_flowers:
					if valid_flower_found == true:
						return
					if flower not in _cur_hive._claimed_flowers:
						return
					if flower != _cur_flower and flower._busy == true:
						return
					valid_flower_found = true
					_cur_flower = flower
					flower._busy = true
					set_home(flower.marker_2d.global_position)
					start_landing()
		FLIGHT_MODE.LANDING:
			_max_vel = 3 + 2 * bee_body.global_position.distance_to(_home_point)
			if _max_vel < 8:
				if bee_body.global_position.distance_to(_cur_hive.global_position) < 50:
					garrison(_cur_hive)
				else:
					land_and_stop()
		FLIGHT_MODE.GROUNDED:
			if jitter_timer.is_stopped() == false:
				jitter_timer.stop()
			if _bee_role == BEE_ROLE.FORAGER and _cur_flower != null:
				if _grounded_mode == GROUNDED_MODE.GATHERING:
					return
				_grounded_mode = GROUNDED_MODE.GATHERING
				gather_nectar()

func _on_jitter_timer_timeout():
	add_jitter()
	jitter_timer.wait_time = randf_range(JITTER_INTERVAL - JITTER_INTERVAL / 2, JITTER_INTERVAL + JITTER_INTERVAL / 2)
