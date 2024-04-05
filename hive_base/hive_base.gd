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
@onready var marker_2d = $HiveBody/Marker2D

var _claimed_flowers: Array = []
var _selected: bool = false
var _is_ghost: bool = false
var _established: bool = false
var _garrisoned_bees: Array[bee_base] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_timer.set_wait_time(60.0 / bee_spawn_rate)
	dotted_circle.radius = hive_radius
	hive_range_circle.get_shape().radius = hive_radius
	if not _is_ghost:
		spawn_timer.start()
		await get_tree().create_timer(0.04).timeout 
		claim_flowers()
		await get_tree().create_timer( (60.0 / bee_spawn_rate) * population_cap + 0.1).timeout 
		allocate_foragers()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	label.text = "Flowers: %s\nBees: %s/%s" % [get_near_flowers().size(), get_origin_bees().size(), population_cap]

func claim_flowers() -> void:
	var near_flowers: Array = get_near_flowers()
	for flower in near_flowers:
		print("Near flower:\n%s" % str(flower))
		if flower._owner_hive == null:
			_claimed_flowers.append(flower)
			flower.claim_flower(self)
	print("New Hive\nClaimed Flowers:\n%s" % str(_claimed_flowers))

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

func get_cur_drones() -> Array[bee_base]:
	return get_cur_bees().filter(func(bee): return bee._bee_role == bee.BEE_ROLE.DRONE)
	

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

func get_near_flowers() -> Array:
	var flowers_list = hive_range.get_overlapping_areas()
	return flowers_list

func allocate_foragers() -> void:
	var current_bees: Array[bee_base] = get_cur_drones()
	for flower in _claimed_flowers:
		var forager_bee = current_bees.pop_front()
		if forager_bee:
			forager_bee._bee_role = forager_bee.BEE_ROLE.FORAGER
			forager_bee.start_flying()
		

func _on_spawn_timer_timeout():
	if get_origin_bees().size() < 1:
		BeeManager.make_new_hive_bee(self, bee_base.BEE_ROLE.QUEEN)
	elif get_origin_bees().size() < 4:
		BeeManager.make_new_hive_bee(self, bee_base.BEE_ROLE.WORKER)
	elif get_origin_bees().size() < population_cap:
		BeeManager.make_new_hive_bee(self, bee_base.BEE_ROLE.DRONE)

func _on_hive_body_input_event(viewport, event, shape_idx):
	if _is_ghost:
		return
	if event.is_action_pressed("MouseClick") == true:
		SignalManager.on_hive_click.emit(self)


func _on_hive_body_mouse_entered():
	for flower in _claimed_flowers:
		flower.set_outline(1)
	label.show()
	dotted_circle.show()


func _on_hive_body_mouse_exited():
	for flower in _claimed_flowers:
		flower.set_outline(0)
	label.hide()
	dotted_circle.hide()
