class_name Ball
extends CharacterBody2D

# object references
@onready var serve_timer: Timer = %ServeTimer
@onready var reset_timer: Timer = %ResetTimer
@onready var ball_spawn: Marker2D = %BallSpawn
@onready var wall_l: StaticBody2D = %WallL
@onready var wall_r: StaticBody2D = %WallR
@onready var col_shape: CollisionShape2D = $CollisionShape2D
#visuals
@onready var score_sprite: AnimatedSprite2D = $Particles/ScoreSprite
@onready var bounce_particles: CPUParticles2D = $Particles/bounceParticles
@onready var score_particles: CPUParticles2D = $Particles/ScoreParticles
@onready var ball_visual: AnimatedSprite2D = $BallVisual
#sound
@onready var bounce_sound: AudioStreamPlayer2D = $BounceSound


# customizable variables
@export var initialSpeed := 500
@export var ball_speed_increment := 30
@export var maxSpeed := 2000
@export var serveAngle := 30
@export var maxPaddleBounceAngle := 50

var speed := 0

var serveSide := 1
# when ball is scored but not reset yet
var ballScored := false

var game: Game

# signals
signal paddle_hit(paddle: Paddle, angle: int)
signal ball_reset(side: int)
signal ball_bounce
signal ball_serve

func _ready() -> void:
	ball_visual.visible = false
	ball_visual.play()
	game = get_parent()
	serve_timer.timeout.connect(serveBall)
	reset_timer.timeout.connect(resetBall)
	
	# wait one frame before calling reset so signals can connect
	await get_tree().process_frame
	resetBall()

func _input(event) -> void:
	if event.is_action_pressed("debug_respawn"):
		resetBall()

func resetBall() -> void:
	col_shape.disabled = false
	ball_visual.visible = false
	velocity = Vector2.ZERO
	# Reset our speed
	speed = initialSpeed
	# Reset ball to our spawn location
	position = ball_spawn.position
	ballScored = false
	serve_timer.start()
	ball_reset.emit(serveSide)

func serveBall() -> void:
	# set direction depending on serveSide
	if serveSide == 1:
		velocity = Vector2.LEFT
	else:
		velocity = Vector2.RIGHT
	
	# Choose random angle from a range using serve angle, (ex. -30, 30)
	var _serveAngle = randf_range(-serveAngle,serveAngle)
	# Set ball rotation
	rotation = deg_to_rad(_serveAngle)
	
	# Set our velocity for move_and_collide and rotate accordingly
	velocity = (velocity * speed).rotated(rotation)
	
	ball_visual.visible = true
	ball_serve.emit()

func _physics_process(delta: float) -> void:
	var col = move_and_collide(velocity * delta)
	rotation = velocity.angle()
	
	if col and not ballScored:
		bounce_particles.emitting = true
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
			ball_bounce.emit()
			velocity = velocity.bounce(col.get_normal()).normalized() * speed
			bounce_sound.play()

func paddleBounce(paddle: Paddle) -> void:
	
	# Get height of collider to get paddle height
	var paddleHeight = paddle.get_node("CollisionShape2D").shape.size.y
	
	# find the location of the ball localized to the paddle, where the bottom is -halfHeight and the top is halfHeight
	var relativeIntersectY =  (paddle.global_position.y - global_position.y)
	# normalize our relative intersection between -1 and 1
	var normalized = clamp(relativeIntersectY / (paddleHeight / 2), -1.0, 1.0)
	# calculate the angle which to bounce at (in rad)
	var bounceRotation = normalized * deg_to_rad(maxPaddleBounceAngle)
	
	# Bounce in opposite direction on the X
	var dirX = -signf(velocity.x)
	
	# Increase speed of the ball before doing the bounce, clamped to maxSpeed
	speed = mini(speed + ball_speed_increment, maxSpeed)
	# set velocity by assigning x direction and rotating by bounceAngle
	velocity = (Vector2.RIGHT * dirX).rotated(bounceRotation) * speed
	paddle_hit.emit(paddle, rad_to_deg(abs(bounceRotation)))

# Set serving side to opposite player, update score, and reset ball to center
func leftWallHit() -> void:
	serveSide = 2
	game.emit_signal("P2Scored")
	on_ball_scored()
func rightWallHit() -> void:
	serveSide = 1
	game.emit_signal("P1Scored")
	on_ball_scored()

func on_ball_scored() -> void:
	velocity = Vector2.ZERO
	col_shape.disabled = true
	ball_visual.visible = false
	ballScored = true
	score_particles.emitting = true
	score_sprite.visible = true
	score_sprite.play()
	if !game.isGameDone:
		reset_timer.start()
