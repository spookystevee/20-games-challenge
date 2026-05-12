class_name Game
extends Node2D

const menu := preload("res://scenes/Menu.tscn")

#audio for scoring
const P1ScoreAudio = preload("uid://d4htl16ohnvtl")
const P2ScoreAudio = preload("uid://bjb6wdfp0sxcu")

var score := [0,0]
var winner := 0

# signals
signal P1Scored
signal P2Scored

#object references
@onready var P1Label: Label = %P1Score
@onready var P2Label: Label = %P2Score

@onready var score_audio: AudioStreamPlayer2D = %ScoreAudio

@onready var serve_indicator: ServeIndicator = %ServeIndicator

var total_combo := 0


func _ready() -> void:
	P1Scored.connect(_on_P1Scored)
	P2Scored.connect(_on_P2Scored)
	var ball: Ball = get_tree().get_first_node_in_group("ball")
	ball.ball_reset.connect(_on_round_reset)
	ball.ball_serve.connect(_on_serve)
	ball.paddle_hit.connect(_on_paddle_hit)

func _on_P1Scored():
	score_audio.stream = P1ScoreAudio
	score_audio.play()
	score[0] += 1
	updateLabels()
func _on_P2Scored():
	score_audio.stream = P2ScoreAudio
	score_audio.play()
	score[1] += 1
	updateLabels()

func updateLabels() -> void:
	P1Label.text = str(score[0])
	P2Label.text = str(score[1])

func _on_round_reset(side: int) -> void:
	if (score[0] == 1):
		winner = 1
		SceneManager.change_scene(menu.resource_path)
	elif (score[1] == 1):
		winner = 2
		SceneManager.change_scene(menu.resource_path)
	else:
		total_combo = 0
		var pos: Vector2
		var flip: bool
		if side == 1:
			flip = false
			pos = P1Label.global_position + (P1Label.size) - Vector2(10,10)
		else:
			flip = true
			pos = P2Label.global_position
		
		serve_indicator.on_reset(pos, flip)


func _on_serve() -> void:
		serve_indicator.on_serve()

func _on_paddle_hit(_p: Paddle, _a: float):
	total_combo += 1
