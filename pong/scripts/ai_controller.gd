class_name AIController
extends PaddleController

# how far the ai is willing to be away from the ball before it is close enough
var deadzone := 75.0

@onready var ball: Ball = get_tree().get_first_node_in_group("ball")


func _process(_delta: float) -> void:
	AIbrain()

func AIbrain() -> void:
	if ball == null:
		return
	
	# Calculate the difference between the paddle and the ball
	var diff = ball.global_position.y - paddle.global_position.y
	# Randomly get a deadzone where the paddle will stop trying to follow the ball
	# this lets the bot play a bit more unpredictably, and can make mistakes
	deadzone = randf_range(25.0, 150.0)
	
	# If the ball is within the deadzone, stop moving
	if abs(diff) < deadzone:
		# Random 1/3 chance to actually stop moving
		if randi_range(0,2) == 1:
			paddle.direction = 0
	elif ball.velocity.x > 0:
		# If the ball is moving towards the right, move up/down towards it
		paddle.direction = sign(diff)
	else:
		paddle.direction = 0
