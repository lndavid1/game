extends Node
class_name GameState

## Runtime player progress.
## This is intentionally small until save/load and progression rules are designed.

var gold: int = 0
var exp: int = 0
var current_wave_id: String = "wave_001"


func add_gold(amount: int) -> void:
	gold = max(gold + amount, 0)
	GameEvents.gold_changed.emit(gold)


func add_exp(amount: int) -> void:
	exp = max(exp + amount, 0)
	GameEvents.exp_changed.emit(exp)


func set_current_wave(wave_id: String) -> void:
	current_wave_id = wave_id

