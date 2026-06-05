extends EnemyCharacter
class_name BossCharacter

## Boss enemy — extends EnemyCharacter with higher stats and a boss-specific
## spawn/death message. Skills and complex AI will be added in a later step.
##
## Inheritance chain:
##   CharacterBase  (stats, damage, death, cooldown timer)
##       └── EnemyCharacter  (group registration, DataManager loading, defeat signal)
##               └── BossCharacter  (this file — boss stats and debug messages)
##
## Because BossCharacter extends EnemyCharacter, it automatically:
##   - Registers in the "enemies" group (heroes can target it)
##   - Loads data from DataManager if enemy_id is set
##   - Emits GameEvents.enemy_defeated when it dies
##   - Drops gold_reward and exp_reward


# ---------------------------------------------------------------------------
# Boss-specific variables
# ---------------------------------------------------------------------------

# is_boss flag is inherited from EnemyCharacter. We will set it to true in _init().

## Boss-specific reward values. BossCharacter will overwrite EnemyCharacter's
## gold_reward and exp_reward with these values in _ready().
@export var boss_gold_reward: int = 50
@export var boss_exp_reward: int = 30


# ---------------------------------------------------------------------------
# Built-in callbacks
# ---------------------------------------------------------------------------

func _init() -> void:
	is_boss = true

func _ready() -> void:
	# super() runs EnemyCharacter._ready() which:
	#   1. Calls add_to_group("enemies")
	#   2. Calls CharacterBase._ready()  →  current_hp = max_hp
	#   3. Loads data from DataManager if enemy_id != ""
	super()
	
	# Override base EnemyCharacter rewards with Boss specific rewards.
	gold_reward = boss_gold_reward
	exp_reward = boss_exp_reward

	# Boss-specific spawn message — printed after super() so stats are final.
	print("*** [BossCharacter] BOSS SPAWNED: %s  HP:%d  ATK:%d  DEF:%d ***" % [
		display_name, max_hp, atk, def
	])


# ---------------------------------------------------------------------------
# Death override — adds boss-specific message, then lets EnemyCharacter
# handle the defeat signal and CharacterBase handle queue_free().
# ---------------------------------------------------------------------------

func die() -> void:
	## Override die() to print a boss-specific death message.
	## super() calls EnemyCharacter.die() which emits enemy_defeated
	## and then calls CharacterBase.die() which sets is_dead + queue_free().

	# Guard: EnemyCharacter.die() also has this guard, but we repeat it here
	# so the boss message is never printed twice on the same frame.
	if is_dead:
		return

	print("*** [BossCharacter] BOSS DEFEATED: %s! Dropping %d gold and %d EXP. ***" % [
		display_name, gold_reward, exp_reward
	])

	# Delegate to EnemyCharacter → CharacterBase for signal + cleanup.
	super()
