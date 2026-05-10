class_name Paddle
extends CharacterBody2D

enum PLAYER {P1, P2}

const SPEED := 500

@export var player := PLAYER.P1

var upControl := "P1Up"
var downControl := "P1Down"
var direction := Vector2.ZERO

func _ready() -> void:
	initControls()

func initControls() -> void:
	if player == PLAYER.P1:
		upControl = "P1Up"
		downControl = "P1Down"
	else:
		upControl = "P2Up"
		downControl = "P2Down"

func paddleUp() -> void:
	direction = Vector2.UP

func paddleDown() -> void:
	direction = Vector2.DOWN

func _physics_process(delta: float) -> void:
	direction = Vector2.ZERO
	
	if Input.is_action_pressed(upControl):
		direction = Vector2.UP
	if Input.is_action_pressed(downControl):
		direction = Vector2.DOWN
	
	velocity = direction * SPEED
	move_and_collide(velocity * delta)
