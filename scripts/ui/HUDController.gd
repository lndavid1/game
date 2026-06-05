extends CanvasLayer
class_name HUDController

## Controls the main battle HUD.
## Later this should listen to game signals and update labels when gold, EXP, stage, or wave changes.

@onready var gold_label: Label = $Root/TopBar/GoldLabel
@onready var exp_label: Label = $Root/TopBar/ExpLabel
@onready var wave_label: Label = $Root/TopBar/WaveLabel
@onready var stage_label: Label = $Root/TopBar/StageLabel


func _ready() -> void:
	# Connect global signals to local UI update functions
	GameEvents.gold_changed.connect(update_gold)
	GameEvents.exp_changed.connect(update_exp)
	GameEvents.wave_started.connect(update_wave)
	
	# Initialize HUD with starting values from GameManager
	update_gold(GameManager.gold)
	update_exp(GameManager.exp)
	update_wave(GameManager.current_wave)
	update_stage(GameManager.current_stage)


func update_gold(value: int) -> void:
	gold_label.text = "Gold: %d" % value


func update_exp(value: int) -> void:
	exp_label.text = "EXP: %d" % value


func update_wave(value: int) -> void:
	wave_label.text = "Wave: %d" % value


func update_stage(value: String) -> void:
	stage_label.text = "Stage: %s" % value
