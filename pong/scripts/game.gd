class_name Game
extends Node2D

var score := [0,0]

signal P1Scored
signal P2Scored
@onready var P1Label: Label = %P1Score
@onready var P2Label: Label = %P2Score

func _ready() -> void:
	P1Scored.connect(_on_P1Scored)
	P2Scored.connect(_on_P2Scored)

func _on_P1Scored():
	score[0] += 1
	updateLabels()
func _on_P2Scored():
	score[1] += 1
	updateLabels()

func updateLabels() -> void:
	P1Label.text = str(score[0])
	P2Label.text = str(score[1])
