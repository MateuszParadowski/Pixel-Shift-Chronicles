extends CharacterBody2D

@export var walk_speed: float = 150
@export var run_speed: float = 250
@export var jump_velocity: float = -850
@export var gravity: float = 900
@export var max_health: int = 100
@export var max_hits: int = 6

@onready var anim = $AnimatedSprite2D
@onready var PociskScene = preload("res://Pocisk.tscn")
@onready var attack_detector = $AttackDetector

var health: int = max_health
var hit_counter: int = 0
var on_ladder: bool = false
var is_shooting: bool = false
var has_gun: bool = false
var crouching: bool = false
var facing_right: bool = true
var aim_direction := Vector2.RIGHT
var is_aiming: bool = false
var dead := false

func _physics_process(delta: float) -> void:
	if dead:
		return

	is_aiming = has_gun and Input.is_action_pressed("aim")
	var direction = 0.0

	if Input.is_action_pressed("move_right"):
		direction += 1
	elif Input.is_action_pressed("move_left"):
		direction -= 1

	if is_aiming:
		facing_right = aim_direction.x >= 0
	else:
		if direction > 0:
			facing_right = true
		elif direction < 0:
			facing_right = false

	anim.flip_h = not facing_right

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

	# Celowanie myszką lub padem
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		var mouse_pos = get_global_mouse_position()
		aim_direction = (mouse_pos - global_position).normalized()
	else:
		var joy_dir = Vector2(
			Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
			Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
		)
		if joy_dir.length() > 0.1:
			aim_direction = joy_dir.normalized()

	move_and_slide()

	if not is_on_floor():
		attack_from_air()

	update_animation(direction)

func update_animation(direction: float):
	if on_ladder:
		if Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
			anim.play("climb")
		return

	if crouching:
		anim.play("crouch")
		return

	if not is_on_floor():
		anim.play("jump_gun" if has_gun else "jump")
		return

	if has_gun:
		if is_aiming:
			var aim_name = get_aim_anim_name()
			if is_shooting:
				anim.play("shoot_" + aim_name)
			else:
				anim.play("aim_" + aim_name)
		else:
			if direction == 0:
				anim.play("idle_gun")
			elif Input.is_action_pressed("run"):
				anim.play("run_gun")
			else:
				anim.play("walk_gun")
	else:
		if direction == 0:
			anim.play("idle")
		elif Input.is_action_pressed("run"):
			anim.play("run")
		else:
			anim.play("walk")

func get_aim_anim_name() -> String:
	if aim_direction.y < -0.5:
		return "upleftright" if aim_direction.x < 0 else "up"
	elif aim_direction.y > 0.5:
		return "downleftright" if aim_direction.x < 0 else "down"
	else:
		return "left" if aim_direction.x < 0 else "forward"

func strzel_pociskiem():
	var pocisk = PociskScene.instantiate()
	pocisk.global_position = global_position + aim_direction * 10
	pocisk.direction = aim_direction
	get_tree().current_scene.add_child(pocisk)

func attack_from_air():
	for body in attack_detector.get_overlapping_bodies():
		if body != self and body.has_method("take_damage"):
			body.take_damage(true)

func take_damage(amount: int):
	if dead:
		return

	health -= amount
	hit_counter += 1
	anim.play("hurt")

	if has_gun:
		has_gun = false
		var dropped = preload("res://GunPickup.tscn").instantiate()
		dropped.global_position = global_position
		get_tree().current_scene.add_child(dropped)

	if health <= 0 or hit_counter >= max_hits:
		die()

func heal(amount: int):
	health = min(health + amount, max_health)

func die():
	dead = true
	anim.play("die")
	await anim.animation_finished
	get_tree().reload_current_scene()

# --- DRABINA I BROŃ ---

func _on_ladder_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("drabina"):
		on_ladder = true
	elif area.is_in_group("pickup_gun"):
		has_gun = true
		area.call_deferred("queue_free")

func _on_ladder_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("drabina"):
		on_ladder = false
