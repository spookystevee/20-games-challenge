class_name PaddleController
extends Node

var paddle : Paddle

func _ready() -> void:
	_set_paddle()

func _set_paddle() -> void:
	if get_parent() is Paddle:
		paddle = get_parent()

func set_active(active: bool) -> void:
	set_process(active)
	set_physics_process(active)
	
	if not active and paddle:
		paddle.direction = 0.0
