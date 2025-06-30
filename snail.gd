extends CharacterBody2D

@export var speed := 30
@onready var anim = $AnimatedSprite2D
@onready var ground_check: RayCast2D = $GroundCheck
@onready var hitbox: Area2D = $Hitbox

var direction := Vector2.LEFT
var hit_count := 0
var hiding := false

func _physics_process(_delta):
	if hiding:
		return

	if not ground_check.is_colliding():
		_turn_around()

	velocity.x = speed * direction.x
	move_and_slide()

func _turn_around():
	direction *= -1
	anim.flip_h = direction.x > 0
	ground_check.position.x = abs(ground_check.position.x) * direction.x

func take_damage(from_jump: bool = false):
	if hiding:
		return

	if from_jump:
		hit_count += 1
		if hit_count >= 2:
			die()
		else:
			_hide()
	else:
		die()

func _hide():
	hiding = true
	anim.play("hit")
	await get_tree().create_timer(5.0).timeout
	hiding = false
	hit_count = 0
	anim.play("walk")

func die():
	queue_free()
