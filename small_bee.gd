extends CharacterBody2D

@export var speed: float = 100
@export var damage: int = 20
@export var detection_range: float = 200
@export var attack_cooldown: float = 1.5

@onready var anim = $AnimatedSprite2D
@onready var detection_area = $DetectionArea

var player: Node2D = null
var can_attack := true
var direction := Vector2.LEFT

func _ready():
	anim.play("fly")
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)

func _physics_process(delta: float) -> void:
	if player:
		var to_player = (player.global_position - global_position).normalized()
		velocity = to_player * speed
	else:
		# Patrol, np. lewo-prawo
		velocity.x = direction.x * speed
		if not is_on_floor():
			velocity.y += 300 * delta  # grawitacja jeśli potrzebna

	move_and_slide()

func _on_player_entered(body: Node2D) -> void:
	if body.name == "Gracz":
		player = body
		attack_player()

func _on_player_exited(body: Node2D) -> void:
	if body == player:
		player = null

func attack_player():
	if not can_attack or player == null:
		return

	if player.has_method("take_damage"):
		player.call_deferred("take_damage", damage)

	can_attack = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
