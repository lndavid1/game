# Technical Design

This document describes the planned technical architecture before gameplay coding begins.

## 1. Engine

- Godot 4.

## 2. Language

- GDScript.

## 3. Main Architecture

### GameManager

Owns high-level game flow. It should track the current state of the game, coordinate major systems, and respond to events such as starting a stage, clearing a wave, or returning from offline time.

### DataManager

Loads static game data from JSON files in `res://data/`. It should provide simple lookup functions for heroes, enemies, skills, items, and stages.

### SaveManager

Handles saving and loading player progress. It should keep save logic separate from gameplay logic so other systems can request saved values without knowing file details.

### OfflineRewardManager

Calculates rewards based on `last_logout_timestamp` and the player's current progress. It should prepare rewards when the game opens, then let the UI show a claim popup.

### WaveManager

Controls wave progression. It should spawn enemies, detect when a wave is cleared, trigger boss waves, and tell the reward system when rewards should be granted.

### Combat System

Handles automatic movement, target selection, attacks, cooldowns, damage, death, and simple skill usage. The first version should stay simple and readable.

### Character System

Defines shared character behavior for heroes and enemies. A common base script should handle stats, HP, damage, and death, while hero and enemy scripts handle their specific behavior.

### UI System

Displays player information and game actions. UI should listen to signals such as gold, EXP, wave, upgrades, and offline rewards instead of directly controlling combat logic.

## 4. Scene Architecture

### Main.tscn

Root scene for the game. It should load the game world and main UI, and act as the entry point for the project.

### GameWorld.tscn

Main gameplay world. It should contain the battlefield, wave spawn points, heroes, enemies, and world-level managers needed for battle.

### Hero.tscn

Reusable hero scene. It should contain visuals, collision, animation nodes, and a hero script that loads hero data from JSON.

### Enemy.tscn

Reusable enemy scene. It should contain visuals, collision, animation nodes, and an enemy script that loads enemy data and reward values from JSON.

### MainHUD.tscn

Main battle UI. It should show gold, EXP, current stage, current wave, boss status, and buttons for upgrades or other panels.

### UpgradePanel.tscn

UI panel for upgrading heroes. It should show hero stats, upgrade costs, and upgrade buttons.

### OfflineRewardPopup.tscn

Popup shown when the player returns after being away. It should display calculated gold and EXP rewards and allow the player to claim them.

## 5. Data Architecture

### heroes.json

Stores hero definitions such as ID, display name, base stats, attack range, attack cooldown, movement speed, and starting skill IDs.

### enemies.json

Stores enemy definitions such as ID, display name, stats, movement speed, reward values, and enemy type.

### skills.json

Stores skill definitions such as ID, display name, damage value, cooldown, target rule, and visual effect reference.

### items.json

Stores item definitions such as ID, display name, item type, stat bonuses, rarity, and icon path.

### stages.json

Stores stage and wave data such as stage ID, map name, wave count, enemy groups, boss wave rules, and reward scaling.

## 6. Save Data Structure

The save file should store:

- `gold`
- `exp`
- `current_stage`
- `current_wave`
- `hero_levels`
- `inventory`
- `last_logout_timestamp`

Example shape:

```json
{
  "gold": 0,
  "exp": 0,
  "current_stage": "stage_001",
  "current_wave": 1,
  "hero_levels": {
    "hero_knight": 1
  },
  "inventory": [],
  "last_logout_timestamp": 0
}
```

## 7. Signal Plan

Useful signals:

- `gold_changed`
- `exp_changed`
- `wave_started`
- `wave_cleared`
- `boss_spawned`
- `enemy_died`
- `hero_upgraded`
- `save_loaded`
- `offline_reward_ready`

Signals should be used when one system needs to notify another without creating tight dependencies.

## 8. Development Order

1. Project setup.
2. CharacterBase.
3. Hero.
4. Enemy.
5. Auto combat.
6. Wave system.
7. Reward system.
8. Upgrade system.
9. Save/load.
10. Offline reward.
11. UI polish.

