extends Actor
class_name Enemy

## Starter enemy script with reward values loaded from JSON.

@export var enemy_id: String = "enemy_slime"

var gold_reward: int = 0
var exp_reward: int = 0


func _ready() -> void:
	var data := DataManager.get_enemy(enemy_id)
	if not data.is_empty():
		apply_data(data)
		gold_reward = int(data.get("gold_reward", gold_reward))
		exp_reward = int(data.get("exp_reward", exp_reward))
	else:
		super()


func die() -> void:
	GameEvents.enemy_defeated.emit(enemy_id, gold_reward, exp_reward)
	super()

