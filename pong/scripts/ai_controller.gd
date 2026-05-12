class_name AIController
extends PaddleController

#determine what side of the board we're on
@onready var myside := 1 if paddle.global_position.x <  float(get_window().size.x) / 2 else 2

# possible positions on the paddle
enum PADDLEPOSITIONS {
	TOP,
	MIDDLE,
	BOTTOM
}

@onready var paddleHeight = paddle.get_node("CollisionShape2D").shape.size.y
# values for calculating the distance from each section of the paddle
@onready var paddle_locations = {
	PADDLEPOSITIONS.TOP: (-paddleHeight/2) + 15,
	PADDLEPOSITIONS.MIDDLE: 0,
	PADDLEPOSITIONS.BOTTOM: (paddleHeight/2) - 15
}

@onready var desiredHitLocation = PADDLEPOSITIONS.TOP

# how far the ai is willing to be away from the ball before it is close enough
var deadzone := 75.0
var last_hit := false

### x = lowend scaling, y = highend scaling, controls how close the AI will get the ball to its desiered position. Higher = dumber
@export var deadzoneScaling := Vector2(.25, .5)

@onready var ball: Ball = get_tree().get_first_node_in_group("ball")

func _ready() -> void:
	ball.paddle_hit.connect(_on_paddle_hit)
	ball.ball_reset.connect(_on_reset)
	ball.ball_serve.connect(_on_serve)
	

func _physics_process(_delta: float) -> void:
	AIbrain()

func AIbrain() -> void:
	if ball == null:
		return
	
	var diff: float = ball.global_position.y - paddle.global_position.y + paddle_locations[desiredHitLocation]
	
	# If the distance is within this range, we start braking.
	var brake_margin = 10
	
	if abs(diff) < deadzone:
		# if in deadzone, stop completely
		paddle.direction = 0
	elif not last_hit:
		# this makes the paddle slow down as it reaches the deadzone edge so hopefully we get less jitter movement
		# this does make it so the AI paddle uses a different speed than the player can technically
		# but probably worth the sacrifice tbh
		var smooth_dir = clamp(diff / brake_margin, -1.0, 1.0)
		paddle.direction = smooth_dir
	else:
		paddle.direction = 0

func _on_paddle_hit(pad: Paddle, _angle: int):
	if pad != paddle:
		last_hit = false
		calculate_hit_variance()
	else:
		last_hit = true

func calculate_hit_variance() -> void:
	# decide where on the paddle we want to hit
	desiredHitLocation = PADDLEPOSITIONS.values().pick_random()
	# Randomly get a deadzone where the paddle will stop trying to follow the ball
	# the bot will become more inaccurate as it continues its combo
	# this lets the bot play a bit more unpredictably, and can make mistakes
	var lowend = 10 * ((paddle.currentCombo + 1) * deadzoneScaling.x)
	var highend = 10 * ((paddle.currentCombo + 1) * deadzoneScaling.y)
	deadzone = randf_range(lowend, highend)

func _on_reset(side: int):
	if side == myside:
		last_hit = false
	else:
		last_hit = true

func _on_serve():
	calculate_hit_variance()
