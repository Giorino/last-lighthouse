# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Last Lighthouse** is a hybrid roguelike survivor-shooter + tower defense game built in Godot 4.5. The core concept combines **Vampire Survivors-style auto-combat** with **They Are Billions tower defense mechanics** and **Dead Cells-style roguelike progression**. Players defend a lighthouse against endless waves while actively fighting with auto-aim weapons, collecting XP to level up mid-run, and building defensive structures during short day phases.

**Key Details:**
- Engine: Godot 4.5 (GDScript primary language)
- Genre: Roguelike Survivor-Shooter + Tower Defense + Resource Management
- Core Gameplay: Auto-aim combat + In-run leveling + Structure building + Endless survival
- Art Style: Atmospheric pixel art (320x180 base resolution, scaled 6x to 1920x1080)
- Target: PC (Windows, macOS, Linux) via Steam

**Hybrid Game Loop (NEW DESIGN - Phase 5):**
```
Night Wave (enemies attack, player fights with auto-aim weapons)
    ↓
Collect XP gems from dead enemies → Level up → Choose upgrade (weapon/stat/ability)
    ↓
Short Day Phase (30 seconds - build structures with resources)
    ↓
Repeat endlessly until player dies or lighthouse is destroyed
```

**No Win Condition:** Game is endless survival - the goal is to survive as long as possible and reach the highest night.

## Development Commands

### Running the Project
- Open the project in Godot Editor and run from there (F5)
- Command line: `godot --path . --verbose` (if godot is in PATH)

### Testing
- No automated test framework currently configured
- Test individual scenes by running them directly (F6 in Godot)
- Create test scenes in `tools/` directory for component testing

### Asset Management
- Godot automatically imports assets placed in the project
- Check `.godot/imported/` for import errors
- Force reimport: Delete `.godot/imported/` and reopen project

## MCP Tools & Integrations

Claude Code has access to specialized MCP (Model Context Protocol) servers that provide enhanced capabilities for this project.

### Godot MCP

Direct integration with Godot Engine for project management and development tasks.

**Available Tools:**
- `mcp__godot__get_godot_version` - Get installed Godot version
- `mcp__godot__get_project_info` - Retrieve project metadata and structure
- `mcp__godot__list_projects` - Find Godot projects in a directory
- `mcp__godot__launch_editor` - Launch Godot editor for the project
- `mcp__godot__run_project` - Run the project and capture output
- `mcp__godot__get_debug_output` - Get current debug output and errors
- `mcp__godot__stop_project` - Stop currently running project
- `mcp__godot__create_scene` - Create new scene files programmatically
- `mcp__godot__add_node` - Add nodes to existing scenes
- `mcp__godot__load_sprite` - Load sprites into Sprite2D nodes
- `mcp__godot__save_scene` - Save scene changes
- `mcp__godot__export_mesh_library` - Export scenes as MeshLibrary resources
- `mcp__godot__get_uid` - Get file UIDs (Godot 4.4+)
- `mcp__godot__update_project_uids` - Update UID references (Godot 4.4+)

**Usage Examples:**
```
# Get project information
mcp__godot__get_project_info(projectPath: "/path/to/project")

# Create a new scene
mcp__godot__create_scene(
  projectPath: "/path/to/project",
  scenePath: "scenes/enemies/new_enemy.tscn",
  rootNodeType: "CharacterBody2D"
)

# Run the project
mcp__godot__run_project(projectPath: "/path/to/project")
```

**When to Use:**
- Querying project structure and metadata
- Creating/modifying scenes programmatically
- Running and debugging the game
- Managing UIDs for resource references

### Context7 MCP

Provides access to up-to-date documentation for libraries and frameworks, including Godot Engine.

**Available Tools:**
- `mcp__context7__resolve-library-id` - Find Context7-compatible library ID for a package/library
- `mcp__context7__get-library-docs` - Fetch current documentation for a library

**Usage Workflow:**
1. First, resolve the library ID:
   ```
   mcp__context7__resolve-library-id(libraryName: "godot")
   # Returns: /godotengine/godot (with available versions)
   ```

2. Then fetch documentation for specific topics:
   ```
   mcp__context7__get-library-docs(
     context7CompatibleLibraryID: "/godotengine/godot/4_5_stable",
     topic: "signals and EventBus",
     tokens: 2000
   )
   ```

**When to Use:**
- Need current Godot Engine documentation
- Looking for code examples for specific features
- Researching how to implement Godot-specific patterns
- Finding documentation for third-party Godot plugins
- Working with other libraries/frameworks in the project

**Available Godot Documentation Sources:**
- `/godotengine/godot/4_5_stable` - Official Godot 4.5 docs (recommended)
- `/websites/godotengine_en_4_5` - Web-based Godot 4.5 docs
- `/godotengine/godot-cpp` - GDExtension C++ bindings
- Various Godot plugin docs (GUT, GodotSteam, etc.)

**Best Practices:**
- Always use Context7 when you need up-to-date API information
- Specify version (`/godotengine/godot/4_5_stable`) to match project Godot version
- Use focused topics for better results (e.g., "NavigationServer2D" vs "navigation")
- Adjust token limit based on complexity (500-2000 typical range)

## Architecture & Code Principles

### Godot-Specific Patterns

**Autoload Singletons (in project.godot order):**
1. `Constants` - Game constants and enums
2. `EventBus` - Global signal bus for decoupled communication
3. `SaveManager` - Persistent save/load system
4. `AudioManager` - Sound and music management
5. `ResourceManager` - In-game resource tracking (wood, metal, stone, fuel)
6. `GameManager` - Core game state and flow control

**Signal-Driven Architecture:**
- Use signals extensively for component communication
- Example: `signal health_changed(current: int, max: int)`
- Connect systems via EventBus for global events
- Avoid direct node references when signals suffice

**Composition Over Inheritance:**
- Prefer Component pattern over deep inheritance trees
- Use separate nodes for behaviors (e.g., HealthComponent, DamageComponent)
- Base classes (enemy.gd, structure.gd, keeper.gd) provide minimal shared functionality

### Code Style

**Naming Conventions:**
```gdscript
# Use descriptive names, avoid abbreviations
var current_health: int  # Good
var hp: int              # Avoid

# Enums for state management
enum Phase { DAY, TRANSITION, NIGHT }
var current_phase: Phase = Phase.DAY

# Signal naming: past tense for completed actions
signal enemy_died
signal wave_completed
signal health_changed
```

**File Organization:**
- Scripts live in `scripts/` (not alongside scenes)
- Scenes live in `scenes/` organized by type
- Data resources (`.tres`) live in `data/`
- Match file names to class names: `keeper.gd` defines `class_name Keeper`

**Performance Considerations:**
- Cache node references in `@onready var` or `_ready()`
- Use object pooling for frequently spawned objects (bullets, particles)
- Prefer `queue_free()` over immediate `free()`
- Avoid `get_node()` calls in `_process()` or `_physics_process()`

## Core Systems Architecture

### Day/Night Cycle
Central game loop managed by `DayNightCycle` class:
- Day Phase: 300s (exploration, gathering, building)
- Transition: 10s (shop overlay, preparations)
- Night Phase: 180-300s (wave-based defense)
- Uses signals to coordinate phase changes across systems

### Resource System
Four resource types tracked by `ResourceManager` autoload:
- **Wood** - Common, basic structures
- **Metal** - Uncommon, advanced defenses
- **Stone** - Common, walls
- **Fuel** - Rare, lighthouse beam power

Resources are gathered from nodes during day phase, spent during building.

### Building System
Grid-based placement (16x16 tile grid):
- Ghost preview shows valid/invalid placement
- Instant construction (resources consumed immediately)
- Structures have health, can be damaged and repaired
- Key structures: Wall, Barricade, Turret, Trap, Generator

### Enemy System
AI uses A* pathfinding to lighthouse:
- State machine: PATHFINDING → ATTACKING → STUNNED
- Path recalculation when blocked
- Wave-based spawning with budget system
- Enemy types: Crawler, Spitter, Brute, Swarm, Bosses

### Lighthouse System
Central objective and defensive mechanic:
- Primary win condition: Keep lighthouse alive
- Special ability: Beam (stuns enemies, drains fuel)
- Takes damage from enemy attacks
- Can be repaired during day phase

### Keeper (Player) System
Four unlockable keepers with unique abilities:
- **Engineer** (starter) - Cheaper/faster building
- **Soldier** - Combat bonuses, turret access
- **Scavenger** - Better loot, faster movement
- **Medic** - Lighthouse regeneration, repair bonuses

## Important Implementation Details

### Scene Inheritance
Use scene inheritance for entity variants:
- Base scenes define common structure
- Inherited scenes override specific properties
- Example: `enemy_base.tscn` → `crawler.tscn`, `spitter.tscn`

### Pathfinding Setup
- Use Godot's NavigationServer2D or AStar2D
- Grid-based navigation matching building grid (16x16)
- Update navigation mesh when structures placed/destroyed
- Enemies recalculate paths when blocked

### Save System
- Save location: `user://savegame.save`
- Auto-save after each night
- Track meta-progression separately from run data
- Use `FileAccess.open()` with `WRITE`/`READ` modes

### Procedural Generation
Map generation happens at run start:
- Lighthouse always centered
- 8-12 ruined buildings (explorable)
- 4-6 resource nodes per type
- 4-8 enemy spawn points at edges
- Seeded random for consistency

## Common Pitfalls

**Godot-Specific:**
- Don't initialize game state in `_ready()` - use explicit init methods
- Don't forget to set process mode for pause functionality
- Don't use `get_tree().reload_current_scene()` - breaks autoload state
- Always check `is_instance_valid()` before accessing cached references
- Use `call_deferred()` when adding/removing nodes during physics/process

**Performance:**
- Avoid hundreds of individual collision shapes - use TileMap collision layers
- Particle systems can tank FPS - set reasonable max particles
- Use CanvasItem visibility for culling off-screen entities
- Profile with Godot's built-in profiler before optimizing

**Architecture:**
- Don't couple systems directly - use EventBus signals
- Don't put UI logic in gameplay scripts
- Don't hard-code resource paths - use `preload()` or exports
- Keep autoloads minimal - not every manager needs global access

## Project-Specific Conventions

### Pixel Art Requirements
- Base resolution: 320x180
- All sprites must snap to pixel grid
- Use 6x integer scaling for display
- Pixel-perfect rendering: Enable in project settings

### Wave Balance Formula
```gdscript
# Enemy budget scales with night number
var enemy_budget = night_number * 10
var wave_count = ceili(night_number / 5.0)
```

### Resource Costs Pattern
Structure costs defined as Dictionary:
```gdscript
@export var costs: Dictionary = {
    Constants.ResourceType.WOOD: 10,
    Constants.ResourceType.METAL: 15
}
```

## Key Files Reference

**Documentation:**
- `README.md` - Comprehensive game design document (primary reference)
- `.cursorrules` - Cursor-specific development guidelines
- `docs/GAME_DESIGN.md` - Detailed mechanics (if exists)
- `docs/TECHNICAL_SPEC.md` - Implementation specifics (if exists)

**Configuration:**
- `project.godot` - Godot project settings, autoloads defined here
- `.gitignore` - Excludes .godot/ and build artifacts

**Current Status:**
Phase 1 prototype is functional and playable. Core systems are implemented with placeholder graphics. See "Implementation Progress" section below for detailed status.

## Implementation Progress

### Phase 1 ✅ COMPLETE
- **Core Loop:** Day(300s) → Transition(30s) → Night(waves) cycle working
- **Systems:** 4 autoloads, pathfinding (A*), combat, building, resource management
- **Content:** 1 enemy (Crawler), 1 structure (Wall), player with beam ability
- **Status:** Functional with placeholders, all base mechanics operational

### Phase 2 ✅ COMPLETE
- **Enemies:** +Spitter (ranged/150rng), +Brute (tank/1.5x structure dmg), +Swarm (fast/100spd)
- **Structures:** +Barricade (cheap), +Turret (auto-aim), +Trap (trigger dmg), +Generator (powers turrets)
- **Wave System:** Budget-based composition, scales by night (N1-5: crawlers only → N16+: all types)
- **Repair:** Hold R near structure, costs 50% original, 2s channel
- **Build UI:** Keys 1-5 select structures, red/green ghost validation
- **Managers:** SaveManager (meta-progression/unlocks), AudioManager (ready for assets)
- **Files:** +32 scripts/scenes total

### Phase 3 ✅ COMPLETE
- **Keepers:** +Soldier (120HP/combat), +Scavenger (130spd/gathering), +Medic (heal lighthouse)
- **Abilities:** F key activates unique keeper abilities (30s cooldown)
  - Soldier: Rally (boost turret attack speed 2x/10s)
  - Scavenger: Sixth Sense (reveal resource nodes)
  - Medic: Emergency Heal (restore lighthouse 50% HP)
- **Pause Menu:** ESC to pause/resume, quit option
- **Game Over Screen:** Shows night reached, enemies killed, resources, tokens earned
- **Files:** +3 keeper scripts/scenes, pause menu, game over screen

### Phase 4 🎨 IN PROGRESS (Polish & Juice)
- **Particle Systems:** ✅ Hit effects, death explosions, muzzle flash, build particles
- **Camera Juice:** ✅ Trauma-based screen shake, smooth follow, zoom support
- **Hit Pause:** ✅ Freeze frames on impacts (light/medium/heavy)
- **Visual Effects Manager:** ✅ Centralized particle spawning system
- **Time Scale Manager:** ✅ Hit pause and slow-motion support
- **Integration:** ✅ Particles + shake on all combat events, building, destruction
- **Art Pipeline:** ✅ Asset structure documented in `docs/ART_ASSET_GUIDE.md`
- **Status:** Technical juice systems complete, ready for art/audio assets
- **Files:** +4 particle scenes, CameraController, VisualEffectsManager, TimeScaleManager

### Current Controls
- **1-5:** Select/build structures | **R:** Repair | **B:** Toggle build | **Space:** Beam | **F:** Keeper ability | **ESC:** Pause | **WASD:** Move | **E:** Interact

### Next Priorities (Phase 4 Completion)
- Add sound effects (combat, building, UI, ambient)
- Add music tracks (day/night themes)
- Polish camera bounds and follow behavior
- Add more particle variety (blood, sparks, smoke)

### Phase 5 🔫 IN PROGRESS (Hybrid Combat & Leveling System)
**MAJOR DESIGN PIVOT:** Transforming from pure tower defense into **Vampire Survivors + Tower Defense hybrid**

---

## Design Rationale & User Vision

**User's Core Idea:**
"Like Vampire Survivors or Brotato, we should have levels when we play. Collect XP from ground that enemies drop, level up, and choose upgrades with keeper tokens. Remove win condition for endless survival. Player should shoot based on character choice with auto-aim. Different characters deal different damage and have different attack types."

**Key User Requirements (IMPORTANT - READ THIS):**
1. ✅ **KEEP building structures** - Don't remove the tower defense aspect
2. ✅ **KEEP day/night cycle** - But modify it significantly
3. ✅ **KEEP resource gathering** - Resources drop from enemies now
4. ✅ **NO win condition** - Endless survival, secure the lighthouse as long as possible
5. ✅ **Auto-aim combat** - Player attacks must be automatic (like Vampire Survivors)
6. ✅ **In-run leveling** - Level up during the run, choose upgrades (NOT just meta-progression)
7. ✅ **Multiple weapon slots** - Start with 6 slots, 1 filled, gain more through leveling
8. ✅ **Class-based weapons** - Each keeper has unique starting weapon and damage scaling

**What Makes This Unique:**
- **Not pure Vampire Survivors** - We have building phase and structures
- **Not pure tower defense** - Player actively fights with auto-aim weapons
- **Hybrid gameplay loop** - Active combat (night) + Strategic building (day) + In-run progression (leveling)

---

## Modified Day/Night Cycle (CRITICAL CHANGE)

**OLD SYSTEM (Phases 1-4):**
```
Day (300s) → Transition (10s) → Night (180-300s) → Day → repeat
```

**NEW SYSTEM (Phase 5+):**
```
START → Night 1 (60s wave) → Day 1 (30s prep) → Night 2 (90s wave) → Day 2 (30s) → Night 3 (120s) → repeat
```

**Specific Changes:**
- **Start with night** (not day) - Short first wave to ease player in
- **Day phase is now 30 seconds** (down from 300s) - Just enough time to build 1-2 structures
- **Night duration increases progressively:**
  - Night 1: 60 seconds
  - Night 2: 90 seconds
  - Night 3: 120 seconds
  - Night 4: 150 seconds
  - Night 5+: 180 seconds (capped at 3 minutes)
- **No transition phase** - Direct Night → Day → Night switching
- **Day phase purpose:** Quickly build defenses with resources gathered during night

**Why This Works:**
- Day becomes a "breather" to spend resources, not a long exploration phase
- Player is mostly in combat (engaging, like VS)
- Building is strategic (plan defenses quickly)
- Resources come from combat, not scavenging

---

## Weapon System (NEW - Core Feature)

**Architecture:**
```gdscript
# Each keeper has WeaponManager component
class_name WeaponManager extends Node

var weapon_slots: Array[Weapon] = []  # Max 6 slots
var max_slots: int = 6

func _process(delta: float):
    for weapon in weapon_slots:
        if weapon:
            weapon.try_fire(delta)  # Each weapon auto-fires independently
```

**Weapon Base Class:**
```gdscript
class_name Weapon extends Node2D

# Core stats
@export var weapon_name: String = "Pistol"
@export var damage: int = 10
@export var fire_rate: float = 1.0  # attacks per second
@export var range: float = 150.0
@export var projectile_speed: float = 300.0
@export var projectile_count: int = 1  # Can shoot multiple projectiles

# Auto-aim logic
func try_fire(delta: float):
    cooldown_timer -= delta
    if cooldown_timer <= 0:
        var target = find_nearest_enemy()
        if target:
            fire_at_target(target)
            cooldown_timer = 1.0 / fire_rate

func find_nearest_enemy() -> Enemy:
    # Get all enemies in range
    # Return closest one
```

**Starting Weapons (One Per Keeper):**
1. **Engineer - Wrench Throw**
   - Damage: 25
   - Fire Rate: 0.8/s (slower)
   - Range: 80 (melee range)
   - Projectile: Spinning wrench that returns like boomerang
   - Theme: High damage, close range, safe/reliable

2. **Soldier - Rifle**
   - Damage: 15
   - Fire Rate: 1.5/s (medium)
   - Range: 200 (long range)
   - Projectile: Bullet with muzzle flash
   - Theme: Balanced, long range, military

3. **Scavenger - Dual Pistols**
   - Damage: 8
   - Fire Rate: 3.0/s (very fast)
   - Range: 120 (medium range)
   - Projectile: Alternating left/right pistol shots
   - Theme: Fast, aggressive, spray damage

4. **Medic - Healing Bolt**
   - Damage: 10
   - Fire Rate: 1.0/s
   - Range: 150
   - Projectile: Green energy bolt
   - Special: On hit, has 30% chance to heal nearest structure for 5 HP
   - Theme: Support, dual-purpose

**Weapon Progression:**
- Level up → Choose "New Weapon" option → Get random weapon from pool
- Fill all 6 slots for maximum DPS
- Can also upgrade existing weapons (damage, fire rate, projectiles, range)

---

## XP & Leveling System (NEW - Core Feature)

**XP Gem Drops:**
```gdscript
# When enemy dies:
func die():
    # ... existing death logic ...
    spawn_xp_gem(xp_value)

# XP values by enemy type:
- Crawler: 5 XP
- Spitter: 8 XP
- Brute: 15 XP
- Swarm: 3 XP (but spawns in groups)
- Boss: 50 XP
```

**XP Gem Behavior:**
- Small glowing orb (different color per value?)
- Stays on ground for 30 seconds, then fades
- Auto-magnet toward player when within 40 pixels
- Pickup is automatic (just walk over it)
- Visual/audio feedback on collection

**Leveling Curve:**
```gdscript
# Formula: base_xp * (level ^ 1.5)
func get_xp_for_level(level: int) -> int:
    return int(10 * pow(level, 1.5))

# Results:
Level 1: 10 XP
Level 2: 28 XP  (cumulative: 38)
Level 3: 52 XP  (cumulative: 90)
Level 4: 80 XP  (cumulative: 170)
Level 5: 112 XP (cumulative: 282)
... (scales exponentially)
```

**Level-Up Flow:**
1. XP bar fills to threshold
2. Level up triggered
3. **Game pauses** (Engine.time_scale = 0.0) OR **slows heavily** (0.1)
4. UI overlay appears with 3 random upgrade choices
5. Player clicks one option
6. Upgrade applied immediately
7. Game resumes
8. Visual feedback (level-up particle burst, sound effect)

**Upgrade Pool (Initial Set):**
```gdscript
# Weapon-related (60% weight)
- "New Weapon" (if slots < 6)
- "+20% Damage" (all weapons)
- "+30% Fire Rate" (all weapons)
- "+1 Projectile" (all weapons shoot one extra)
- "+30% Range" (all weapons)

# Stat upgrades (30% weight)
- "+10% Movement Speed"
- "+20 Max HP"
- "+5 HP Regen per second"

# Economy (10% weight)
- "+25% Resource Drop Rate"
- "-10% Build Costs"

# Later: Structure blueprints (Phase 6+)
```

**UI Design:**
```
╔═══════════════════════════════════════╗
║           LEVEL UP! (Level 5)         ║
╠═══════════════════════════════════════╣
║                                       ║
║  ┌───────────┐ ┌───────────┐ ┌──────────┐
║  │ NEW WEAPON│ │ +20% DMG  │ │ +10% SPD │
║  │           │ │           │ │          │
║  │  Shotgun  │ │ All Wpns  │ │ Movement │
║  │ [Icon]    │ │ [Icon]    │ │ [Icon]   │
║  └───────────┘ └───────────┘ └──────────┘
║       [CLICK TO CHOOSE]                ║
╚═══════════════════════════════════════╝
```

---

## Resource Drop System (MODIFIED)

**OLD:** Resources gathered from nodes during day phase
**NEW:** Resources drop from enemies during night combat

**Drop Rates:**
```gdscript
func die():
    spawn_xp_gem(xp_value)  # Always

    # Random resource drops
    if randf() < 0.20:  # 20% chance
        spawn_resource(ResourceType.WOOD, randi_range(2, 5))

    if randf() < 0.10:  # 10% chance
        spawn_resource(ResourceType.METAL, randi_range(1, 3))

    if randf() < 0.05:  # 5% chance
        spawn_resource(ResourceType.STONE, randi_range(1, 2))
```

**Resource Pickup Behavior:**
- Small glowing items (Wood = brown, Metal = gray, Stone = white)
- Auto-collect on player contact (like XP gems)
- Persist longer than XP (60 seconds before fading)
- Visual distinction from XP gems

**Why This Works:**
- Combat is rewarding (get resources AND xp)
- No need for long scavenging phase
- Resource nodes can be removed OR repurposed as static bonuses

---

## Endless Survival (Win Condition Removed)

**OLD:** Survive 20 nights OR reach target → Victory screen
**NEW:** No victory condition, only defeat conditions

**Game Over Triggers:**
1. Player dies (keeper HP reaches 0)
2. Lighthouse destroyed (lighthouse HP reaches 0)

**Goal:** Survive as many nights as possible, reach highest night number

**Leaderboard/Stats Tracking:**
- Highest night reached
- Total enemies killed
- Total XP gained
- Most powerful weapon combo
- Most resources collected

**Meta-Progression Still Exists:**
- Keeper Tokens earned based on performance (1 per night + bonuses)
- Spent in permanent upgrade shop between runs
- Unlock new keepers, starting bonuses, etc.

---

## Implementation Checklist

**Phase 5A - Core Combat:**
- [x] Create Weapon base class (`scripts/weapons/weapon.gd`)
- [x] Create WeaponManager component for Keeper
- [x] Implement auto-aim targeting system
- [x] Create 4 starting weapons (one per keeper)
- [x] Add weapon firing and projectile spawning
- [x] Test weapon slot system (add/remove weapons)

**Phase 5B - XP & Leveling:**
- [x] Create XP gem entity (`scripts/pickups/xp_gem.gd`)
- [x] Add XP drop logic to Enemy.die()
- [x] Create LevelManager autoload
- [x] Implement XP tracking and leveling curve
- [x] Build level-up UI scene
- [x] Create upgrade pool system
- [x] Test level-up flow (pause, choose, resume)

**Phase 5C - Integration:**
- [x] Add resource drop logic to Enemy.die() (implemented as auto-collect for now)
- [ ] Modify DayNightCycle timings (start with night, 30s day)
- [ ] Remove win condition checks from GameManager
- [ ] Update HUD to show weapon slots and XP bar
- [ ] Balance tuning (XP values, weapon stats, drop rates)
- [ ] Add visual/audio feedback for pickups and level-ups

**Phase 5D - Polish:**
- [ ] Add weapon icons/UI
- [ ] Particle effects for level-up
- [ ] Sound effects for pickups
- [ ] Test full gameplay loop
- [ ] Update CLAUDE.md progress log

---

## Progress Log (Phase 5)

**Format:** `[Date] - Feature - Files Changed - Notes`

```
[2025-11-02] - Weapon Base Class - scripts/weapons/weapon.gd - Created auto-aim targeting system with find_nearest_enemy(), fire_at_target() with multi-projectile support, upgrade application system

[2025-11-02] - WeaponManager Component - scripts/weapons/weapon_manager.gd - Created weapon slot manager (6 slots), auto-fire loop in _process(), upgrade multiplier system (damage/fire rate/range), add/remove weapon functions

[2025-11-02] - Keeper Weapon Integration - scripts/entities/keeper.gd - Added weapon_manager property, instantiate WeaponManager in _ready(), added add_starting_weapon() function

[2025-11-02] - Engineer Starting Weapon - scripts/weapons/weapon_wrench.gd, keeper.gd - Wrench weapon (25 dmg, 0.8 fire rate, 80 range), added to base keeper

[2025-11-02] - Soldier Starting Weapon - scripts/weapons/weapon_rifle.gd, keeper_soldier.gd - Rifle weapon (15 dmg, 1.5 fire rate, 200 range), added to Soldier keeper

[2025-11-02] - Scavenger Starting Weapon - scripts/weapons/weapon_pistols.gd, keeper_scavenger.gd - Dual Pistols (8 dmg, 3.0 fire rate, 120 range), added to Scavenger keeper

[2025-11-02] - Medic Starting Weapon - scripts/weapons/weapon_healing_bolt.gd, keeper_medic.gd - Healing Bolt (10 dmg, 1.0 fire rate, 150 range, 30% heal chance), added to Medic keeper with heal_nearby_structure() mechanic

[2025-11-02] - XP Gem Pickup - scripts/pickups/xp_gem.gd, scenes/pickups/xp_gem.tscn - Created XP gem with auto-magnet (40px range), 30s lifetime, visual size/color based on XP value (5/15/50 XP = green/blue/gold)

[2025-11-02] - Enemy XP Drops - scripts/entities/enemy.gd - Added xp_value export (5 XP default), spawn_xp_gem() on death, resource drop chances (Wood 20%, Metal 10%, Stone 5%), XP_GEM_SCENE preload

[2025-11-02] - LevelManager Autoload - scripts/autoload/level_manager.gd, project.godot - Created level manager with XP tracking, exponential leveling curve (base 10 * level^1.5), upgrade pool system (10 upgrade types), apply_upgrade() for stat modifications

[2025-11-02] - Level-Up UI - scripts/ui/level_up_screen.gd, scenes/ui/level_up_screen.tscn - Created level-up screen (CanvasLayer) with PanelContainer UI, 3-choice button layout, game pause on level-up, signal connection to LevelManager.level_up_choice_ready

[2025-11-02] - Game Integration - scenes/main/game.tscn - Added LevelUpScreen to game scene, registered LevelManager as autoload (order: after AudioManager, before VisualEffectsManager)
```

**Phase 5A Status: ✅ COMPLETE** - All 4 starting weapons created and integrated!

**Phase 5B Status: ✅ COMPLETE** - XP system, leveling, and level-up UI fully implemented!

---

## Key Technical Decisions

1. **Weapon Slots = 6 (Fixed)**
   - Allows meaningful progression
   - Not too many to overwhelm UI
   - Similar to VS (6-8 weapon slots)

2. **Auto-Aim = Nearest Enemy**
   - Simple, predictable
   - Works well with multiple weapons
   - Can be enhanced later (prioritize low HP, etc.)

3. **Level-Up = Pause Game**
   - Gives player time to read and choose
   - Creates tension/relief moments
   - Can change to slow-mo if pausing feels bad

4. **Day Phase = 30 Seconds**
   - Enough time to build 1-2 structures
   - Not long enough to get bored
   - Creates urgency and strategic choices

5. **Resources From Combat**
   - Makes combat more rewarding
   - Removes need for exploration
   - Maintains building economy

---

## Questions to Consider (For Future Sessions)

1. Should weapon upgrades affect ALL weapons or individual weapons?
   - Current: All weapons (simpler, more impactful)
   - Alternative: Choose which weapon to upgrade (more strategic)

2. Should there be weapon rarities (common/rare/epic)?
   - Phase 5: All weapons equal (simpler)
   - Phase 6+: Add rarities for variety

3. How should structure blueprints work in level-up?
   - Option A: Unlock new structure types (one-time)
   - Option B: Get a free structure placed immediately
   - Recommend: Discuss with user in Phase 6

4. Should player have HP or be invincible (only lighthouse matters)?
   - Current: Player has HP and can die
   - Keeps tension, player must dodge/position

5. Should resource nodes stay on the map?
   - Option A: Remove entirely (resources only from combat)
   - Option B: Keep as static bonus spawners
   - Recommend: Remove for Phase 5, revisit later

### Next Priorities (Phase 6+)
- Additional weapon types (10-15 unique weapons)
- Weapon rarities and synergies
- Structure blueprints in level-up pool
- Boss enemies and elite variants
- Replace placeholder sprites with pixel art


## Development Workflow

### Adding New Features
1. Check README.md for design specification
2. Create necessary scene/script files following directory structure
3. Implement using signal-based architecture
4. Test in isolation before integration
5. Update documentation if behavior differs from spec

### Adding New Enemies
1. Create scene inheriting from `enemy_base.tscn`
2. Override stats (health, speed, damage)
3. Implement unique behavior in script
4. Add to wave spawner composition logic
5. Balance against night progression curve

### Adding New Structures
1. Create scene inheriting from `structure_base.tscn`
2. Define costs dictionary and health
3. Implement unique functionality
4. Add to build menu UI
5. Ensure grid placement works correctly

### Adding New Keepers
1. Create scene inheriting from `keeper_base.tscn`
2. Set stat modifiers
3. Implement `_execute_ability()` override
4. Define unlock condition in SaveManager
5. Add to keeper selection UI

## Testing Strategy

### Component Testing
Create isolated test scenes in `tools/` to verify:
- Pathfinding behavior (spawn enemies, visualize paths)
- Building placement (test grid snapping, collision detection)
- Wave spawning (verify enemy budgets, timing)
- Resource gathering (check node depletion, respawn)

### Balance Testing
- Night 1-5 should be beatable by new players
- Night 10 requires strategy and planning
- Night 20+ demands mastery and optimal builds
- All keepers should be viable for full runs

### Debug Tools
Add debug overlays for development:
- Pathfinding visualization (draw paths)
- Collision shape visualization
- Resource spawn indicators
- Enemy AI state display

## Resources & References

**Godot Documentation:**
- https://docs.godotengine.org/en/stable/
- Focus on: Signals, Scenes, Nodes, Physics2D, Navigation

**Similar Game References:**
- Dead Cells (roguelike progression)
- They Are Billions (tower defense)
- Into the Breach (grid tactics, clear UI)

**Asset Tools:**
- Aseprite for pixel art creation
- Lospec for color palettes
- Audacity for audio editing
