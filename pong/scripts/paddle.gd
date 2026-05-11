class_name Paddle
extends AnimatableBody2D

const SPEED := 650

var direction := 0.0

func _physics_process(delta: float) -> void:
	move_and_collide(Vector2(0, direction) * SPEED * delta)
