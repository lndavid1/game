extends CharacterBody2D
class_name CharacterBase

## Shared base class for heroes and enemies.
## Handles stats, damage calculation, attacking, and death.
## Hero AI and Enemy AI are NOT implemented here — those go in subclasses.

# ---------------------------------------------------------------------------
# Exported stats — can be set in the Godot Inspector or via setup_from_data().
# ---------------------------------------------------------------------------

@export var character_id: String = ""
@export var display_name: String = ""
@export var max_hp: int = 1
@export var atk: int = 1
@export var def: int = 0
@export var move_speed: float = 50.0
@export var attack_range: float = 32.0
@export var attack_cooldown: float = 1.0

# ---------------------------------------------------------------------------
# Runtime state — these change during gameplay.
# ---------------------------------------------------------------------------

var current_hp: int = 1
var is_dead: bool = false
var can_attack: bool = true   # Set to false while on attack cooldown.
var _attack_timer: float = 0.0


# ---------------------------------------------------------------------------
# Built-in callbacks
# ---------------------------------------------------------------------------

func _ready() -> void:
	# Start with full HP when the node enters the scene.
	current_hp = max_hp


func _process(delta: float) -> void:
	# Count down the attack cooldown timer every frame.
	_tick_attack_cooldown(delta)


# ---------------------------------------------------------------------------
# Data loading
# ---------------------------------------------------------------------------

func setup_from_data(data: Dictionary) -> void:
	## Load stats from a JSON-style Dictionary (from DataManager).
	## Field names match heroes.json and enemies.json.
	character_id    = data.get("id",               character_id)
	display_name    = data.get("display_name",     display_name)
	max_hp          = int(data.get("max_hp",        max_hp))
	atk             = int(data.get("attack",        atk))
	def             = int(data.get("defense",       def))
	move_speed      = float(data.get("move_speed",  move_speed))
	attack_range    = float(data.get("attack_range", attack_range))
	attack_cooldown = float(data.get("attack_cooldown", attack_cooldown))
	current_hp      = max_hp


# ---------------------------------------------------------------------------
# Combat functions
# ---------------------------------------------------------------------------

func calculate_damage(raw_damage: int) -> int:
	## Subtract DEF from incoming damage, with a minimum of 1.
	## Raw damage is the attacker's ATK value.
	return maxi(raw_damage - def, 1)


func take_damage(amount: int) -> void:
	## Receive damage from an attack.
	## Amount is the raw ATK of the attacker — DEF is applied here.
	if is_dead:
		return

	var final_damage := calculate_damage(amount)
	current_hp = maxi(current_hp - final_damage, 0)

	print("[%s] took %d damage (raw: %d, def: %d). HP: %d / %d" % [
		display_name, final_damage, amount, def, current_hp, max_hp
	])

	if current_hp <= 0:
		die()


func attack_target(target: Node) -> void:
	## Attack another character node.
	## Uses has_method() so this works safely with any Node subclass.
	if is_dead:
		return
	if target == null:
		return
	if not can_attack:
		return
	if not target.has_method("take_damage"):
		push_warning("[%s] attack_target: target has no take_damage method." % display_name)
		return

	# Check if the target is already dead (if it has is_dead property).
	if "is_dead" in target and target.is_dead:
		return

	print("[%s] attacks [%s] for %d ATK." % [display_name, target.name, atk])
	target.take_damage(atk)

	# Start cooldown.
	can_attack = false
	_attack_timer = attack_cooldown


func die() -> void:
	## Mark this character as dead and remove it from the scene safely.
	if is_dead:
		return

	is_dead = true
	can_attack = false
	velocity = Vector2.ZERO

	print("[%s] has died." % display_name)

	# queue_free() safely removes the node at the end of the current frame.
	queue_free()


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

func _tick_attack_cooldown(delta: float) -> void:
	## Counts down the attack timer. Sets can_attack = true when ready.
	if can_attack:
		return

	_attack_timer = maxf(_attack_timer - delta, 0.0)
	if _attack_timer <= 0.0:
		can_attack = true
