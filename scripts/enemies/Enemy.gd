extends CharacterBase
class_name EnemyCharacter

## Basic enemy behavior.
## Receives damage from heroes, dies when HP reaches zero, emits defeat signal.
## Movement and AI will be added in a later step.

# ---------------------------------------------------------------------------
# Enemy-only data (not in CharacterBase because heroes don't have these).
# ---------------------------------------------------------------------------

## The JSON key used to look up this enemy in DataManager.
@export var enemy_id: String = ""

## Gold and EXP given to the player when this enemy is defeated.
var gold_reward: int = 0
var exp_reward: int = 0


# ---------------------------------------------------------------------------
# Built-in callbacks
# ---------------------------------------------------------------------------

func _ready() -> void:
	# Register in the "enemies" group so heroes can find this node.
	add_to_group("enemies")

	# CharacterBase._ready() sets current_hp = max_hp.
	super()

	# Load stats from DataManager if enemy_id is set.
	# This overwrites the Inspector defaults with JSON balance values.
	if enemy_id != "":
		var data := DataManager.get_enemy(enemy_id)
		if not data.is_empty():
			_load_from_data(data)
		else:
			push_warning("[EnemyCharacter] No data found for enemy_id: %s" % enemy_id)

	print("[EnemyCharacter] spawned: %s  HP:%d  ATK:%d  DEF:%d  Gold:%d  EXP:%d" % [
		display_name, max_hp, atk, def, gold_reward, exp_reward
	])


# ---------------------------------------------------------------------------
# Data loading
# ---------------------------------------------------------------------------

func _load_from_data(data: Dictionary) -> void:
	## Load stats from enemies.json via DataManager.
	## Calls CharacterBase.setup_from_data() for shared fields,
	## then reads enemy-only fields (gold_reward, exp_reward).

	# Shared stats: id, display_name, max_hp, attack, move_speed, etc.
	setup_from_data(data)

	# Enemy-only reward values.
	gold_reward = int(data.get("gold_reward", gold_reward))
	exp_reward  = int(data.get("exp_reward",  exp_reward))


# ---------------------------------------------------------------------------
# Death — override to emit the defeat signal before removing the node.
# ---------------------------------------------------------------------------

func die() -> void:
	## Called when HP reaches zero (from CharacterBase.take_damage).
	## Emits GameEvents.enemy_defeated so the reward system can respond.
	## Then calls super() which sets is_dead = true and calls queue_free().

	# Guard: prevent double-death (CharacterBase.die() also checks, but
	# we check here too so the signal is never emitted twice).
	if is_dead:
		return

	print("[EnemyCharacter] %s defeated! Dropping %d gold and %d EXP." % [
		display_name, gold_reward, exp_reward
	])

	# Notify other systems (gold, EXP, wave tracker, etc.).
	GameEvents.enemy_defeated.emit(enemy_id, gold_reward, exp_reward)

	# Let CharacterBase handle is_dead = true, velocity reset, queue_free().
	super()


# ---------------------------------------------------------------------------
# Target finding — kept here for when enemy AI is added later.
# ---------------------------------------------------------------------------

func find_nearest_hero() -> Node2D:
	## Scans the "heroes" group and returns the closest living Node2D.
	## Returns null if no valid hero exists.
	## Not called yet — enemy AI is not implemented in this step.

	var nearest: Node2D = null
	var nearest_dist := INF

	for node in get_tree().get_nodes_in_group("heroes"):
		# Skip anything that is not a 2D node.
		if not node is Node2D:
			continue

		# Skip heroes that are already dead.
		if "is_dead" in node and node.is_dead:
			continue

		# Skip nodes freed but not yet removed from the group.
		if not is_instance_valid(node):
			continue

		var dist := global_position.distance_to((node as Node2D).global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = node as Node2D

	return nearest


# ---------------------------------------------------------------------------
# AI stub — movement and attack-back behavior comes in a later step.
# ---------------------------------------------------------------------------

func update_ai() -> void:
	## Enemy AI placeholder.
	## Will be implemented after the hero attack loop is stable.
	## When ready: find nearest hero, move toward it, attack when in range.
	pass
