extends StaticBody2D

@export var move_distance: float = 100.0
@export var move_speed: float = 50.0

var direction := 1
var activated := false
var start_position := Vector2.ZERO

@onready var area := $Area2D

func _ready():
	start_position = position
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Gracz":
		activated = true

func _process(delta):
	if not activated:
		return

	position.x += move_speed * delta * direction

	if abs(position.x - start_position.x) >= move_distance:
		direction *= -1
