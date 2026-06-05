extends CharacterBase
class_name HeroCharacter

## Hero auto-battle AI.
## Finds the nearest enemy, moves toward it, and attacks when in range.
## Cooldown is managed by CharacterBase via can_attack + _attack_timer.
## AI logic runs every physics frame via _physics_process -> update_ai.

# ---------------------------------------------------------------------------
# Built-in callbacks
# ---------------------------------------------------------------------------

func _ready() -> void:
	# Register this hero so enemies and other systems can find it.
	add_to_group("heroes")

	# CharacterBase._ready() sets current_hp = max_hp.
	# Call super() so that initialization still runs.
	super()

	print("[HeroCharacter] spawned: %s  HP:%d  ATK:%d  DEF:%d  SPD:%.0f" % [
		display_name, max_hp, atk, def, move_speed
	])


func _physics_process(delta: float) -> void:
	# Run the full AI loop every physics frame.
	# delta is passed in so subclasses or future systems can use it.
	update_ai(delta)


# ---------------------------------------------------------------------------
# AI loop
# ---------------------------------------------------------------------------

func update_ai(delta: float) -> void:
	## Main AI entry point, called every physics frame.
	## Order: guard -> find target -> move -> attack.

	# Do nothing if already dead.
	if is_dead:
		return

	# Find the closest living enemy.
	var target := find_nearest_enemy()

	# No enemies left — stop moving and wait.
	if target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Move toward the target (stops itself when close enough).
	move_to_target(target)

	# Try to attack if within range and cooldown is ready.
	try_attack(target)


# ---------------------------------------------------------------------------
# Target finding
# ---------------------------------------------------------------------------

func find_nearest_enemy() -> Node2D:
	## Scans the "enemies" group and returns the closest living Node2D.
	## Returns null if no valid target exists.

	var nearest: Node2D = null
	var nearest_dist := INF

	for node in get_tree().get_nodes_in_group("enemies"):
		# Skip anything that is not a 2D node.
		if not node is Node2D:
			continue

		# Skip enemies that are already dead.
		if "is_dead" in node and node.is_dead:
			continue

		# Skip nodes that have been freed but not yet removed from the group.
		if not is_instance_valid(node):
			continue

		var dist := global_position.distance_to((node as Node2D).global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = node as Node2D

	return nearest


# ---------------------------------------------------------------------------
# Movement
# ---------------------------------------------------------------------------

func move_to_target(target: Node2D) -> void:
	## Move toward target until within attack_range, then stop.
	## Always calls move_and_slide() so physics stays in sync.

	var dist := global_position.distance_to(target.global_position)

	if dist <= attack_range:
		# Already in range — stand still.
		velocity = Vector2.ZERO
	else:
		# Walk toward the target at move_speed pixels per second.
		var direction := global_position.direction_to(target.global_position)
		velocity = direction * move_speed

	move_and_slide()


# ---------------------------------------------------------------------------
# Attacking
# ---------------------------------------------------------------------------

func try_attack(target: Node2D) -> void:
	## Attack the target if all conditions are met.
	## Cooldown is handled by CharacterBase (can_attack flag + _attack_timer).
	##
	## NOTE on cooldown design:
	##   Using "await get_tree().create_timer(attack_cooldown).timeout" is a
	##   valid GDScript pattern, but it conflicts with CharacterBase's
	##   _tick_attack_cooldown which runs every _process frame. That function
	##   would immediately reset can_attack to true on the next frame whenever
	##   _attack_timer is 0, causing the await guard to be bypassed.
	##   CharacterBase's timer system is used here because it is already in
	##   place and works correctly inside _physics_process without coroutines.

	# Guard: hero must be alive.
	if is_dead:
		return

	# Guard: target must still be valid and alive.
	if target == null or not is_instance_valid(target):
		return
	if "is_dead" in target and target.is_dead:
		return

	# Guard: must be within melee/ranged reach.
	var dist := global_position.distance_to(target.global_position)
	if dist > attack_range:
		return

	# Guard: cooldown must have expired (set in CharacterBase.attack_target).
	if not can_attack:
		return

	# Everything checks out — delegate to CharacterBase to deal damage
	# and start the attack cooldown (sets can_attack = false, _attack_timer).
	attack_target(target)
