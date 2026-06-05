extends Node2D
class_name GameWorld

## GameWorld — orchestrates the auto-battle scene.
##
## Responsibilities:
##   - Owns the Hero, Enemies container, and WaveManager nodes.
##   - Calls WaveManager.start_wave() once on startup.
##   - Listens to WaveManager signals to log wave progress.
##   - Listens to GameEvents.enemy_defeated to log rewards.
##     (Rewards will be wired to game state in a later step.)

# ---------------------------------------------------------------------------
# Node references — populated automatically when the scene loads.
# ---------------------------------------------------------------------------

const FloatingTextScene = preload("res://scenes/ui/FloatingText.tscn")

@onready var heroes_root:  Node2D      = $Heroes
@onready var enemies_root: Node2D      = $Enemies
@onready var wave_manager: WaveManager = $WaveManager

@onready var _spawn1: Marker2D = $SpawnPoints/EnemySpawn1
@onready var _spawn2: Marker2D = $SpawnPoints/EnemySpawn2
@onready var _spawn3: Marker2D = $SpawnPoints/EnemySpawn3


# ---------------------------------------------------------------------------
# _ready — runs once when GameWorld enters the scene tree.
# ---------------------------------------------------------------------------

func _ready() -> void:
	print("=== [GameWorld] Starting auto-battle wave loop ===")
	print("[GameWorld] Heroes ready:  %d" % heroes_root.get_child_count())

	# Wire WaveManager in code — this is the ONLY reliable approach for
	# hand-written .tscn files. Godot does not guarantee NodePath resolution
	# for exported Node/Array[Node] properties in non-editor-written scenes.
	wave_manager.enemies_root = enemies_root
	wave_manager.spawn_points = [_spawn1, _spawn2, _spawn3]

	# Connect WaveManager signals so GameWorld can react to wave events.
	# Later these will also update the HUD and game state.
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.wave_cleared.connect(_on_wave_cleared)
	wave_manager.boss_spawned.connect(_on_boss_spawned)
	wave_manager.all_waves_completed.connect(_on_all_waves_completed)

	# Log enemy defeat events (reward wiring comes in a later step).
	GameEvents.enemy_defeated.connect(_on_enemy_defeated)

	# Kick off the first wave.
	# WaveManager handles all subsequent waves automatically.
	wave_manager.start_wave()


# ---------------------------------------------------------------------------
# WaveManager signal handlers
# ---------------------------------------------------------------------------

func _on_wave_started(wave_number: int) -> void:
	print("[GameWorld] ▶ Wave %d started." % wave_number)


func _on_wave_cleared(wave_number: int) -> void:
	print("[GameWorld] ✓ Wave %d cleared!" % wave_number)


func _on_boss_spawned(wave_number: int) -> void:
	print("[GameWorld] ★ BOSS spawned on wave %d!" % wave_number)


func _on_all_waves_completed() -> void:
	print("[GameWorld] 🏆 All waves completed — victory!")


# ---------------------------------------------------------------------------
# GameEvents signal handlers
# ---------------------------------------------------------------------------

func _on_enemy_defeated(enemy_id: String, gold_reward: int, exp_reward: int, _is_boss: bool, death_position: Vector2) -> void:
	## Logs each enemy defeat reward.
	## Gold and EXP will be applied to game state in a later step.
	print("[GameWorld] Reward: id=%s  gold=%d  exp=%d  (not yet applied)" % [
		enemy_id, gold_reward, exp_reward
	])
	
	# Spawn floating texts if rewards are greater than 0
	if gold_reward > 0:
		var ft = FloatingTextScene.instantiate()
		add_child(ft)
		# Slightly offset gold to the left/up
		ft.setup("+%d Gold" % gold_reward, death_position + Vector2(-10, -20), Color(1.0, 0.8, 0.2)) # Gold-ish yellow
		
	if exp_reward > 0:
		var ft = FloatingTextScene.instantiate()
		add_child(ft)
		# Slightly offset exp to the right/up
		ft.setup("+%d EXP" % exp_reward, death_position + Vector2(10, -10), Color(0.2, 0.6, 1.0)) # EXP-ish blue
