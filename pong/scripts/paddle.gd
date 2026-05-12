class_name Paddle
extends AnimatableBody2D

const SPEED := 650

var direction := 0.0

@onready var hit_sound: AudioStreamPlayer2D = $HitSound
var currentCombo := 0

func _ready() -> void:
	var ball = get_tree().get_first_node_in_group("ball")
	
	if ball:
		ball.paddle_hit.connect(_on_ball_hit)
		ball.ball_reset.connect(_on_reset)

func _physics_process(delta: float) -> void:
	move_and_collide(Vector2(0, direction) * SPEED * delta)

func _on_ball_hit(paddle: Paddle, _angle: float) -> void:
	if paddle == self:
		hit_sound.pitch_scale += (get_parent().total_combo * .05)
		hit_sound.play()
		currentCombo += 1

func _on_reset(_side: int) -> void:
	currentCombo = 0
	hit_sound.pitch_scale = 1
