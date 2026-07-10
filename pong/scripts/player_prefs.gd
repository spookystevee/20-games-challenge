class_name PlayerPrefs extends Resource

enum Difficulty {
	NORMAL,
	HARD
}

enum GameType {
	LOCAL,
	BOT,
}

static var difficultyScaling = {
	Difficulty.NORMAL: Vector2(0.5, 0.85),
	Difficulty.HARD: Vector2(0.25, 0.5),
}

#Selected mode, either Local multiplayer or playing against a bot
@export var currentGameType := GameType.BOT

@export var currentDifficulty = difficultyScaling[Difficulty.NORMAL]

func save() -> void:
	ResourceSaver.save(self, "user://player_prefs.tres")

static func load_or_create() -> PlayerPrefs:
	var res: PlayerPrefs = load("user://player_prefs.tres") as PlayerPrefs
	if !res:
		res = PlayerPrefs.new()
	return res
