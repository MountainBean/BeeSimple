extends Area2D

class_name hive_base

@export var bee_spawn_rate: float = 240
@export var population_cap: int = 8

@onready var spawn_timer = $SpawnTimer
@onready var bees = $Bees
@onready var sprite_2d = $Sprite2D
@onready var collision_shape_2d = $CollisionShape2D

var _selected: bool = false

var BEE_BASE: PackedScene = load("res://bee_base/bee_base.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_timer.set_wait_time(60.0 / bee_spawn_rate)
	spawn_timer.start()
	#new_hive_bee()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _get_class_name() -> String:
	return "hive_base"

func new_hive_bee() -> void:
	var bee = BEE_BASE.instantiate()
	bee.set_origin_hive(self)
	bee.set_cur_hive(self)
	bees.add_child(bee)

func get_bees() -> Array[bee_base]:
	var bee_list: Array[bee_base] = []
	for node in bees.get_children():
		if node._get_class_name() == "bee_base":
			bee_list.append(node)
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
	var all_bees: Array[bee_base] = get_bees()
	var grab: int = floori(all_bees.size() * percent)
	bee_list.append_array(all_bees.slice(0, grab))
	SignalManager.on_bees_grabbed.emit(bee_list)

func _on_spawn_timer_timeout():
	if bees.get_children().size() < population_cap:
		new_hive_bee()

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("MouseClick") == true:
		SignalManager.on_hive_click.emit(self)

