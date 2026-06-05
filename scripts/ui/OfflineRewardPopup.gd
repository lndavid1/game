extends Panel
class_name OfflineRewardPopup

## Placeholder controller for offline rewards.
## Later this should show calculated rewards and notify the reward system when claimed.

@onready var gold_label: Label = $Content/GoldRewardLabel
@onready var exp_label: Label = $Content/ExpRewardLabel
@onready var items_label: Label = $Content/ItemsRewardLabel


func show_reward(gold: int, exp: int, items: Array) -> void:
	# Later: show item icons or names instead of a simple count.
	gold_label.text = "Gold: %d" % gold
	exp_label.text = "EXP: %d" % exp
	items_label.text = "Items: %d" % items.size()
	show()


func on_claim_button_pressed() -> void:
	# Later: apply rewards to the player save and close the popup.
	hide()

