# Coding Rules

This project is a beginner-friendly Godot 4 idle RPG foundation. Keep changes small and easy to understand.

## Project Rules

- Use GDScript for gameplay code.
- Use JSON files in `res://data/` for tunable game data.
- Keep scenes focused on one responsibility.
- Prefer simple scripts over large manager classes.
- Use Godot signals when different systems need to react to events.
- Do not build full systems before the gameplay foundation is proven.
- Do not put unrelated logic in autoloads.
- Name files and folders in `snake_case` for scripts and data, and `PascalCase` for scenes.

## Script Rules

- One main class per script.
- Keep exported values near the top of the script.
- Use clear comments for beginner-facing intent, not for obvious assignments.
- Avoid deep inheritance. Use composition or scene children when possible.
- Do not hardcode balance values in scripts if they belong in JSON.

## Data Rules

- Keep JSON keys consistent and readable.
- Use stable string IDs, such as `hero_knight` and `enemy_slime`.
- Add new data fields only when a script is ready to use them.

