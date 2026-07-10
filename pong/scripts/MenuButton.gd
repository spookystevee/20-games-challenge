extends Button

var tween: Tween
@onready var button_sfx: AudioStreamPlayer2D = %ButtonSwitchSFX
@onready var button_select_sfx: AudioStreamPlayer2D = %ButtonSelectSFX

const BUTTON_UP = preload("uid://cogpgte2fijo8")
const BUTTON_DOWN = preload("uid://pik13o68cqw7")


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	focus_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_exited.connect(_on_mouse_exited)
	
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	
func _on_mouse_entered() -> void:
	reset_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.6)
	button_sfx.play()
	
func _on_mouse_exited() -> void:
	reset_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, 0.6)

func _on_button_down() -> void:
	reset_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2(.95, .95), 0.4)
	button_select_sfx.stream = BUTTON_DOWN
	button_select_sfx.play()

func _on_button_up() -> void:
	_on_mouse_exited()
	button_select_sfx.stream = BUTTON_UP
	button_select_sfx.play()

func reset_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
