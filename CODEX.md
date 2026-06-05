# CODEX.md

Permanent instruction guide for Codex while working on this project.

## 1. Project Overview

- This project is a 2D idle RPG auto-battle game.
- Engine: Godot 4.
- Language: GDScript.
- Target platform: Windows first, Android later.

## 2. Core Gameplay

- Heroes automatically move toward enemies.
- Heroes automatically attack enemies.
- Enemies spawn in waves.
- A boss appears every 10 waves.
- The player earns gold and EXP.
- The player upgrades heroes.
- Offline reward is calculated when returning to the game.

## 3. Coding Rules

- Keep code modular.
- Do not rewrite unrelated files.
- Do not overengineer.
- Use clear comments.
- Use signals for communication between systems.
- Use JSON for game data.
- Keep scripts beginner-friendly.
- Do not create multiplayer or online features yet.

## 4. Folder Rules

- `scenes/` contains Godot scene files. Scenes should represent screens, gameplay areas, actors, UI, or reusable scene components.
- `scripts/` contains GDScript files. Scripts should be organized by responsibility, such as actors, battle, UI, systems, autoloads, and core logic.
- `data/` contains JSON game data. Use this for heroes, enemies, waves, upgrades, rewards, and other balance values.
- `assets/` contains art, audio, fonts, and other imported game assets.
- `docs/` contains project documentation, planning notes, coding rules, and design references.

## 5. Naming Rules

- Scenes use PascalCase.
- Scripts use PascalCase.
- JSON ids use snake_case.
- Signals use snake_case.
- Variables use snake_case.

## 6. Development Rule

Every task must:

- Explain files changed.
- Explain how to test.
- Avoid touching unrelated systems.

## 7. MVP Scope

The first playable version should include:

- 1 map.
- 3 heroes.
- 5 enemies.
- 1 boss.
- 50 waves.
- Auto movement.
- Auto attack.
- Gold.
- EXP.
- Upgrade.
- Save/load.
- Offline reward.

