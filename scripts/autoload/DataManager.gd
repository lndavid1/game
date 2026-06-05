extends Node

## Loads static game data from JSON.
## Balance values should start in res://data/ instead of being hardcoded in gameplay scripts.

const HEROES_PATH := "res://data/heroes.json"
const ENEMIES_PATH := "res://data/enemies.json"
const WAVES_PATH := "res://data/waves.json"
const UPGRADES_PATH := "res://data/upgrades.json"

var heroes: Array = []
var enemies: Array = []
var waves: Array = []
var upgrades: Array = []


func _ready() -> void:
	load_all()


func load_all() -> void:
	heroes = _load_json_array(HEROES_PATH)
	enemies = _load_json_array(ENEMIES_PATH)
	waves = _load_json_array(WAVES_PATH)
	upgrades = _load_json_array(UPGRADES_PATH)


func get_hero(hero_id: String) -> Dictionary:
	return _find_by_id(heroes, hero_id)


func get_enemy(enemy_id: String) -> Dictionary:
	return _find_by_id(enemies, enemy_id)


func get_wave(wave_id: String) -> Dictionary:
	return _find_by_id(waves, wave_id)


func _load_json_array(path: String) -> Array:
	if not FileAccess.file_exists(path):
		push_warning("Missing data file: %s" % path)
		return []

	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if parsed == null:
		push_error("Invalid JSON file: %s" % path)
		return []
	if not (parsed is Array):
		push_error("Expected JSON array in: %s" % path)
		return []

	return parsed


func _find_by_id(items: Array, item_id: String) -> Dictionary:
	for item in items:
		if item is Dictionary and item.get("id", "") == item_id:
			return item
	return {}
