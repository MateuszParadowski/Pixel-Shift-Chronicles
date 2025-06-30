extends CharacterBody2D

@export var speed := 60
@export var charge_speed := 200
@export var charge_cooldown := 3.0
@onready var anim = $AnimatedSprite2D
@onready var hitbox = $Hitbox
@onready var hurtbox = $Hurtbox

var direction := -1
var can_charge := true
var is_charging := false
var target: Node2D = null
var hp := 10

func _ready():
	anim.play("walk")

func _physics_process(_delta):
	if is_charging and target:
		var dir = (target.global_position - global_position).normalized()
		velocity = dir * charge_speed
	else:
		velocity = Vector2.LEFT * speed * direction
	move_and_slide()

func _on_Hurtbox_body_entered(body):
	if body.name == "Gracz":
		body.take_damage()

func _on_Hitbox_area_entered(area):
	if area.name == "attack_detector":
		hp -= 1
	elif area.is_in_group("projectile"):
		hp -= 1
		area.call_deferred("queue_free")
	
	if hp <= 0:
		queue_free()

func start_charge_at(player):
	if can_charge:
		is_charging = true
		target = player
		anim.play("run")
		can_charge = false
		await get_tree().create_timer(1.5).timeout
		is_charging = false
		anim.play("walk")
		await get_tree().create_timer(charge_cooldown).timeout
		can_charge = true
