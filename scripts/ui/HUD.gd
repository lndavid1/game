extends CanvasLayer

## Simple HUD that listens to global game events.

@onready var gold_label: Label = $Root/TopBar/GoldLabel
@onready var exp_label: Label = $Root/TopBar/ExpLabel
@onready var wave_label: Label = $Root/TopBar/WaveLabel


func _ready() -> void:
	GameEvents.gold_changed.connect(_on_gold_changed)
	GameEvents.exp_changed.connect(_on_exp_changed)
	GameEvents.wave_started.connect(_on_wave_started)


func _on_gold_changed(new_amount: int) -> void:
	gold_label.text = "Gold: %d" % new_amount


func _on_exp_changed(new_amount: int) -> void:
	exp_label.text = "EXP: %d" % new_amount


func _on_wave_started(wave_id: String) -> void:
	wave_label.text = "Wave: %s" % wave_id

