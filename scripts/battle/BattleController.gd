extends Node2D

## Minimal wave starter.
## This spawns one starter hero and reads the first wave without implementing full combat yet.

@export var hero_scene: PackedScene
@export var enemy_scene: PackedScene
@export var starting_wave_id: String = "wave_001"

@onready var heroes_root: Node2D = $Heroes
@onready var enemies_root: Node2D = $Enemies
@onready var hero_spawn: Marker2D = $SpawnPoints/HeroSpawn
@onready var enemy_spawn: Marker2D = $SpawnPoints/EnemySpawn

var active_wave_id: String = ""


func _ready() -> void:
	spawn_starter_hero("hero_knight")
	start_wave(starting_wave_id)


func spawn_starter_hero(hero_id: String) -> void:
	if hero_scene == null:
		push_warning("Hero scene is not assigned.")
		return

	var hero := hero_scene.instantiate() as Hero
	if hero == null:
		push_warning("Assigned hero scene does not use Hero.gd.")
		return

	hero.hero_id = hero_id
	heroes_root.add_child(hero)
	hero.global_position = hero_spawn.global_position


func start_wave(wave_id: String) -> void:
	active_wave_id = wave_id
	GameEvents.wave_started.emit(wave_id)

	var wave := DataManager.get_wave(wave_id)
	if wave.is_empty():
		push_warning("Unknown wave id: %s" % wave_id)
		return

	_spawn_wave_enemies(wave)


func _spawn_wave_enemies(wave: Dictionary) -> void:
	if enemy_scene == null:
		push_warning("Enemy scene is not assigned.")
		return

	var spawn_offset := Vector2.ZERO
	for entry in wave.get("enemies", []):
		var enemy_id := String(entry.get("enemy_id", ""))
		var count := int(entry.get("count", 0))

		for _index in range(count):
			var enemy := enemy_scene.instantiate() as Enemy
			if enemy == null:
				push_warning("Assigned enemy scene does not use Enemy.gd.")
				return

			enemy.enemy_id = enemy_id
			enemies_root.add_child(enemy)
			enemy.global_position = enemy_spawn.global_position + spawn_offset
			spawn_offset += Vector2(42, 0)
