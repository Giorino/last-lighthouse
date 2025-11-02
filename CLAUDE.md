# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Last Lighthouse** is a roguelike tower defense game built in Godot 4.5. The core concept combines Dead Cells-style roguelike progression with They Are Billions tower defense mechanics. Players defend a lighthouse against nightly horrors while scavenging during the day. Features permadeath with meta-progression through unlockable lighthouse keepers.

**Key Details:**
- Engine: Godot 4.5 (GDScript primary language)
- Genre: Roguelike + Tower Defense + Resource Management
- Art Style: Atmospheric pixel art (320x180 base resolution, scaled 6x to 1920x1080)
- Target: PC (Windows, macOS, Linux) via Steam

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

### Phase 3 ✅ IN PROGRESS
- **Keepers:** +Soldier (120HP/combat), +Scavenger (130spd/gathering), +Medic (heal lighthouse)
- **Abilities:** F key activates unique keeper abilities (30s cooldown)
  - Soldier: Rally (boost turret attack speed 2x/10s)
  - Scavenger: Sixth Sense (reveal resource nodes)
  - Medic: Emergency Heal (restore lighthouse 50% HP)
- **Pause Menu:** ESC to pause/resume, quit option
- **Game Over Screen:** Shows night reached, enemies killed, resources, tokens earned
- **Files:** +3 keeper scripts/scenes, pause menu, game over screen

### Current Controls
- **1-5:** Select/build structures | **R:** Repair | **B:** Toggle build | **Space:** Beam | **F:** Keeper ability | **ESC:** Pause | **WASD:** Move | **E:** Interact

### Next Priorities
- Keeper selection screen, Main menu, Stat tracking integration, Resource respawning, Victory screen


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
