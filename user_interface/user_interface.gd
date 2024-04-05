extends Control

@onready var bee_hud = $BeeHud
@onready var hive_stats = $HiveStats


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_bees_grabbed.connect(on_bees_grabbed)
	SignalManager.on_deselect_all.connect(on_deselect_all)
	SignalManager.on_hive_click.connect(on_hive_click)

func on_hive_click(_hive: hive_base) -> void:
	hive_stats.show()

func on_bees_grabbed(_bee_list: Array[bee_base]) -> void:
	bee_hud.show()

func on_deselect_all() -> void:
	bee_hud.hide()
	hive_stats.hide()
