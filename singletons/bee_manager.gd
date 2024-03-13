extends Node

const BEE_BASE = preload("res://bee_base/bee_base.tscn")

var _bees: Array[bee_base] = []

func add_child_deferred(child_to_add) -> void:
	get_node("/root/GameScene/Bees").add_child(child_to_add)

func call_add_child(child_to_add) -> void:
	call_deferred("add_child_deferred", child_to_add)

func make_new_hive_bee(hive: hive_base) -> void:
	var bee = BEE_BASE.instantiate()
	bee.global_position = hive.position
	bee.set_origin_hive(hive)
	bee.set_cur_hive(hive)
	print("hive position = x: %.1f, y: %.1f" % [hive.position.x, hive.position.y])
	bee.set_home(hive.position)
	print("bee home = x: %.1f, y: %.1f" % [bee._home_point.x, bee._home_point.y])
	_bees.append(bee)
	call_add_child(bee)
