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

func new_hive_bee() -> void:
	if bees.get_children().size() < population_cap:
		var bee = BEE_BASE.instantiate()
		bee.set_hive(self)
		bees.add_child(bee)

func get_bees() -> Array:
	return bees.get_children()

func selected() -> void:
	sprite_2d.self_modulate = Color("d079ff")
	_selected = true
	
func deselect() -> void:
	sprite_2d.self_modulate = Color("ffffff")
	_selected = false

func _on_spawn_timer_timeout():
	new_hive_bee()

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("MouseClick") == true:
		SignalManager.on_hive_select.emit(self)

