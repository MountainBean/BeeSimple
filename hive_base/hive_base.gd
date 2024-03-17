extends Node2D

class_name hive_base

@export var bee_spawn_rate: float = 240
@export var population_cap: int = 8
@export var hive_radius: int = 200

@onready var spawn_timer = $HiveBody/SpawnTimer
@onready var sprite_2d = $HiveBody/Sprite2D
@onready var body_collision = $HiveBody/BodyCollision
@onready var dotted_circle = $DottedCircle
@onready var hive_range = $HiveRange
@onready var hive_range_circle = $HiveRange/HiveRangeCircle
@onready var label = $Label

var _selected: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_timer.set_wait_time(60.0 / bee_spawn_rate)
	dotted_circle.radius = hive_radius
	hive_range_circle.get_shape().radius = hive_radius


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	population_cap = count_near_flowers() * 1
	label.text = "Flowers: %s\nBees: %s/%s" % [count_near_flowers(), get_origin_bees().size(), population_cap]

func _get_class_name() -> String:
	return "hive_base"

func get_origin_bees() -> Array[bee_base]:
	var bee_list: Array[bee_base] = []
	for bee in BeeManager._bees:
		if bee.get_origin_hive() == self:
			bee_list.append(bee)
	return bee_list

func get_cur_bees() -> Array[bee_base]:
	var bee_list: Array[bee_base] = []
	for bee in BeeManager._bees:
		if bee.get_cur_hive() == self:
			bee_list.append(bee)
	return bee_list

func on_select() -> void:
	sprite_2d.self_modulate = Color("d079ff")
	_selected = true

func on_deselect() -> void:
	sprite_2d.self_modulate = Color("ffffff")
	_selected = false

func select_child_bees(percent: float) -> void:
	assert(percent >= 0, "Percent must be expressed as a float value between 0 and 1")
	assert(percent <= 1.0, "Percent must be expressed as a float value between 0 and 1")
	var bee_list: Array[bee_base] = []
	var all_bees: Array[bee_base] = get_cur_bees()
	var grab: int = floori(all_bees.size() * percent)
	bee_list.append_array(all_bees.slice(0, grab))
	SignalManager.on_bees_grabbed.emit(bee_list)

func count_near_flowers() -> int:
	var flowers_list = hive_range.get_overlapping_areas()
	return flowers_list.size()

func _on_spawn_timer_timeout():
	if get_origin_bees().size() < population_cap:
		BeeManager.make_new_hive_bee(self)

func _on_hive_body_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("MouseClick") == true:
		SignalManager.on_hive_click.emit(self)


func _on_hive_body_mouse_entered():
	label.show()
	dotted_circle.show()


func _on_hive_body_mouse_exited():
	label.hide()
	dotted_circle.hide()
