extends Node2D

func _ready():
	$Timer.timeout.connect(_on_Timer_timeout)

func _on_Timer_timeout():
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _input(event):
	if event.is_action_pressed("ui_accept") or event is InputEventMouseButton:
		get_tree().change_scene_to_file("res://main_menu.tscn")
