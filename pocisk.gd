extends Area2D

@export var speed: float = 500
var direction: Vector2 = Vector2.RIGHT  # domyślny kierunek

func _ready():
	# Opcjonalnie: obracaj sprite w stronę ruchu
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		position += direction.normalized() * speed * delta

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(false)  # false = z broni
	queue_free()
