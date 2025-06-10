extends CharacterBody2D

@export var walk_speed: float = 150
@export var run_speed: float = 250
@export var jump_velocity: float = -400
@export var gravity: float = 900
@export var health: int = 100
@export var max_health: int = 100

@onready var anim = $AnimatedSprite2D
@onready var PociskScene = preload("res://Pocisk.tscn")

var on_ladder: bool = false
var is_shooting: bool = false
var has_gun: bool = false
var crouching: bool = false
var facing_right: bool = true
var aim_direction := Vector2.RIGHT

func _physics_process(delta: float) -> void:
	var direction = 0.0

	if Input.is_action_pressed("move_right"):
		direction += 1
	elif Input.is_action_pressed("move_left"):
		direction -= 1

	if direction > 0:
		facing_right = true
	elif direction < 0:
		facing_right = false

	$AnimatedSprite2D.flip_h = not facing_right

	var speed = run_speed if Input.is_action_pressed("run") else walk_speed
	crouching = Input.is_action_pressed("crouch")

	velocity.x = direction * (speed * 0.4 if crouching else speed)

	if on_ladder:
		velocity.y = 0
		if Input.is_action_pressed("move_up"):
			velocity.y = -speed
		elif Input.is_action_pressed("move_down"):
			velocity.y = speed
	else:
		if not is_on_floor():
			velocity.y += gravity * delta
		elif Input.is_action_just_pressed("jump") and not crouching:
			velocity.y = jump_velocity

	if has_gun and Input.is_action_just_pressed("shoot"):
		strzel_pociskiem()
		is_shooting = true
	else:
		is_shooting = false

	var mouse_pos = get_global_mouse_position()
	aim_direction = (mouse_pos - global_position).normalized()

	update_animation(direction)
	move_and_slide()

func update_animation(direction: float):
	if crouching:
		anim.play("croutch")
		return

	if not is_on_floor():
		anim.play("jump_gun" if has_gun else "jump")
		return

	if on_ladder:
		anim.play("climb")
		return

	if is_shooting:
		anim.play("shoot")
		return

	if has_gun:
		match get_aim_anim_name():
			"up":
				anim.play("aim_up")
			"upleftright":
				anim.play("aim_upleftright")
			"down":
				anim.play("aim_down")
			"downleftright":
				anim.play("aim_downleftright")
			"forward":
				anim.play("run_gun" if direction != 0 else "idle_gun")
	else:
		anim.play("run" if direction != 0 else "idle")

func get_aim_anim_name() -> String:
	if aim_direction.y < -0.5:
		return "upleftright" if abs(aim_direction.x) > 0.5 else "up"
	elif aim_direction.y > 0.5:
		return "downleftright" if abs(aim_direction.x) > 0.5 else "down"
	else:
		return "forward"

func strzel_pociskiem():
	var pocisk = PociskScene.instantiate()
	pocisk.global_position = global_position
	pocisk.direction = aim_direction
	get_tree().current_scene.add_child(pocisk)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("drabina"):
		on_ladder = true
	if area.is_in_group("pickup_gun"):
		has_gun = true
		area.queue_free()

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("drabina"):
		on_ladder = false

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()
	else:
		anim.play("hurt")
		if has_gun:
			has_gun = false

func heal(amount: int):
	health = min(health + amount, max_health)

func die():
	queue_free()
