extends Node

## RewardManager — listens for enemy defeats and awards gold and exp.
## Connects the combat layer to the persistent GameManager state.

func _ready() -> void:
	# Listen for all enemy defeats in the game.
	GameEvents.enemy_defeated.connect(_on_enemy_defeated)
	print("[RewardManager] Ready. Listening for enemy defeats.")


func _on_enemy_defeated(_enemy_id: String, gold_reward: int, exp_reward: int, is_boss: bool, _death_position: Vector2) -> void:
	## Called whenever any enemy or boss is defeated.
	## Receives the reward values directly from the defeated enemy.
	
	if gold_reward > 0:
		GameManager.add_gold(gold_reward)
		
	if exp_reward > 0:
		GameManager.add_exp(exp_reward)
		
	if is_boss:
		print("Boss reward received: +%d gold, +%d EXP" % [gold_reward, exp_reward])
	else:
		print("Reward received: +%d gold, +%d EXP" % [gold_reward, exp_reward])
		
	# Emit a combined signal so UI or effect systems can show a pop-up.
	if gold_reward > 0 or exp_reward > 0:
		GameEvents.reward_received.emit(gold_reward, exp_reward)
