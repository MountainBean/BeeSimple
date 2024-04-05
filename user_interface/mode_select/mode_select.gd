extends Control

@onready var label = $MarginContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_mode_select.connect(on_mode_select)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_mode_select(_cm_last_frame: GameManager.CURSOR_MODE) -> void:
	label.text = GameManager.CURSOR_MODE.keys()[GameManager._cm]
