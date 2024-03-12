extends Node2D

class_name hive_base

@export var bee_spawn_rate: float = 240
@export var population_cap: int = 8

@onready var spawn_timer = $SpawnTimer
@onready var bees = $Bees

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

func _on_spawn_timer_timeout():
	new_hive_bee()
