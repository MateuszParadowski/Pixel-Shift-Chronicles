extends StaticBody2D

@onready var area := $Area2D
@onready var timer_hide := Timer.new()
@onready var timer_show := Timer.new()
@onready var collision := $CollisionShape2D

func _ready():
	# Timer do ukrywania (1 sekunda po wejściu)
	add_child(timer_hide)
	timer_hide.wait_time = 1.0
	timer_hide.one_shot = true
	timer_hide.timeout.connect(_on_hide_platform)

	# Timer do pokazania (3 sekundy po zniknięciu)
	add_child(timer_show)
	timer_show.wait_time = 3.0
	timer_show.one_shot = true
	timer_show.timeout.connect(_on_show_platform)

	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Gracz" or body.is_in_group("player"):
		timer_hide.start()

func _on_hide_platform():
	visible = false
	collision.disabled = true
	area.monitoring = false
	timer_show.start()

func _on_show_platform():
	visible = true
	collision.disabled = false
	area.monitoring = true
