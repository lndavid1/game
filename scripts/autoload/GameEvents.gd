extends Node

## Central place for cross-system signals.
## Keep this small: only add signals when multiple systems need the same event.

signal gold_changed(new_amount: int)
signal exp_changed(new_amount: int)
signal wave_started(wave_id: String)
signal wave_cleared(wave_id: String)
signal hero_spawned(hero: Node)
signal enemy_defeated(enemy_id: String, gold_reward: int, exp_reward: int)
signal offline_rewards_claimed(gold_reward: int, exp_reward: int)

