extends CharacterBody2D
class_name CharacterBase

## Shared base class for heroes and enemies.
## Later this will handle common movement, damage, attack timing, and death behavior.

@export var character_id: String = ""
@export var display_name: String = ""
@export var max_hp: int = 1
@export var atk: int = 1
@export var def: int = 0
@export var move_speed: float = 50.0
@export var attack_range: float = 32.0
@export var attack_cooldown: float = 1.0

var current_hp: int = 1
var is_dead: bool = false
var _attack_timer: float = 0.0


func _ready() -> void:
	current_hp = max_hp


func setup_from_data(data: Dictionary) -> void:
	# Reads common stat fields from JSON-style data.
	character_id = data.get("id", character_id)
	display_name = data.get("name", display_name)
	max_hp = int(data.get("base_hp", max_hp))
	atk = int(data.get("base_atk", atk))
	def = int(data.get("base_def", def))
	move_speed = float(data.get("move_speed", move_speed))
	attack_range = float(data.get("attack_range", attack_range))
	attack_cooldown = float(data.get("attack_cooldown", attack_cooldown))
	current_hp = max_hp


func take_damage(amount: int) -> void:
	if is_dead:
		return

	var final_damage := maxi(amount - def, 1)
	current_hp = maxi(current_hp - final_damage, 0)
	print("%s took %d damage. HP: %d/%d" % [display_name, final_damage, current_hp, max_hp])

	if current_hp <= 0:
		die()


func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	print("%s died." % display_name)
	queue_free()


func attack_target(target: CharacterBase) -> void:
	if is_dead or target == null or target.is_dead:
		return
	if _attack_timer > 0.0:
		return

	print("%s attacks %s." % [display_name, target.display_name])
	target.take_damage(atk)
	_attack_timer = attack_cooldown


func update_attack_cooldown(delta: float) -> void:
	if _attack_timer > 0.0:
		_attack_timer = max(_attack_timer - delta, 0.0)
