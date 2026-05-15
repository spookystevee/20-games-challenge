extends Control

@onready var start: Button = %Start
@onready var settings: Button = %Settings
@onready var quit: Button = %Quit
@onready var focus_arrow: Sprite2D = %FocusArrow

@onready var main_menu: MarginContainer = %MainMenu

var game_scene := ("res://scenes/game.tscn")


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
	start.grab_focus()

func _on_start_pressed() -> void:
	SceneManager.change_scene(game_scene)


func _on_start_focus_entered() -> void:
	focus_arrow.reparent(start.get_node("ArrowMark"), false)


func _on_settings_focus_entered() -> void:
	focus_arrow.reparent(settings.get_node("ArrowMark"), false)

func _on_quit_focus_entered() -> void:
	focus_arrow.reparent(quit.get_node("ArrowMark"), false)


func _on_quit_pressed() -> void:
	get_tree().quit()
