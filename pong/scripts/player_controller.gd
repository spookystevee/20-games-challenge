class_name PlayerController
extends PaddleController

@export var upControl := "P1Up"
@export var downControl := "P1Down"

func _process(_delta: float) -> void:
	paddle.direction = Input.get_axis(upControl, downControl)
