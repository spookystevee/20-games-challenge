extends Control

@onready var start: Button = %Start
@onready var settings: Button = %Settings
@onready var quit: Button = %Quit
@onready var focus_arrow: Sprite2D = %FocusArrow

@onready var main_menu: MarginContainer = %MainMenu

var game_scene := ("res://scenes/game.tscn")

var player_prefs: PlayerPrefs


func _enter_tree() -> void:
	# On enter tree we connect to SceneTree.node_added signal to find all the buttons that will be added
	# and connect to their signals
	get_tree().node_added.connect(func(node:Node):
		if node is Button and not node.is_connected("mouse_entered", node.grab_focus):
			# grab focus when mouse entered so we can play the animation on mouse hover
			node.mouse_entered.connect(node.grab_focus)
	)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		_on_quit_pressed()

func _ready() -> void:
	player_prefs = PlayerPrefs.load_or_create()
	start.grab_focus()

func _on_start_pressed() -> void:
	SceneManager.change_scene(game_scene)


func _on_start_focus_entered() -> void:
	focus_arrow.reparent(start.get_node("ArrowMark"), false)


func _on_quit_focus_entered() -> void:
	focus_arrow.reparent(quit.get_node("ArrowMark"), false)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_ai_pressed() -> void:
	if player_prefs:
		player_prefs.currentGameType = player_prefs.GameType.BOT
		player_prefs.save()

func _on_local_pressed() -> void:
	if player_prefs:
		player_prefs.currentGameType = player_prefs.GameType.LOCAL
		player_prefs.save()

func _on_normal_pressed() -> void:
	player_prefs.currentDifficulty = PlayerPrefs.difficultyScaling[PlayerPrefs.Difficulty.NORMAL]
	
func _on_hard_pressed() -> void:
	player_prefs.currentDifficulty = PlayerPrefs.difficultyScaling[PlayerPrefs.Difficulty.HARD]
