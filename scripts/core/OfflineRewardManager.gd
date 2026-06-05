extends Node
class_name OfflineRewardManager

## Calculates rewards earned while the player was away.
## This should use save timestamps later, but should not own save file logic.


func save_logout_time() -> void:
	# Later: record the current timestamp before the game closes or pauses.
	pass


func calculate_offline_reward() -> Dictionary:
	# Later: compare logout time with current time and calculate gold/EXP.
	return {}


func claim_offline_reward() -> void:
	# Later: apply calculated rewards and notify the UI.
	pass

