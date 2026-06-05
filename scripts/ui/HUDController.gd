extends CanvasLayer
class_name HUDController

## Controls the main battle HUD.
## Later this should listen to game signals and update labels when gold, EXP, stage, or wave changes.

@onready var gold_label: Label = $Root/TopBar/GoldLabel
@onready var exp_label: Label = $Root/TopBar/ExpLabel
@onready var wave_label: Label = $Root/TopBar/WaveLabel
@onready var stage_label: Label = $Root/TopBar/StageLabel


func update_gold(value: int) -> void:
	# Later: call this from a gold_changed signal.
	gold_label.text = "Gold: %d" % value


func update_exp(value: int) -> void:
	# Later: call this from an exp_changed signal.
	exp_label.text = "EXP: %d" % value


func update_wave(value: int) -> void:
	# Later: call this when the active wave changes.
	wave_label.text = "Wave: %d" % value


func update_stage(value: String) -> void:
	# Later: call this when the active stage changes.
	stage_label.text = "Stage: %s" % value

