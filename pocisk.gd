extends Area2D

@export var speed: float = 400

func _physics_process(delta: float) -> void:
	position.x += speed * delta
