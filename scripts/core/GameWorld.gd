extends Node2D
class_name GameWorld

## Prototype auto-battle test.
## Spawns one Hero and one Enemy from the scene tree.
## Hero AI runs automatically via HeroCharacter._physics_process.
## No wave system, no rewards UI — this is a minimal gameplay proof of concept.

# References to the container nodes defined in GameWorld.tscn.
@onready var heroes_root: Node2D = $Heroes
@onready var enemies_root: Node2D = $Enemies


func _ready() -> void:
	print("--- [GameWorld] Auto Battle Test Started ---")
	print("[GameWorld] Heroes in scene:  %d" % heroes_root.get_child_count())
	print("[GameWorld] Enemies in scene: %d" % enemies_root.get_child_count())

	# Listen for enemy defeat so we can log the reward drop.
	# The reward system (gold/EXP) will be wired here in a later step.
	GameEvents.enemy_defeated.connect(_on_enemy_defeated)


func _on_enemy_defeated(enemy_id: String, gold_reward: int, exp_reward: int) -> void:
	## Called when any EnemyCharacter dies and emits the defeated signal.
	print("[GameWorld] Enemy defeated: id=%s  gold=%d  exp=%d" % [
		enemy_id, gold_reward, exp_reward
	])
	print("[GameWorld] (Rewards not yet wired to game state — wave system next.)")
