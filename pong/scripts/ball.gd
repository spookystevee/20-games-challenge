extends CharacterBody2D

enum SERVE {P1, P2}

@onready var ball_spawn: Marker2D = %BallSpawn
@onready var wall_l: StaticBody2D = %WallL
@onready var wall_r: StaticBody2D = %WallR

@export var initialSpeed := 500
@export var ball_speed_increment := 30
@export var maxSpeed := 2000
@export var serveAngle := 30
@export var maxPaddleBounceAngle := 50

var speed := 0

var serveSide := SERVE.P1

var game: Game

func _ready() -> void:
	game = get_parent()
	resetBall()

func _input(event) -> void:
	if event.is_action_pressed("debug_respawn"):
		resetBall()

func resetBall() -> void:
	# Determine side to serve to
	if serveSide == SERVE.P1:
		velocity = Vector2.LEFT
	else:
		velocity = Vector2.RIGHT
	
	# Reset our speed
	speed = initialSpeed
	
	# Choose random angle from a range using serve angle, (ex. -30, 30)
	var _serveAngle = randf_range(-serveAngle,serveAngle)
	# Set ball rotation
	rotation = deg_to_rad(_serveAngle)
	# Reset ball to our spawn location
	position = ball_spawn.position
	# Set our velocity for move_and_collide and rotate accordingly
	velocity = (velocity * speed).rotated(rotation)

func _physics_process(delta: float) -> void:
	var col = move_and_collide(velocity * delta)
	
	if col:
		var obj := col.get_collider()
		if obj == wall_l:
			# P1 Side wall was hit
			leftWallHit()
		elif obj == wall_r:
			# P2 Side wall was hit
			rightWallHit()
		elif obj is Paddle:
			# Paddle was hit
			paddleBounce(obj)
		else:
			# Regular bounce for everything else
			velocity = velocity.bounce(col.get_normal()).normalized() * speed

func paddleBounce(paddle: Paddle) -> void:
	
	# Get height of collider to get paddle height
	var paddleHeight = paddle.get_node("CollisionShape2D").shape.size.y
	
	# find the location of the ball localized to the paddle, where the bottom is -halfHeight and the top is halfHeight
	var relativeIntersectY =  (paddle.global_position.y - global_position.y)
	# normalize our relative intersection between -1 and 1
	var normalized = clamp(relativeIntersectY / (paddleHeight / 2), -1.0, 1.0)
	# calculate the angle which to bounce at (in rad)
	var bounceAngle = normalized * deg_to_rad(maxPaddleBounceAngle)
	
	# Bounce in opposite direction on the X
	var dirX = -signf(velocity.x)
	
	# Increase speed of the ball before doing the bounce, clamped to maxSpeed
	speed = mini(speed + ball_speed_increment, maxSpeed)
	# set velocity by assigning x direction and rotating by bounceAngle
	velocity = (Vector2.RIGHT * dirX).rotated(bounceAngle) * speed

# Set serving side to opposite player, update score, and reset ball to center
func leftWallHit() -> void:
	serveSide = SERVE.P2
	game.emit_signal("P2Scored")
	resetBall()
func rightWallHit() -> void:
	serveSide = SERVE.P1
	game.emit_signal("P1Scored")
	resetBall()
