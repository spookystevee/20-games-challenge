extends Control

@onready var start: Button = %Start
@onready var settings: Button = %Settings
@onready var quit: Button = %Quit

@onready var music_button: Button = %MusicButton
@onready var play_mode_button: Button = %PlayModeButton
@onready var settings_back_button: Button = %SettingsBackButton
@onready var difficulty_button: Button = %DifficultyButton
@onready var sfx_button: Button = %SfxButton

@onready var difficulty_section: HBoxContainer = %DifficultySec

@onready var main_menu: MarginContainer = %MainMenu
@onready var settings_menu: MarginContainer = %SettingsMenu

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
	InitializeMenu()

func InitializeMenu() -> void:
	main_menu.visible = true
	settings_menu.visible = false
	player_prefs = PlayerPrefs.load_or_create()
	LoadSettings()
	start.grab_focus()
	
	start.pressed.connect(_on_start_pressed)
	settings.pressed.connect(_on_settings_pressed)
	quit.pressed.connect(_on_quit_pressed)
	
	music_button.pressed.connect(_on_music_toggle)
	sfx_button.pressed.connect(_on_sfx_toggle)
	play_mode_button.pressed.connect(_on_playmode_toggle)
	difficulty_button.pressed.connect(_on_difficulty_toggle)
	
	settings_back_button.pressed.connect(_on_settings_back)

func LoadSettings() -> void:
	UpdateMusicSetting()
	UpdatePlayModeSetting()
	UpdateDifficultySetting()
	UpdateSFXSetting()

func UpdateMusicSetting() -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_mute(music_bus, !player_prefs.music)
	if player_prefs.music:
		music_button.text = 'ON'
	else:
		music_button.text = 'OFF'

func UpdateSFXSetting() -> void:
	var sfx_bus = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_mute(sfx_bus, !player_prefs.sfx)
	if player_prefs.sfx:
		sfx_button.text = 'ON'
	else:
		sfx_button.text = 'OFF'

func UpdatePlayModeSetting() -> void:
	if player_prefs.currentGameType == player_prefs.GameType.LOCAL:
		play_mode_button.text = "LOCAL"
		difficulty_section.visible = false
	else:
		play_mode_button.text = "BOT"
		difficulty_section.visible = true

func UpdateDifficultySetting() -> void:
	if player_prefs.currentDifficulty == player_prefs.difficultyScaling[player_prefs.Difficulty.NORMAL]:
		difficulty_button.text = "NORMAL"
	else:
		difficulty_button.text = "HARD"

func _on_start_pressed() -> void:
	SceneManager.change_scene(game_scene)

func _on_settings_pressed() -> void:
	settings_menu.visible = true
	main_menu.visible = false
	play_mode_button.grab_focus()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_normal_pressed() -> void:
	player_prefs.currentDifficulty = PlayerPrefs.difficultyScaling[PlayerPrefs.Difficulty.NORMAL]
	
func _on_hard_pressed() -> void:
	player_prefs.currentDifficulty = PlayerPrefs.difficultyScaling[PlayerPrefs.Difficulty.HARD]

func _on_music_toggle() -> void:
	player_prefs.music = !player_prefs.music
	UpdateMusicSetting()

func _on_sfx_toggle() -> void:
	player_prefs.sfx = !player_prefs.sfx
	UpdateSFXSetting()

func _on_difficulty_toggle() -> void:
	if player_prefs.currentDifficulty == player_prefs.difficultyScaling[player_prefs.Difficulty.NORMAL]:
		player_prefs.currentDifficulty = player_prefs.difficultyScaling[player_prefs.Difficulty.HARD]
	else:
		player_prefs.currentDifficulty = player_prefs.difficultyScaling[player_prefs.Difficulty.NORMAL]
	UpdateDifficultySetting()

func _on_playmode_toggle() -> void:
	if player_prefs.currentGameType == player_prefs.GameType.LOCAL:
		player_prefs.currentGameType = player_prefs.GameType.BOT
	else:
		player_prefs.currentGameType = player_prefs.GameType.LOCAL
	UpdatePlayModeSetting()

func _on_settings_back() -> void:
	player_prefs.save()
	settings_menu.visible = false
	main_menu.visible = true
	start.grab_focus()
