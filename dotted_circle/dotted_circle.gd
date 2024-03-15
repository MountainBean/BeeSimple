@tool
extends Node2D

@export var radius: float = 200

var seg_len: int = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _draw():
	var drawn_segments: float = ( PI * 2 * radius ) / seg_len
	var seg_angle: float = 360 / ( 2 * drawn_segments )
	for i in range(0, ceili(drawn_segments)):
		draw_arc(
			self.position, 
			radius, 
			deg_to_rad((2 * i) * seg_angle), 
			deg_to_rad( ( ( 2 * i ) + 1 ) * seg_angle), 
			5, 
			Color("ffffff94"), 
			4
		)
