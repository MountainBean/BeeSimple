extends Control

@onready var label = $MC/Label

var _hive_id: String = "0000"
var _claimed_flowers: String = "00"
var _garrisoned_bees: String = "00"

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_hive_click.connect(on_hive_click)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_hive_click(hive: hive_base) -> void:
	_hive_id = str(hive.get_instance_id())
	_claimed_flowers = str(hive._claimed_flowers.size())
	_garrisoned_bees = str(hive._garrisoned_bees.size())
	update_label()

func update_label() -> void:
	label.text = "Hive ID: %s\nClaimed Flowers: %s\nGarrisoned Bees: %s" % [_hive_id, _claimed_flowers, _garrisoned_bees]

