extends Node
class_name OfflineRewards

## Placeholder for future offline rewards.
## Keep this simple until save data and reward pacing are designed.

const MAX_OFFLINE_SECONDS := 8 * 60 * 60


func calculate_rewards(seconds_away: int) -> Dictionary:
	var clamped_seconds := clampi(seconds_away, 0, MAX_OFFLINE_SECONDS)
	var reward_minutes := int(clamped_seconds / 60)

	return {
		"gold": reward_minutes,
		"exp": int(reward_minutes / 2)
	}
