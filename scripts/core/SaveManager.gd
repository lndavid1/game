extends Node
class_name SaveManager

## Handles saving, loading, and resetting player progress.
## Keep file access and save format details contained in this manager.


func save_game() -> void:
	# Later: write player progress to a save file.
	pass


func load_game() -> Dictionary:
	# Later: read player progress from a save file.
	return {}


func reset_save() -> void:
	# Later: clear save data and restore default progress.
	pass

