extends Node

## Coordinates high-level game flow.
## Detailed gameplay logic should stay in focused systems such as wave, combat, save, and UI scripts.

var gold: int = 0
var exp: int = 0
var current_stage: String = "forest_stage_01"
var current_wave: int = 1


func start_game() -> void:
	# Later: load save data, prepare the first stage, and start idle battle flow.
	pass


func pause_game() -> void:
	# Later: pause gameplay timers and prepare save/offline tracking.
	pass


func add_gold(amount: int) -> void:
	if amount <= 0:
		return
	gold += amount
	GameEvents.gold_changed.emit(gold)


func add_exp(amount: int) -> void:
	if amount <= 0:
		return
	exp += amount
	GameEvents.exp_changed.emit(exp)
