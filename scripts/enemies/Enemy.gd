extends CharacterBase
class_name EnemyCharacter

## Enemy-specific character skeleton.
## Later this will load enemy data, search for heroes, and run simple auto-battle AI.


func find_nearest_hero() -> CharacterBase:
	var nearest_hero: CharacterBase = null
	var nearest_distance := INF

	for hero in get_tree().get_nodes_in_group("heroes"):
		if not (hero is CharacterBase):
			continue

		var hero_character := hero as CharacterBase
		if hero_character.is_dead:
			continue

		var distance := global_position.distance_to(hero_character.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_hero = hero_character

	return nearest_hero


func update_ai() -> void:
	# Enemy AI will be added after the first hero attack loop is stable.
	pass
