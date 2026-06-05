extends Actor
class_name Hero

## Starter hero script.
## Auto-battle targeting will be added after the battle loop is proven.

@export var hero_id: String = "hero_knight"


func _ready() -> void:
	var data := DataManager.get_hero(hero_id)
	if not data.is_empty():
		apply_data(data)
	else:
		super()

	GameEvents.hero_spawned.emit(self)


func move_toward_target(target_position: Vector2, delta: float) -> void:
	var direction := global_position.direction_to(target_position)
	velocity = direction * move_speed
	move_and_slide()

