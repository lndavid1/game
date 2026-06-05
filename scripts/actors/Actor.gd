extends CharacterBody2D
class_name Actor

## Shared starter behavior for heroes and enemies.
## Later, combat targeting and animation should be added in smaller dedicated scripts.

signal died(actor: Actor)

@export var display_name: String = "Actor"
@export var max_hp: int = 1
@export var attack: int = 1
@export var attack_range: float = 32.0
@export var attack_cooldown: float = 1.0
@export var move_speed: float = 50.0

var current_hp: int = 1
var is_dead: bool = false


func _ready() -> void:
	current_hp = max_hp


func apply_data(data: Dictionary) -> void:
	display_name = data.get("display_name", display_name)
	max_hp = int(data.get("max_hp", max_hp))
	attack = int(data.get("attack", attack))
	attack_range = float(data.get("attack_range", attack_range))
	attack_cooldown = float(data.get("attack_cooldown", attack_cooldown))
	move_speed = float(data.get("move_speed", move_speed))
	current_hp = max_hp


func take_damage(amount: int) -> void:
	if is_dead:
		return

	current_hp = max(current_hp - amount, 0)
	if current_hp == 0:
		die()


func die() -> void:
	if is_dead:
		return

	is_dead = true
	died.emit(self)
	queue_free()

