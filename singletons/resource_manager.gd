extends Node

var _flowers_list: Dictionary = {}


func claim_flower(hive: hive_base, flower: Area2D) -> void:
	print("add %s: %s to _flowers_list" % [str(flower.get_instance_id()), str(hive.get_instance_id())])
	_flowers_list[str(flower.get_instance_id())] = hive.get_instance_id()
