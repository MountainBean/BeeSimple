extends Area2D


var _nearby_hives: Array[hive_base] = []
var _busy: bool = false
var _owner_hive: hive_base
@onready var marker_2d = $Marker2D
@onready var sprite_2d = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_outline(w: float) -> void:
	sprite_2d.material.set_shader_parameter("width", w)

func claim_flower(owner_hive: hive_base) -> void:
	_owner_hive = owner_hive
