extends StaticBody2D

@export var move_distance: float = 100.0
@export var move_speed: float = 50.0

var direction := 1
var start_position := Vector2.ZERO

func _ready():
	start_position = position

func _process(delta):
	position.x += move_speed * delta * direction

	if abs(position.x - start_position.x) >= move_distance:
		direction *= -1
