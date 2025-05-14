extends CharacterBody2D

@export var speed: float = 200
@export var jump_velocity: float = -400
@export var gravity: float = 900
@export var health: int = 100
@export var max_health: int = 100

@onready var anim = $AnimatedSprite2D
@onready var PociskScene = preload("res://Pocisk.tscn")

var on_ladder: bool = false
var is_shooting: bool = false

func _physics_process(delta: float) -> void:
	var direction = 0.0

	# Lewo / prawo
	if Input.is_action_pressed("move_right"):
		direction += 1
		$AnimatedSprite2D.flip_h = false
	elif Input.is_action_pressed("move_left"):
		direction -= 1
		$AnimatedSprite2D.flip_h = true

	velocity.x = direction * speed

	# Wspinanie się
	if on_ladder:
		velocity.y = 0

		if Input.is_action_pressed("move_up"):
			velocity.y = -speed
		elif Input.is_action_pressed("move_down"):
			velocity.y = speed

		if direction != 0 or velocity.y != 0:
			anim.play("climb")
		else:
			anim.play("idle")
	else:
		# Grawitacja i skok
		if not is_on_floor():
			velocity.y += gravity * delta
			anim.play("jump")
		else:
			if Input.is_action_just_pressed("jump"):
				velocity.y = jump_velocity
				$SFX_Jump.play()
			if direction != 0:
				anim.play("run")
			else:
				anim.play("idle")

	# Strzelanie
	if Input.is_action_just_pressed("shoot"):
		strzel_pociskiem()
		$SFX_Shoot.play()
		anim.play("shoot")

	move_and_slide()

func strzel_pociskiem():
	var pocisk = PociskScene.instantiate()
	pocisk.global_position = global_position
	get_tree().current_scene.add_child(pocisk)

# Wspinanie
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("drabina"):
		on_ladder = true

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("drabina"):
		on_ladder = false

# Obrażenia
func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func heal(amount: int):
	health = min(health + amount, max_health)

func die():
	queue_free()  # Tu możesz zrobić Game Over
