extends CharacterBase
class_name HeroCharacter

## Hero-specific character skeleton.
## Later this will load hero data, search for enemies, and run simple auto-battle AI.


func _physics_process(delta: float) -> void:
	update_attack_cooldown(delta)
	update_ai()


func find_nearest_enemy() -> CharacterBase:
	var nearest_enemy: CharacterBase = null
	var nearest_distance := INF

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not (enemy is CharacterBase):
			continue

		var enemy_character := enemy as CharacterBase
		if enemy_character.is_dead:
			continue

		var distance := global_position.distance_to(enemy_character.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy_character

	return nearest_enemy


func move_to_target(target: CharacterBase) -> void:
	if target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance := global_position.distance_to(target.global_position)
	if distance <= attack_range:
		velocity = Vector2.ZERO
	else:
		var direction := global_position.direction_to(target.global_position)
		velocity = direction * move_speed

	move_and_slide()


func update_ai() -> void:
	if is_dead:
		return

	var target := find_nearest_enemy()
	if target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	move_to_target(target)
	if global_position.distance_to(target.global_position) <= attack_range:
		attack_target(target)
