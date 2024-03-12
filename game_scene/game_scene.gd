extends Node2D

@onready var hives = $Hives


const HIVE_BASE = preload("res://hive_base/hive_base.tscn")

var select_box: Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.set_cursor_mode(GameManager.CURSOR_MODE.SELECT)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	calculate_cursor_mode()
	
	match GameManager.get_cursor_mode():
		GameManager.CURSOR_MODE.BUILD:
			if Input.is_action_just_pressed("MouseClick"):
				hive_at_mouse(get_viewport().get_mouse_position())
		GameManager.CURSOR_MODE.SELECT:
			if Input.is_action_pressed("MouseClick"):
				var bee_list: Array
				for hive in hives.get_children(true):
					for bee in hive.get_bees():
						bee.set_home(get_viewport().get_mouse_position())
	
	if Input.is_action_just_pressed("SendHome"):
		for hive in hives.get_children(true):
			for bee in hive.get_bees():
				bee.set_home(bee.get_hive().global_position)


func hive_at_mouse(pos: Vector2) -> void:
	var hive = HIVE_BASE.instantiate()
	hive.global_position = pos
	hives.add_child(hive)

func calculate_cursor_mode() -> void:
	if Input.is_action_just_pressed("BuildMode") == true:
		GameManager.set_cursor_mode(GameManager.CURSOR_MODE.BUILD)
	if Input.is_action_just_pressed("SelectMode") == true:
		GameManager.set_cursor_mode(GameManager.CURSOR_MODE.SELECT)
