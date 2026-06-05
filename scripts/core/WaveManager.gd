extends Node
class_name WaveManager

## Manages waves of enemies for the idle RPG auto-battle.
##
## Death detection (updated approach):
##   Each enemy spawned by WaveManager has CharacterBase.died signal.
##   WaveManager connects to it at spawn time and decrements _alive_count.
##   When _alive_count reaches 0 the wave is cleared immediately — no
##   scanning the scene tree every frame, no call_deferred workaround.
##
## How the full loop works:
##   1. Call start_wave() to begin the current wave.
##   2. WaveManager spawns enemies and connects to each one's died signal.
##   3. Each time an enemy dies, _on_enemy_died() fires and decrements
##      _alive_count.
##   4. When _alive_count reaches 0, _on_wave_cleared() is called.
##   5. After a short delay, the next wave starts automatically.
##   6. Every 10 waves a boss wave is spawned instead of a normal wave.
##
## To use:
##   - Add WaveManager as a child node of GameWorld.
##   - Assign enemy_scene, boss_scene, enemies_root, and spawn_points in Inspector.
##   - Call start_wave() from GameWorld._ready() after heroes are in place.


# ---------------------------------------------------------------------------
# Signals — emitted so GameWorld, HUD, and other systems can react.
# ---------------------------------------------------------------------------

signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)
signal boss_spawned(wave_number: int)
signal all_waves_completed()


# ---------------------------------------------------------------------------
# Exported settings — set these in the Godot Inspector or from GameWorld.gd.
# ---------------------------------------------------------------------------

## Scene to instantiate for regular enemies. Must use EnemyCharacter script.
@export var enemy_scene: PackedScene

## Scene to instantiate for boss enemies. Falls back gracefully if not set.
@export var boss_scene: PackedScene

## The Node2D that spawned enemies will be added to as children.
## Should be the "Enemies" node in GameWorld so they stay organized.
@export var enemies_root: Node2D

## List of positions where enemies can spawn (right side of battlefield).
## WaveManager cycles through these to spread enemies out.
@export var spawn_points: Array[Node2D] = []

## How many enemies appear in a normal wave.
## This grows slightly with each wave to increase difficulty over time.
@export var enemies_per_wave: int = 3

## Boss appears every N waves. Default is every 10 waves.
@export var boss_wave_interval: int = 10

## Seconds to wait between wave cleared and next wave starting.
@export var next_wave_delay: float = 3.0

## Maximum number of waves before the game considers the run complete.
## Set to 0 for unlimited waves.
@export var max_waves: int = 50


# ---------------------------------------------------------------------------
# Runtime state — changes during gameplay.
# ---------------------------------------------------------------------------

## The wave number currently active (starts at 1).
var current_wave: int = 1

## True while a wave is in progress (enemies are still alive).
var is_wave_active: bool = false

## Counts how many enemies were spawned in the current wave.
## Used for logging.
var _enemies_spawned: int = 0

## Counts how many spawned enemies are still alive.
## Decremented by _on_enemy_died() when each enemy's died signal fires.
## When it reaches 0 the wave is considered cleared.
var _alive_count: int = 0


# ---------------------------------------------------------------------------
# Built-in callbacks
# ---------------------------------------------------------------------------

func _ready() -> void:
	# Listen to GameEvents.enemy_defeated so GameWorld and HUD can receive
	# reward data via the global bus. Wave clearing is handled separately
	# by per-instance died signals connected in spawn_enemy().
	GameEvents.enemy_defeated.connect(_on_enemy_defeated)

	print("[WaveManager] Ready. Starting on wave %d." % current_wave)


# ---------------------------------------------------------------------------
# Public API — called by GameWorld to start the battle loop.
# ---------------------------------------------------------------------------

func start_wave() -> void:
	## Begin the current wave. Call this once from GameWorld._ready().
	## After the first wave clears, WaveManager handles the rest automatically.

	if is_wave_active:
		push_warning("[WaveManager] start_wave() called while a wave is already active.")
		return

	if max_waves > 0 and current_wave > max_waves:
		print("[WaveManager] All %d waves completed!" % max_waves)
		all_waves_completed.emit()
		return

	is_wave_active = true
	_enemies_spawned = 0
	_alive_count = 0  # Reset before spawning so count is accurate.

	print("\n--- [WaveManager] Wave %d starting ---" % current_wave)

	# Emit signal so HUD and GameEvents can react.
	wave_started.emit(current_wave)
	GameEvents.wave_started.emit(current_wave)

	# Choose between boss wave and normal wave.
	if current_wave % boss_wave_interval == 0:
		spawn_boss_wave()
	else:
		spawn_normal_wave()


func stop_waves() -> void:
	## Pause the wave loop. Useful for game-over or pause screens.
	is_wave_active = false
	print("[WaveManager] Wave loop stopped.")


# ---------------------------------------------------------------------------
# Spawning
# ---------------------------------------------------------------------------

func spawn_normal_wave() -> void:
	## Spawn a group of regular enemies.
	## Enemy count scales slightly with wave number to add difficulty.

	# Count increases every 5 waves: wave 1-4 = base, wave 5-9 = base+1, etc.
	var count := enemies_per_wave + (current_wave / 5)

	print("[WaveManager] Spawning %d normal enemies for wave %d." % [count, current_wave])

	for i in range(count):
		var spawn_pos := _get_spawn_position(i)
		spawn_enemy(spawn_pos, false)


func spawn_boss_wave() -> void:
	## Spawn a boss enemy instead of regular enemies.
	## If boss_scene is not assigned, falls back to a buffed normal enemy.

	print("[WaveManager] *** BOSS WAVE %d! ***" % current_wave)
	boss_spawned.emit(current_wave)

	if boss_scene == null:
		push_warning("[WaveManager] boss_scene not assigned — spawning buffed normal enemy instead.")
		# Fall back: spawn one enemy at center-right and manually buff it after.
		var spawn_pos := _get_spawn_position(0)
		var enemy := spawn_enemy(spawn_pos, true)
		if enemy != null and enemy.has_method("setup_from_data"):
			# Double the HP and ATK for a makeshift boss feel.
			enemy.max_hp  = enemy.max_hp  * 2
			enemy.current_hp = enemy.max_hp
			enemy.atk     = enemy.atk     + 5
			enemy.display_name = "BOSS " + enemy.display_name
		return

	# Spawn the actual boss scene.
	var spawn_pos := _get_spawn_position(0)
	spawn_enemy(spawn_pos, true)


func spawn_enemy(spawn_position: Vector2, is_boss: bool = false) -> Node:
	## Instantiate one enemy and add it to enemies_root.
	## Returns the spawned node, or null if something went wrong.
	##
	## spawn_position: Where in the world to place the enemy.
	## is_boss:        If true, use boss_scene instead of enemy_scene.

	# Choose which scene to instantiate.
	var scene := boss_scene if (is_boss and boss_scene != null) else enemy_scene

	if scene == null:
		push_error("[WaveManager] spawn_enemy: no valid scene to instantiate.")
		return null

	if enemies_root == null:
		push_error("[WaveManager] spawn_enemy: enemies_root is not assigned.")
		return null

	# Create the enemy node from the scene.
	var enemy := scene.instantiate()

	# Add to the scene tree under enemies_root.
	enemies_root.add_child(enemy)

	# Place the enemy at the requested position.
	if enemy is Node2D:
		(enemy as Node2D).global_position = spawn_position

	_enemies_spawned += 1
	_alive_count += 1

	# Connect to the per-instance died signal on this enemy.
	# When the enemy dies, _on_enemy_died() fires and decrements _alive_count.
	# We check has_signal() so this is safe even if a non-CharacterBase node
	# ends up in the scene by mistake.
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)

	print("[WaveManager] Spawned %s at %s (boss=%s)" % [
		enemy.name, str(spawn_position), str(is_boss)
	])

	return enemy


# ---------------------------------------------------------------------------
# Wave cleared detection
# ---------------------------------------------------------------------------

func get_alive_enemies() -> Array:
	## Return all living enemies currently in the scene.
	## Uses the "enemies" group — same group EnemyCharacter._ready() registers.

	var alive: Array = []

	for node in get_tree().get_nodes_in_group("enemies"):
		# Skip invalid or already-freed nodes.
		if not is_instance_valid(node):
			continue
		# Skip dead enemies (is_dead comes from CharacterBase).
		if "is_dead" in node and node.is_dead:
			continue
		alive.append(node)

	return alive


func check_wave_cleared() -> void:
	## Check if all enemies from this wave are dead.
	## Called after every enemy death — not every frame.

	if not is_wave_active:
		return

	var alive := get_alive_enemies()

	if alive.size() == 0:
		# All enemies are gone — the wave is cleared.
		_on_wave_cleared()


# ---------------------------------------------------------------------------
# Wave progression
# ---------------------------------------------------------------------------

func _on_wave_cleared() -> void:
	## Called internally when all enemies in the current wave are dead.

	is_wave_active = false

	print("[WaveManager] Wave %d cleared!" % current_wave)

	wave_cleared.emit(current_wave)
	GameEvents.wave_cleared.emit(current_wave)

	# Wait a few seconds, then start the next wave automatically.
	start_next_wave()


func start_next_wave() -> void:
	## Wait for the configured delay, then increment wave and start again.
	## Uses await so this runs as a coroutine without blocking other code.

	print("[WaveManager] Next wave in %.1f seconds..." % next_wave_delay)

	# Pause before the next wave so the hero has a moment to stand still.
	await get_tree().create_timer(next_wave_delay).timeout

	current_wave += 1
	start_wave()


# ---------------------------------------------------------------------------
# Signal handlers
# ---------------------------------------------------------------------------

func _on_enemy_died(character: CharacterBase) -> void:
	## Called the moment an enemy's died signal fires (from CharacterBase.die()).
	## At this point:
	##   - character.is_dead is already true.
	##   - character node is still valid (queue_free runs end-of-frame).
	##   - get_alive_enemies() will correctly skip this character.
	## No call_deferred is needed because is_dead is true before died fires.

	if not is_wave_active:
		return

	_alive_count = maxi(_alive_count - 1, 0)

	print("[WaveManager] Enemy died: %s. Remaining this wave: %d" % [
		character.display_name, _alive_count
	])

	# Check immediately — no deferral needed.
	if _alive_count <= 0:
		_on_wave_cleared()


func _on_enemy_defeated(_enemy_id: String, _gold: int, _exp: int, _is_boss: bool, _death_position: Vector2) -> void:
	## Triggered by GameEvents.enemy_defeated.
	## Wave clearing is now handled by _on_enemy_died (per-instance died signal).
	## This handler is kept only so GameWorld / HUD can still receive reward data
	## via the global GameEvents bus without WaveManager needing to re-emit it.
	pass  # Wave clearing is handled by _on_enemy_died above.


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

func _get_spawn_position(enemy_index: int) -> Vector2:
	## Return a world position for the Nth enemy in the wave.
	##
	## If spawn_points are assigned: cycle through them.
	## If no spawn_points: use a fallback row on the right side of the screen.

	if spawn_points.size() > 0:
		# Cycle through assigned spawn points (index wraps around).
		var point := spawn_points[enemy_index % spawn_points.size()]
		if is_instance_valid(point):
			# Spread enemies so they don't all stack on the same pixel.
			# Each enemy is offset slightly downward from the previous.
			var vertical_offset := Vector2(0, (enemy_index / spawn_points.size()) * 40)
			return point.global_position + vertical_offset

	# Fallback: place enemies in a horizontal row at x=900, y=500.
	# Each enemy is 50px to the right of the previous one.
	return Vector2(900 + enemy_index * 50, 500)
