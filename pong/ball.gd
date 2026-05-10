extends CharacterBody2D

enum SERVE {P1, P2}

@onready var ball_spawn: Marker2D = %BallSpawn
@onready var wall_l: StaticBody2D = %WallL
@onready var wall_r: StaticBody2D = %WallR


@export var initialSpeed := 500
@export var ball_speed_increment := 30
@export var serveAngle := 30

var speed := 0
var direction = Vector2.ZERO

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
		direction = Vector2.LEFT
	else:
		direction = Vector2.RIGHT
	
	# Reset our speed
	speed = initialSpeed
	
	# Choose random angle from a range using serve angle, (ex. -30, 30)
	var _serveAngle = randf_range(-serveAngle,serveAngle)
	# Set ball rotation
	rotation = deg_to_rad(_serveAngle)
	# Reset ball to our spawn location
	position = ball_spawn.position
	# Set our velocity for move_and_collide and rotate accordingly
	velocity = (direction * speed).rotated(rotation)

func _physics_process(delta: float) -> void:
	var col = move_and_collide(velocity * delta)
	
	if col:
		var obj = col.get_collider()
		if obj == wall_l:
			# P1 Side wall was hit
			leftWallHit()
		elif obj == wall_r:
			# P2 Side wall was hit
			rightWallHit()
		
		elif obj is Paddle:
			# If we hit a paddle, increase speed of the ball
			speed += ball_speed_increment
			
		# We can then bounce off of whatever we hit (either paddles, or top/bottom walls)
		direction = velocity.bounce(col.get_normal()).normalized()
		velocity = direction * speed

# Set serving side to opposite player, update score, and reset
func leftWallHit() -> void:
	serveSide = SERVE.P2
	game.emit_signal("P2Scored")
	resetBall()
func rightWallHit() -> void:
	serveSide = SERVE.P1
	game.emit_signal("P1Scored")
	resetBall()
