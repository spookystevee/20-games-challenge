extends Camera2D

# how fast the shake stops
@export var shake_fade := 5.0  
var rng = RandomNumberGenerator.new()
var noise = FastNoiseLite.new()

var shake_strength := 0.0
var noise_i : float = 0.0

func _ready():
	noise.seed = randi()
	# higher = faster shake
	noise.frequency = 0.5
	%Ball.paddle_hit.connect(on_paddle_hit)
	%Ball.ball_bounce.connect(on_bounce)
	get_parent().P1Scored.connect(on_score)
	get_parent().P2Scored.connect(on_score)

func _process(delta):
	if shake_strength > 0:
		# reduce shake strength over time
		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
		
		# Move the camera based on noise
		offset = get_noise_offset(delta)

func apply_shake(strength: float):
	shake_strength = strength

func get_noise_offset(delta: float) -> Vector2:
	# controls how fast we move through the noise map
	noise_i += delta * 30 
	return Vector2(
		noise.get_noise_2d(1, noise_i) * shake_strength,
		noise.get_noise_2d(100, noise_i) * shake_strength
	)

func on_paddle_hit(_p: Paddle, _a: float):
	apply_shake(5)
func on_score():
	apply_shake(250)
func on_bounce():
	apply_shake(7)
