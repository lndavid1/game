extends Label
class_name FloatingText

## FloatingText — displays temporary text that moves upward and fades out.

@export var float_speed: float = 50.0
@export var duration: float = 1.5

var _timer: float = 0.0

func _ready() -> void:
	# Ensure the text is centered on the spawn position.
	set_anchors_preset(Control.PRESET_CENTER)
	
	# Create a tween for the fade-out effect.
	var tween = create_tween()
	# Wait for half the duration before starting the fade.
	tween.tween_interval(duration * 0.5)
	# Fade out over the remaining half.
	tween.tween_property(self, "modulate:a", 0.0, duration * 0.5)

func _process(delta: float) -> void:
	_timer += delta
	
	# Move upwards.
	global_position.y -= float_speed * delta
	
	# Remove when duration is reached.
	if _timer >= duration:
		queue_free()

func setup(text_to_show: String, start_pos: Vector2, color: Color = Color.WHITE) -> void:
	text = text_to_show
	global_position = start_pos
	modulate = color
