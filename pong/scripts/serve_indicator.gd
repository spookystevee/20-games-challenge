class_name ServeIndicator
extends Node2D
@onready var indicator_audio: AudioStreamPlayer2D = %IndicatorAudio
@onready var arrow: AnimatedSprite2D = %Arrow

func on_reset(pos: Vector2, flip: bool) -> void:
	arrow.flip_h = flip
	arrow.global_position.x = pos.x
	indicator_audio.play()
	arrow.visible = true
	arrow.play()

func on_serve() -> void:
	arrow.visible = false
	arrow.stop()
