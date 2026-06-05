extends Panel
class_name UpgradePanel

## Placeholder controller for the hero upgrade panel.
## Later this should display selected hero stats and request upgrades through the upgrade system.

@onready var hero_name_label: Label = $Content/HeroNameLabel
@onready var upgrade_cost_label: Label = $Content/UpgradeCostLabel


func show_hero_info(hero_data: Dictionary) -> void:
	# Later: fill in all visible hero stats from JSON/save data.
	hero_name_label.text = "Hero: %s" % hero_data.get("name", "Unknown")


func update_upgrade_cost(cost: int) -> void:
	# Later: refresh this when hero level or upgrade rules change.
	upgrade_cost_label.text = "Cost: %d gold" % cost


func on_upgrade_button_pressed() -> void:
	# Later: request an upgrade for the selected hero.
	pass

