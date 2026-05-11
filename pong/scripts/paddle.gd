class_name Paddle
extends AnimatableBody2D

enum PLAYER {P1, P2, AI}

const SPEED := 650

@export var player := PLAYER.P1
@onready var ball: CharacterBody2D = %Ball

var upControl := "P1Up"
var downControl := "P1Down"
var direction := Vector2.ZERO

var aiDeadzone := 75.0

func _ready() -> void:
	initControls()

func initControls() -> void:
	if player == PLAYER.P1:
		upControl = "P1Up"
		downControl = "P1Down"
	elif player == PLAYER.P2:
		upControl = "P2Up"
		downControl = "P2Down"
	elif player == PLAYER.AI:
		upControl = ""
		downControl = ""
		aiDeadzone = randf_range(50.0, 100.0)
		

func paddleUp() -> void:
	direction = Vector2.UP

func paddleDown() -> void:
	direction = Vector2.DOWN

func AIBrain() -> void:
	# Calculate the difference between the paddle and the ball
	var diff = ball.global_position.y - global_position.y
	# Randomly get a deadzone where the paddle will stop trying to follow the ball
	# this lets the bot play a bit more unpredictably, and can make mistakes
	aiDeadzone = randf_range(25.0, 150.0)
	
	# If the ball is within the deadzone, stop moving
	if abs(diff) < aiDeadzone:
		# Random 1/3 chance to actually stop moving
		if randi_range(0,2) == 1:
			direction = Vector2.ZERO
	elif ball.velocity.x > 0:
		# If the ball is moving towards the right, move up/down towards it
		direction.y = sign(diff)
	else:
		direction = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if player == PLAYER.AI:
		# Run AI calculations if player is a bot
		# this logic should eventually be moved into its own class
		AIBrain()
	else:
		direction = Vector2.ZERO
		if Input.is_action_pressed(upControl):
			direction = Vector2.UP
		if Input.is_action_pressed(downControl):
			direction = Vector2.DOWN
	
	move_and_collide(direction * SPEED * delta)
