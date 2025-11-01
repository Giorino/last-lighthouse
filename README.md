# Last Lighthouse - Roguelike Tower Defense

## 🎮 Game Overview

**Genre:** Roguelike + Tower Defense + Resource Management  
**Engine:** Godot 4.x  
**Platform:** PC (Windows, macOS, Linux) - Steam Release  
**Target Playtime:** 20-30 hours for full completion  
**Single Run Duration:** 45-90 minutes  
**Art Style:** Atmospheric Pixel Art  
**Perspective:** Top-down 2D

---

## 📖 Core Concept

### High-Concept Pitch
*"Dead Cells meets They Are Billions - Defend your lighthouse against nightly horrors while scavenging a ruined coastal town during the day. Permanent death, but unlock new lighthouse keepers with unique abilities."*

### The Story
You are a lighthouse keeper in a world where something has gone terribly wrong. Every night, grotesque creatures emerge from the sea, drawn to the light. During the day, you must explore the abandoned coastal town, scavenge resources, and prepare your defenses for the coming darkness.

When your lighthouse falls, you die. But another keeper arrives, ready to try again with knowledge of what came before.

### The Hook
- **Day/Night Cycle:** Explore and build during day (5 min), defend during night (3-5 min)
- **Permadeath:** When lighthouse falls, start completely over
- **Meta-Progression:** Unlock new keepers, permanent upgrades, and knowledge
- **Atmospheric Tension:** Growing dread as night approaches
- **Replayability:** Procedural maps, multiple keepers, varied strategies
- **Win Condition:** Survive 20-30 nights until rescue boat arrives

---

## 🎨 Art Style & Visual Design

### Overall Aesthetic
**Atmospheric Pixel Art** with a focus on:
- Moody, desaturated color palette
- Heavy use of lighting and shadows
- Fog/mist effects
- Weather systems that affect visuals
- Victorian/early 1900s coastal architecture

### Color Palette

**Day Colors:**
```
- Sky: Pale gray-blue (#8EA3B0)
- Sea: Dark gray-blue (#3D5A6C)
- Fog: Translucent white (#FFFFFF40)
- Buildings: Weathered gray (#6B6B6B), faded red (#8B4545)
- Vegetation: Muted green (#5C7457)
```

**Night Colors:**
```
- Sky: Deep purple-black (#1A1A2E)
- Sea: Black-blue (#0F1419)
- Lighthouse beam: Warm yellow (#FFDD88)
- Enemy glow: Sickly green (#88FF88)
- Fire/torches: Orange-red (#FF6B35)
```

### Resolution & Pixel Density
- **Base Resolution:** 320x180 (16:9 ratio)
- **Scaled to:** 1920x1080 (6x integer scaling)
- **Pixel Size:** 1 pixel at 320x180 = 6x6 pixels at 1080p
- **Tile Size:** 16x16 pixels (base) = 96x96 pixels (scaled)

### Visual References
Think of:
- **Don't Starve** - Atmospheric, Tim Burton-esque style
- **Darkest Dungeon** - Oppressive atmosphere, stark shadows
- **Dead Cells** - Fluid animation, clear readability
- **Into the Breach** - Clear UI, grid-based precision

### Animation Principles
- **Limited Animation:** 4-8 frames for most actions
- **Emphasis on Key Poses:** Anticipation, action, follow-through
- **Exaggerated Motion:** Squash and stretch for impact
- **Idle Animations:** Subtle breathing, swaying for living elements
- **Particle Effects:** Sparks, dust, water splashes for juice

---

## 🏗️ Technical Architecture

### Project Structure

```
LastLighthouse/
├── project.godot                 # Godot project file
├── README.md                     # This file
├── .gitignore                   # Git ignore rules
├── .gdignore                    # Godot ignore rules
│
├── assets/                       # All game assets
│   ├── sprites/                 # Sprite sheets and images
│   │   ├── characters/          # Player characters
│   │   ├── enemies/             # Enemy sprites
│   │   ├── structures/          # Buildings and defenses
│   │   ├── environment/         # Tiles, decorations
│   │   ├── ui/                  # UI elements
│   │   └── vfx/                 # Visual effects
│   │
│   ├── audio/                   # Sound and music
│   │   ├── music/               # Background music
│   │   ├── sfx/                 # Sound effects
│   │   └── ambient/             # Ambient sounds
│   │
│   ├── fonts/                   # Pixel fonts
│   │
│   └── shaders/                 # Custom shaders
│       ├── water.gdshader       # Water ripple effect
│       ├── fog.gdshader         # Fog overlay
│       └── lighthouse_beam.gdshader
│
├── scenes/                       # Godot scenes
│   ├── main/                    # Main game scenes
│   │   ├── main_menu.tscn       # Title screen
│   │   ├── game.tscn            # Main game scene
│   │   ├── pause_menu.tscn      # Pause overlay
│   │   └── game_over.tscn       # Death screen
│   │
│   ├── gameplay/                # Core gameplay scenes
│   │   ├── day_phase.tscn       # Day exploration mode
│   │   ├── night_phase.tscn     # Night defense mode
│   │   ├── lighthouse.tscn      # Central lighthouse
│   │   └── build_mode.tscn      # Building UI overlay
│   │
│   ├── characters/              # Character scenes
│   │   ├── keeper_base.tscn     # Base keeper template
│   │   ├── keeper_engineer.tscn
│   │   ├── keeper_soldier.tscn
│   │   ├── keeper_scavenger.tscn
│   │   └── keeper_medic.tscn
│   │
│   ├── enemies/                 # Enemy scenes
│   │   ├── enemy_base.tscn      # Base enemy template
│   │   ├── crawler.tscn         # Basic melee
│   │   ├── spitter.tscn         # Ranged attacker
│   │   ├── brute.tscn           # Heavy unit
│   │   └── boss_leviathan.tscn  # Boss enemy
│   │
│   ├── structures/              # Buildable structures
│   │   ├── structure_base.tscn  # Base structure template
│   │   ├── wall.tscn            # Defensive wall
│   │   ├── barricade.tscn       # Quick barrier
│   │   ├── turret.tscn          # Auto-turret
│   │   ├── trap.tscn            # Spike trap
│   │   └── generator.tscn       # Power generator
│   │
│   ├── environment/             # World elements
│   │   ├── tile_map.tscn        # World tilemap
│   │   ├── building_ruins.tscn  # Explorable buildings
│   │   ├── resource_node.tscn   # Scavenge points
│   │   └── weather_system.tscn  # Weather effects
│   │
│   └── ui/                      # UI components
│       ├── hud.tscn             # In-game HUD
│       ├── resource_display.tscn
│       ├── build_menu.tscn      # Building selection
│       ├── tech_tree.tscn       # Upgrade screen
│       └── wave_timer.tscn      # Night countdown
│
├── scripts/                     # GDScript files
│   ├── autoload/                # Singleton scripts
│   │   ├── game_manager.gd      # Core game state
│   │   ├── event_bus.gd         # Global event system
│   │   ├── save_manager.gd      # Save/load system
│   │   ├── audio_manager.gd     # Sound management
│   │   └── resource_manager.gd  # Resource tracking
│   │
│   ├── gameplay/                # Gameplay logic
│   │   ├── day_night_cycle.gd   # Phase management
│   │   ├── wave_spawner.gd      # Enemy spawning
│   │   ├── path_finding.gd      # A* pathfinding
│   │   └── damage_system.gd     # Combat calculations
│   │
│   ├── entities/                # Entity behaviors
│   │   ├── keeper.gd            # Player controller
│   │   ├── enemy.gd             # Enemy AI base
│   │   ├── structure.gd         # Building logic
│   │   └── projectile.gd        # Bullet/projectile
│   │
│   ├── systems/                 # Game systems
│   │   ├── inventory_system.gd  # Item management
│   │   ├── build_system.gd      # Construction logic
│   │   ├── upgrade_system.gd    # Tech tree
│   │   └── lighthouse_system.gd # Light mechanics
│   │
│   ├── procedural/              # Generation code
│   │   ├── map_generator.gd     # Procedural maps
│   │   ├── building_placer.gd   # Structure placement
│   │   └── loot_generator.gd    # Loot tables
│   │
│   └── utils/                   # Helper scripts
│       ├── constants.gd         # Global constants
│       ├── helpers.gd           # Utility functions
│       └── state_machine.gd     # FSM implementation
│
├── data/                        # Game data files
│   ├── keepers/                 # Keeper definitions
│   │   ├── engineer.tres        # Engineer stats
│   │   ├── soldier.tres         # Soldier stats
│   │   ├── scavenger.tres       # Scavenger stats
│   │   └── medic.tres           # Medic stats
│   │
│   ├── enemies/                 # Enemy definitions
│   │   ├── wave_patterns.tres   # Wave configurations
│   │   └── enemy_stats/         # Individual enemy data
│   │
│   ├── structures/              # Building data
│   │   ├── defenses.tres        # Defense structures
│   │   └── utilities.tres       # Utility buildings
│   │
│   ├── items/                   # Item definitions
│   │   ├── resources.tres       # Resource types
│   │   └── upgrades.tres        # Upgrade definitions
│   │
│   └── balancing/               # Balance configurations
│       ├── difficulty_curve.tres
│       └── progression.tres
│
├── docs/                        # Documentation
│   ├── GAME_DESIGN.md           # Detailed design doc
│   ├── TECHNICAL_SPEC.md        # Technical details
│   ├── ART_GUIDE.md             # Art style guide
│   └── BALANCING_NOTES.md       # Balance considerations
│
└── tools/                       # Development tools
    ├── map_editor/              # Custom map editor
    └── balance_calculator/      # Balance testing tools
```

### Godot Autoload Singletons (In Order)

```gdscript
# project.godot autoload configuration:
# 1. Constants (constants.gd) - Game constants
# 2. EventBus (event_bus.gd) - Global signals
# 3. SaveManager (save_manager.gd) - Persistent data
# 4. AudioManager (audio_manager.gd) - Sound system
# 5. ResourceManager (resource_manager.gd) - Resources
# 6. GameManager (game_manager.gd) - Core game state
```

---

## 🔄 Game Loop

### High-Level Flow

```
Main Menu
    ↓
[Select Keeper]
    ↓
[Generate Map] (Procedural)
    ↓
┌─────────────────────────┐
│   DAY PHASE (5 min)     │
│  - Explore ruins        │
│  - Gather resources     │
│  - Build defenses       │
│  - Repair damage        │
└───────────┬─────────────┘
            ↓
    [Transition: 10 sec]
     - Buy upgrades
     - Final preparations
            ↓
┌─────────────────────────┐
│  NIGHT PHASE (3-5 min)  │
│  - Waves of enemies     │
│  - Defend lighthouse    │
│  - Manage light/power   │
└───────────┬─────────────┘
            ↓
    [Check Lighthouse HP]
            ↓
    ┌───────┴───────┐
    │               │
   Alive          Dead
    │               │
    ↓               ↓
 Night +1      GAME OVER
    │          - Unlock new content
    │          - Meta progression
    │          - Start new run
    ↓
[Win Check]
    │
 20-30 nights?
    │
   Yes → VICTORY → Credits
    │
   No → Back to Day Phase
```

### Detailed Phase Breakdown

#### **1. Main Menu**
- Start New Run
- Continue (if save exists)
- Keeper Select (unlocked keepers)
- Settings
- Quit

#### **2. Keeper Selection**
Player chooses from unlocked keepers:
- **Engineer** (starter) - Builds 25% faster, structures cheaper
- **Soldier** (unlock: survive 5 nights) - Better combat, can build turrets
- **Scavenger** (unlock: collect 500 resources) - Finds more loot, faster movement
- **Medic** (unlock: survive 10 nights) - Lighthouse regenerates HP, better repairs

#### **3. Map Generation**
```
Procedural elements:
- Lighthouse placement (always center)
- 8-12 ruined buildings (random placement)
- 4-6 resource nodes (trees, debris piles)
- Coastline shape variation
- Starting resources nearby
- Enemy spawn points (4-8 locations)
```

#### **4. Day Phase (300 seconds)**

**Player Activities:**

1. **Exploration**
   - WASD movement (pixel-perfect, 8-directional)
   - Enter buildings to search
   - Find resources and blueprints
   - Discover shortcuts

2. **Resource Gathering**
   - Press E to scavenge nodes
   - Resources: Wood, Metal, Stone, Fuel
   - Each node: 2-3 second channeling time
   - Inventory limit: Varies by keeper

3. **Building**
   - Press B to enter build mode
   - Grid-based placement (16x16 tiles)
   - Preview shows valid placement
   - Instant construction (resources consumed)

4. **Repairing**
   - Damaged structures highlighted
   - Stand near + hold R to repair
   - Costs 50% of original resource cost

**Day Phase UI:**
```
Top-Left: Resources (Wood, Metal, Stone, Fuel)
Top-Right: Time until night (countdown)
Bottom-Left: Lighthouse HP bar
Bottom-Right: Build menu (hotkeys 1-9)
Center: Minimal crosshair
```

**Day Phase Progression:**
- First 2 minutes: Safe exploration
- Last minute: Subtle audio cues (wind picking up)
- 30 seconds: Warning notification "Night approaches!"
- 10 seconds: Screen darkens slightly

#### **5. Transition Phase (10 seconds)**

**Pre-Night Preparation:**
- Shop overlay appears
- Spend excess resources on:
  - Instant repairs
  - Emergency supplies (medkits, ammo)
  - Temporary buffs (bonus damage, speed)
- Cannot move during this phase
- Optional: Can skip to start night immediately

#### **6. Night Phase (180-300 seconds)**

**Wave Structure:**
```
Night 1-5:   1 wave, basic enemies
Night 6-10:  2 waves, introduce ranged
Night 11-15: 3 waves, heavy units appear
Night 16-20: 4 waves, boss every 5th night
Night 21-25: 5 waves, multiple bosses
Night 26-30: Survival mode (constant spawns)
```

**Enemy Spawn Pattern:**
```gdscript
# Pseudocode for wave spawning
func spawn_wave(night_number: int):
    var wave_count = ceil(night_number / 5.0)
    var wave_delay = 60 # seconds between waves
    
    for wave in wave_count:
        await get_tree().create_timer(wave_delay).timeout
        var enemy_budget = night_number * 10
        spawn_enemies_from_budget(enemy_budget)
```

**Player Activities:**
- Defend lighthouse manually (combat)
- Repair critical structures mid-fight
- Manage lighthouse beam (fuel consumption)
- Activate abilities (keeper-specific)

**Combat Mechanics:**
- **Keeper Combat:** Click to shoot projectile toward mouse
- **Auto-Turrets:** Target nearest enemy automatically
- **Traps:** Triggered by enemy proximity
- **Lighthouse Beam:** Hold Space to activate (stuns enemies, drains fuel)

**Enemy Behavior:**
```
Pathfinding:
1. Find shortest path to lighthouse (A* algorithm)
2. If blocked by wall: Attack wall
3. If in range of keeper/turret: May aggro player
4. Special enemies have unique behaviors
```

**Night Phase UI:**
```
Top-Left: Resources (grayed out, can't gather)
Top-Right: Wave indicator (1/3, 2/3, 3/3)
Bottom-Left: Lighthouse HP (prominent, pulsing)
Bottom-Right: Keeper HP, ammo, ability cooldown
Center: Minimal crosshair + enemy health bars
```

**Night End Conditions:**
- **Victory:** All waves defeated, lighthouse survives
- **Defeat:** Lighthouse HP reaches 0
- **Special:** Boss nights have no time limit

#### **7. Post-Night Evaluation**

**If Survived:**
```
- Show stats screen:
  - Enemies killed
  - Structures built
  - Resources gathered
  - Lighthouse damage taken
  
- Award meta-currency (Keeper Tokens)
- Progress to next day phase
- Increment night counter
```

**If Died:**
```
- Slow-motion lighthouse collapse
- Death screen:
  - "The light fades..."
  - Run summary stats
  - Unlocks earned this run
  - Meta-progression rewards
  
- Options:
  - Try Again (new run)
  - Keeper Selection
  - Main Menu
```

#### **8. Victory Condition**

**Survive 20-30 Nights:**
- Final night is special boss gauntlet
- Rescue boat cutscene
- Ending varies by keeper used
- Unlock "Nightmare Mode" (harder difficulty)
- Credits roll

---

## ⚙️ Core Mechanics (Detailed)

### 1. Day/Night Cycle

**Implementation:**
```gdscript
# day_night_cycle.gd
class_name DayNightCycle extends Node

signal day_started
signal night_approaching(seconds_left: int)
signal night_started
signal night_ended

enum Phase { DAY, TRANSITION, NIGHT }

var current_phase: Phase = Phase.DAY
var day_duration: float = 300.0 # 5 minutes
var night_duration: float = 180.0 # 3 minutes
var transition_duration: float = 10.0

var time_remaining: float = 0.0

func _ready():
    start_day_phase()

func start_day_phase():
    current_phase = Phase.DAY
    time_remaining = day_duration
    day_started.emit()
    
    # Enable day mechanics
    GameManager.enable_building = true
    GameManager.enable_scavenging = true
    
func _process(delta):
    if current_phase == Phase.DAY:
        time_remaining -= delta
        
        # Warning at 30 seconds
        if time_remaining <= 30 and time_remaining > 29:
            night_approaching.emit(30)
        
        if time_remaining <= 0:
            start_transition()
    
    elif current_phase == Phase.TRANSITION:
        time_remaining -= delta
        if time_remaining <= 0:
            start_night_phase()
    
    elif current_phase == Phase.NIGHT:
        # Night ends when all waves complete
        if WaveSpawner.all_waves_complete():
            end_night_phase()
```

### 2. Resource System

**Resource Types:**
```gdscript
# resources.tres (Resource data)
enum ResourceType {
    WOOD,   # Common, for basic structures
    METAL,  # Uncommon, for advanced defenses
    STONE,  # Common, for walls
    FUEL    # Rare, for lighthouse beam + generators
}

# Resource node data
class ResourceNode:
    var resource_type: ResourceType
    var amount: int
    var respawn_chance: float # Chance to respawn next day
    var harvest_time: float # Seconds to gather
```

**Gathering Mechanic:**
```gdscript
# resource_node.gd
extends Area2D

@export var resource_type: Constants.ResourceType
@export var amount: int = 10
@export var harvest_time: float = 2.0

var is_being_harvested: bool = false
var harvest_progress: float = 0.0
var harvester: Node2D = null

func _on_body_entered(body):
    if body.is_in_group("keeper"):
        # Show prompt "Press E to gather"
        pass

func start_harvest(keeper: Node2D):
    is_being_harvested = true
    harvester = keeper
    harvest_progress = 0.0
    # Play harvest animation

func _process(delta):
    if is_being_harvested:
        harvest_progress += delta
        if harvest_progress >= harvest_time:
            complete_harvest()

func complete_harvest():
    ResourceManager.add_resource(resource_type, amount)
    is_being_harvested = false
    queue_free() # Or hide and mark for potential respawn
```

**Resource Manager (Autoload):**
```gdscript
# resource_manager.gd
extends Node

signal resource_changed(type: Constants.ResourceType, amount: int)

var resources: Dictionary = {
    Constants.ResourceType.WOOD: 50,  # Starting amounts
    Constants.ResourceType.METAL: 20,
    Constants.ResourceType.STONE: 30,
    Constants.ResourceType.FUEL: 10
}

func add_resource(type: Constants.ResourceType, amount: int):
    resources[type] += amount
    resource_changed.emit(type, resources[type])

func spend_resource(type: Constants.ResourceType, amount: int) -> bool:
    if resources[type] >= amount:
        resources[type] -= amount
        resource_changed.emit(type, resources[type])
        return true
    return false

func can_afford(costs: Dictionary) -> bool:
    for type in costs:
        if resources[type] < costs[type]:
            return false
    return true
```

### 3. Building System

**Grid-Based Placement:**
```gdscript
# build_system.gd
extends Node2D

const TILE_SIZE = 16
var build_mode: bool = false
var selected_structure: PackedScene = null
var ghost_instance: Node2D = null

func enter_build_mode(structure: PackedScene):
    build_mode = true
    selected_structure = structure
    
    # Create ghost preview
    ghost_instance = structure.instantiate()
    ghost_instance.modulate = Color(1, 1, 1, 0.5)
    add_child(ghost_instance)

func _process(_delta):
    if build_mode and ghost_instance:
        # Snap ghost to grid
        var mouse_pos = get_global_mouse_position()
        var grid_pos = snap_to_grid(mouse_pos)
        ghost_instance.global_position = grid_pos
        
        # Check if valid placement
        var is_valid = check_placement_valid(grid_pos)
        ghost_instance.modulate = Color.GREEN if is_valid else Color.RED

func snap_to_grid(pos: Vector2) -> Vector2:
    return Vector2(
        floor(pos.x / TILE_SIZE) * TILE_SIZE + TILE_SIZE/2,
        floor(pos.y / TILE_SIZE) * TILE_SIZE + TILE_SIZE/2
    )

func check_placement_valid(pos: Vector2) -> bool:
    # Check if overlapping with existing structures
    # Check if within build radius of lighthouse
    # Check if on valid terrain
    return true # Simplified

func place_structure():
    if not check_placement_valid(ghost_instance.global_position):
        return
    
    var structure_data = selected_structure.get_meta("structure_data")
    if not ResourceManager.can_afford(structure_data.costs):
        # Show "Not enough resources" message
        return
    
    # Spend resources
    for type in structure_data.costs:
        ResourceManager.spend_resource(type, structure_data.costs[type])
    
    # Create real structure
    var structure = selected_structure.instantiate()
    structure.global_position = ghost_instance.global_position
    get_parent().add_child(structure)
    
    # Exit build mode
    exit_build_mode()
```

**Structure Types:**
```gdscript
# structure_base.gd
class_name Structure extends StaticBody2D

@export var structure_name: String
@export var max_health: int = 100
@export var costs: Dictionary = {}
@export var build_time: float = 0.0 # Instant for now
@export var can_be_repaired: bool = true

var current_health: int = max_health

func take_damage(amount: int):
    current_health -= amount
    
    if current_health <= 0:
        destroy()
    else:
        # Visual damage feedback
        update_damaged_sprite()

func repair(amount: int):
    current_health = min(current_health + amount, max_health)
    update_damaged_sprite()

func destroy():
    # Play destruction animation
    # Spawn debris particles
    queue_free()
```

**Example Structures:**

```gdscript
# Wall
costs = {WOOD: 5, STONE: 10}
max_health = 200
blocks_enemy_pathing = true

# Barricade (cheap, weak)
costs = {WOOD: 3}
max_health = 50
blocks_enemy_pathing = true

# Turret
costs = {WOOD: 10, METAL: 15}
max_health = 100
attack_damage = 10
attack_range = 200
attack_speed = 1.0 # attacks per second

# Spike Trap
costs = {METAL: 8}
max_health = 50
damage_on_trigger = 30
single_use = false
cooldown = 5.0

# Generator
costs = {METAL: 20, FUEL: 10}
max_health = 75
generates_power = true
powers_nearby_turrets = true
```

### 4. Enemy System

**Base Enemy Class:**
```gdscript
# enemy.gd
class_name Enemy extends CharacterBody2D

@export var enemy_name: String
@export var max_health: int = 50
@export var speed: float = 50.0
@export var attack_damage: int = 10
@export var attack_range: float = 20.0
@export var attack_cooldown: float = 1.0
@export var bounty: int = 5 # Meta-currency on kill

var current_health: int = max_health
var current_target: Node2D = null
var attack_timer: float = 0.0
var path: Array[Vector2] = []
var path_index: int = 0

enum State { PATHFINDING, ATTACKING, STUNNED }
var current_state: State = State.PATHFINDING

func _ready():
    current_health = max_health
    find_path_to_lighthouse()

func find_path_to_lighthouse():
    var lighthouse = get_tree().get_first_node_in_group("lighthouse")
    if lighthouse:
        path = PathFinding.find_path(global_position, lighthouse.global_position)
        path_index = 0

func _physics_process(delta):
    match current_state:
        State.PATHFINDING:
            move_along_path(delta)
        State.ATTACKING:
            perform_attack(delta)
        State.STUNNED:
            # Wait for stun duration
            pass

func move_along_path(delta):
    if path.is_empty() or path_index >= path.size():
        find_path_to_lighthouse()
        return
    
    var target_pos = path[path_index]
    var direction = (target_pos - global_position).normalized()
    velocity = direction * speed
    move_and_slide()
    
    # Check if reached waypoint
    if global_position.distance_to(target_pos) < 5.0:
        path_index += 1
    
    # Check if reached lighthouse
    var lighthouse = get_tree().get_first_node_in_group("lighthouse")
    if lighthouse and global_position.distance_to(lighthouse.global_position) < attack_range:
        current_state = State.ATTACKING
        current_target = lighthouse

func perform_attack(delta):
    attack_timer += delta
    
    if attack_timer >= attack_cooldown:
        if current_target and is_instance_valid(current_target):
            current_target.take_damage(attack_damage)
            attack_timer = 0.0
            # Play attack animation
        else:
            current_state = State.PATHFINDING
            find_path_to_lighthouse()

func take_damage(amount: int):
    current_health -= amount
    
    # Visual feedback
    flash_red()
    spawn_damage_number(amount)
    
    if current_health <= 0:
        die()

func die():
    # Award bounty
    GameManager.add_meta_currency(bounty)
    
    # Play death animation
    # Spawn particle effect
    
    queue_free()
```

**Enemy Types:**

```gdscript
# Crawler (basic melee)
max_health = 50
speed = 50
attack_damage = 10
attack_range = 20

# Spitter (ranged)
max_health = 30
speed = 40
attack_damage = 8
attack_range = 150
projectile_scene = preload("res://scenes/enemies/acid_spit.tscn")

# Brute (heavy)
max_health = 200
speed = 30
attack_damage = 25
attack_range = 25
can_break_walls_faster = true

# Swarm (fast, weak)
max_health = 15
speed = 100
attack_damage = 5
attack_range = 15
spawns_in_groups = 5

# Boss: Leviathan
max_health = 1000
speed = 20
attack_damage = 50
attack_range = 50
special_ability = "tidal_wave" # AOE attack
phases = 3 # Changes behavior at 66%, 33% HP
```

### 5. Wave Spawner

```gdscript
# wave_spawner.gd
extends Node

signal wave_started(wave_number: int, total_waves: int)
signal wave_completed(wave_number: int)
signal all_waves_completed

var current_night: int = 1
var current_wave: int = 0
var total_waves: int = 1
var enemies_remaining: int = 0
var is_spawning: bool = false

func start_night(night_number: int):
    current_night = night_number
    current_wave = 0
    total_waves = calculate_total_waves(night_number)
    
    spawn_next_wave()

func calculate_total_waves(night: int) -> int:
    return ceili(night / 5.0) # 1 wave per 5 nights

func spawn_next_wave():
    if current_wave >= total_waves:
        return
    
    current_wave += 1
    is_spawning = true
    wave_started.emit(current_wave, total_waves)
    
    var enemy_budget = current_night * 10
    var enemy_composition = generate_enemy_composition(current_night, enemy_budget)
    
    spawn_enemies(enemy_composition)

func generate_enemy_composition(night: int, budget: int) -> Dictionary:
    # Example composition logic
    var composition = {}
    
    # Nights 1-5: Only crawlers
    if night <= 5:
        composition["crawler"] = budget / 5
    
    # Nights 6-10: Crawlers + Spitters
    elif night <= 10:
        composition["crawler"] = (budget * 0.7) / 5
        composition["spitter"] = (budget * 0.3) / 8
    
    # Nights 11-15: Mixed with brutes
    elif night <= 15:
        composition["crawler"] = (budget * 0.5) / 5
        composition["spitter"] = (budget * 0.3) / 8
        composition["brute"] = (budget * 0.2) / 20
    
    # Boss nights (every 5)
    if night % 5 == 0:
        composition["boss_leviathan"] = 1
    
    return composition

func spawn_enemies(composition: Dictionary):
    var spawn_points = get_tree().get_nodes_in_group("enemy_spawn")
    
    for enemy_type in composition:
        var count = int(composition[enemy_type])
        for i in count:
            var spawn_point = spawn_points.pick_random()
            var enemy_scene = load("res://scenes/enemies/" + enemy_type + ".tscn")
            var enemy = enemy_scene.instantiate()
            
            enemy.global_position = spawn_point.global_position
            enemy.tree_exited.connect(_on_enemy_died)
            
            get_parent().call_deferred("add_child", enemy)
            enemies_remaining += 1
            
            # Stagger spawns
            await get_tree().create_timer(0.5).timeout

func _on_enemy_died():
    enemies_remaining -= 1
    
    if enemies_remaining <= 0:
        wave_completed.emit(current_wave)
        
        if current_wave < total_waves:
            # Wait before next wave
            await get_tree().create_timer(30.0).timeout
            spawn_next_wave()
        else:
            all_waves_completed.emit()
```

### 6. Lighthouse System

**The Central Mechanic:**
```gdscript
# lighthouse.gd
extends StaticBody2D

signal health_changed(current: int, max: int)
signal lighthouse_destroyed

@export var max_health: int = 500
@export var beam_fuel_cost: float = 5.0 # per second
@export var beam_stun_radius: float = 200.0

var current_health: int = max_health
var beam_active: bool = false
var light_rotation: float = 0.0

@onready var light_sprite = $LightBeam
@onready var damage_flash = $DamageFlash

func _ready():
    current_health = max_health
    health_changed.emit(current_health, max_health)

func _process(delta):
    # Rotate light slowly
    light_rotation += delta * 10.0 # degrees per second
    light_sprite.rotation_degrees = light_rotation
    
    # Handle beam activation (player holds Space)
    if Input.is_action_pressed("lighthouse_beam"):
        activate_beam(delta)
    else:
        deactivate_beam()

func activate_beam(delta):
    # Check if enough fuel
    if ResourceManager.resources[Constants.ResourceType.FUEL] <= 0:
        deactivate_beam()
        return
    
    beam_active = true
    light_sprite.modulate = Color.WHITE
    light_sprite.scale = Vector2(1.5, 1.5)
    
    # Consume fuel
    ResourceManager.spend_resource(
        Constants.ResourceType.FUEL, 
        beam_fuel_cost * delta
    )
    
    # Stun nearby enemies
    var enemies_in_range = get_enemies_in_radius(beam_stun_radius)
    for enemy in enemies_in_range:
        enemy.apply_stun(delta)

func deactivate_beam():
    beam_active = false
    light_sprite.modulate = Color(1, 1, 1, 0.5)
    light_sprite.scale = Vector2.ONE

func get_enemies_in_radius(radius: float) -> Array:
    var enemies = []
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if global_position.distance_to(enemy.global_position) <= radius:
            enemies.append(enemy)
    return enemies

func take_damage(amount: int):
    current_health -= amount
    health_changed.emit(current_health, max_health)
    
    # Visual feedback
    damage_flash.visible = true
    await get_tree().create_timer(0.1).timeout
    damage_flash.visible = false
    
    if current_health <= 0:
        destroy_lighthouse()

func repair(amount: int):
    current_health = min(current_health + amount, max_health)
    health_changed.emit(current_health, max_health)

func destroy_lighthouse():
    lighthouse_destroyed.emit()
    # Trigger game over
    GameManager.game_over()
```

### 7. Keeper System

**Base Keeper Class:**
```gdscript
# keeper.gd
class_name Keeper extends CharacterBody2D

@export var keeper_name: String
@export var max_health: int = 100
@export var speed: float = 100.0
@export var inventory_capacity: int = 100
@export var special_ability_cooldown: float = 30.0

var current_health: int = max_health
var ability_timer: float = 0.0
var is_gathering: bool = false
var is_repairing: bool = false

# Movement
func _physics_process(delta):
    if is_gathering or is_repairing:
        return
    
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    
    if input_dir != Vector2.ZERO:
        velocity = input_dir * speed
    else:
        velocity = velocity.move_toward(Vector2.ZERO, speed * 10 * delta)
    
    move_and_slide()

# Combat
func _unhandled_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            shoot_projectile()

func shoot_projectile():
    var projectile_scene = preload("res://scenes/projectile.tscn")
    var projectile = projectile_scene.instantiate()
    
    projectile.global_position = global_position
    projectile.direction = (get_global_mouse_position() - global_position).normalized()
    
    get_parent().add_child(projectile)

# Keeper-specific abilities (overridden in subclasses)
func use_special_ability():
    if ability_timer < special_ability_cooldown:
        return
    
    _execute_ability()
    ability_timer = 0.0

func _execute_ability():
    # Override in subclasses
    pass
```

**Keeper Subclasses:**

```gdscript
# keeper_engineer.gd
extends Keeper

func _ready():
    keeper_name = "Engineer"
    # Buildings cost 25% less
    # Builds 25% faster

func _execute_ability():
    # Ability: "Quick Fix"
    # Instantly repair all structures in 150 radius to 50% HP
    var structures = get_structures_in_radius(150)
    for structure in structures:
        structure.repair(structure.max_health * 0.5)

# keeper_soldier.gd
extends Keeper

func _ready():
    keeper_name = "Soldier"
    # Deals 50% more damage
    # Can build turrets

func _execute_ability():
    # Ability: "Rally"
    # All turrets gain 100% attack speed for 10 seconds
    var turrets = get_tree().get_nodes_in_group("turrets")
    for turret in turrets:
        turret.apply_buff("attack_speed", 2.0, 10.0)

# keeper_scavenger.gd
extends Keeper

func _ready():
    keeper_name = "Scavenger"
    speed = 120.0 # Faster movement
    inventory_capacity = 150 # More inventory

func _execute_ability():
    # Ability: "Sixth Sense"
    # Reveal all resource nodes on map for 15 seconds
    EventBus.reveal_resources.emit(15.0)

# keeper_medic.gd
extends Keeper

func _ready():
    keeper_name = "Medic"
    # Lighthouse regenerates 1 HP per second
    # Repairs cost 25% less

func _execute_ability():
    # Ability: "Emergency Heal"
    # Restore lighthouse to 50% HP instantly
    var lighthouse = get_tree().get_first_node_in_group("lighthouse")
    if lighthouse:
        lighthouse.repair(lighthouse.max_health * 0.5)
```

### 8. Meta-Progression

**Unlock System:**
```gdscript
# save_manager.gd
extends Node

var save_data = {
    "unlocked_keepers": ["engineer"], # Starts with engineer
    "meta_currency": 0,
    "total_nights_survived": 0,
    "total_runs": 0,
    "highest_night_reached": 0,
    "enemies_killed": 0,
    "unlocks": [],
    "achievements": []
}

const SAVE_PATH = "user://savegame.save"

func save_game():
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    file.store_var(save_data)
    file.close()

func load_game():
    if not FileAccess.file_exists(SAVE_PATH):
        return
    
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    save_data = file.get_var()
    file.close()

# Unlock conditions
func check_unlocks():
    # Soldier: Survive 5 nights
    if save_data.highest_night_reached >= 5:
        unlock_keeper("soldier")
    
    # Scavenger: Collect 500 total resources
    # (tracked separately)
    
    # Medic: Survive 10 nights
    if save_data.highest_night_reached >= 10:
        unlock_keeper("medic")

func unlock_keeper(keeper_id: String):
    if not keeper_id in save_data.unlocked_keepers:
        save_data.unlocked_keepers.append(keeper_id)
        EventBus.keeper_unlocked.emit(keeper_id)
        save_game()
```

**Permanent Upgrades (Meta-currency spending):**
```
- Starting Resources (+10 wood/metal/stone) - 50 tokens
- Extra Day Time (+30 seconds) - 100 tokens
- Lighthouse HP (+50 max HP) - 75 tokens
- Building Speed (+10% faster) - 60 tokens
- Resource Yield (+10% from nodes) - 80 tokens
```

---

## 🎯 Unique Mechanics Summary

### 1. **Dynamic Weather System**
```gdscript
# weather_system.gd
enum Weather { CLEAR, FOG, RAIN, STORM }

var current_weather: Weather = Weather.CLEAR

# Effects:
# - FOG: Reduces visibility (darkens edges of screen)
# - RAIN: Reduces movement speed by 10%, damages paper resources
# - STORM: Lightning strikes random locations, damages structures
```

### 2. **Lighthouse Beam Mechanic**
- Hold **Space** to activate powerful beam
- Stuns all enemies in 200px radius
- Drains fuel (5 fuel/second)
- Risk/reward: Powerful but expensive

### 3. **Procedural Map Generation**
```gdscript
# map_generator.gd
func generate_map(seed_value: int):
    seed(seed_value)
    
    # Place lighthouse (center)
    place_lighthouse(Vector2(160, 90))
    
    # Generate coastline (Perlin noise)
    generate_coastline()
    
    # Place buildings (8-12)
    for i in randi_range(8, 12):
        place_building_ruin(get_valid_position())
    
    # Place resource nodes (4-6)
    for i in randi_range(4, 6):
        place_resource_node(get_valid_position())
    
    # Enemy spawn points (4-8 at edges)
    for i in randi_range(4, 8):
        place_spawn_point(get_edge_position())
```

### 4. **Building Degradation**
- Structures take damage each night
- More damaged = reduced effectiveness
- Visual indication (cracks, smoke)
- Must be repaired during day

### 5. **Enemy Variety & Behavior**
- **Crawlers:** Basic pathfinding, attack lighthouse
- **Spitters:** Stay at range, shoot projectiles
- **Brutes:** Tank damage, break walls faster
- **Swarms:** Fast, weak, overwhelm by numbers
- **Bosses:** Unique mechanics, multi-phase fights

### 6. **Emergency Light Restoration**
- If lighthouse HP < 25%, light flickers
- Reduced defense range
- Enemies move faster (sense weakness)
- Creates desperate moments

### 7. **Speedrun Potential**
- Built-in timer
- Leaderboards (local + Steam)
- Optimal route discovery
- Different strategies per keeper

---

## 📅 Development Phases

### **Phase 1: Core Prototype (Weeks 1-4)**

**Goal:** Playable vertical slice - one complete day/night cycle

**Tasks:**
1. ✅ Project setup in Godot 4.x
2. ✅ Basic player movement (WASD, 8-directional)
3. ✅ Day/night cycle timer
4. ✅ Simple lighthouse with HP
5. ✅ One enemy type (crawler) with pathfinding
6. ✅ Basic building (wall) placement
7. ✅ Resource gathering (wood from one node)
8. ✅ Win/loss conditions

**Deliverable:** 
- Can play one full cycle
- Build a wall
- Enemy attacks lighthouse
- Lighthouse can be destroyed

**Validation:**
- Is the core loop fun?
- Does day/night cycle feel good?
- Is combat satisfying?

---

### **Phase 2: Content Foundation (Weeks 5-8)**

**Goal:** Expand content, add variety

**Tasks:**
1. ✅ Add 3 more enemy types (spitter, brute, swarm)
2. ✅ Add 4 more structure types (barricade, turret, trap, generator)
3. ✅ Implement 3 more resource types (metal, stone, fuel)
4. ✅ Wave spawner system
5. ✅ Multiple nights progression (1-10)
6. ✅ Engineer keeper fully functional
7. ✅ Basic UI (HUD, resource display)
8. ✅ Simple procedural map generation

**Deliverable:**
- Can survive 10 nights
- Multiple structures to build
- Enemy variety creates challenge
- Basic progression curve

---

### **Phase 3: Keepers & Meta-Progression (Weeks 9-12)**

**Goal:** Add replay value, unlockables

**Tasks:**
1. ✅ Implement 3 additional keepers (Soldier, Scavenger, Medic)
2. ✅ Keeper-specific abilities
3. ✅ Save/load system
4. ✅ Meta-currency (Keeper Tokens)
5. ✅ Unlock conditions
6. ✅ Permanent upgrades shop
7. ✅ Stats tracking (enemies killed, nights survived, etc.)
8. ✅ Game over screen with stats

**Deliverable:**
- 4 playable keepers
- Meaningful meta-progression
- Reasons to replay runs

---

### **Phase 4: Polish & Juice (Weeks 13-16)**

**Goal:** Make it feel GOOD

**Tasks:**
1. ✅ Pixel art polish (animations, sprites)
2. ✅ Particle effects (hits, deaths, explosions)
3. ✅ Screen shake on impacts
4. ✅ Sound effects (60+ sounds)
5. ✅ Music (day theme, night theme, boss theme)
6. ✅ UI polish (menus, transitions)
7. ✅ Camera juice (zoom, follow, shake)
8. ✅ Hit pause (freeze frames on hit)

**Deliverable:**
- Game feels responsive and satisfying
- Visual/audio feedback for every action
- Professional presentation

---

### **Phase 5: Balance & Content Complete (Weeks 17-20)**

**Goal:** Finish all content, balance difficulty

**Tasks:**
1. ✅ Nights 11-30 fully designed
2. ✅ Boss enemies (3-5 unique bosses)
3. ✅ 5+ different map variations
4. ✅ Weather system implementation
5. ✅ Difficulty curve tuning
6. ✅ Playtesting (20+ hours each keeper)
7. ✅ Bug fixing
8. ✅ Lighthouse beam mechanic polish

**Deliverable:**
- Complete 30-night campaign
- Balanced and challenging
- No major bugs

---

### **Phase 6: Marketing Prep (Weeks 21-24)**

**Goal:** Prepare for launch

**Tasks:**
1. ✅ Steam page creation
2. ✅ Trailer production (60-90 seconds)
3. ✅ Screenshot captures (10-15 high-quality)
4. ✅ Press kit preparation
5. ✅ Discord community setup
6. ✅ Social media accounts
7. ✅ Demo build for Steam Next Fest
8. ✅ Influencer outreach list

**Deliverable:**
- Professional Steam page
- Marketing materials ready
- Community building started

---

### **Phase 7: Beta & Final Polish (Weeks 25-28)**

**Goal:** Community testing, final bugs

**Tasks:**
1. ✅ Closed beta (50-100 players)
2. ✅ Bug reports & fixes
3. ✅ Balance adjustments based on feedback
4. ✅ Achievements implementation
5. ✅ Controller support
6. ✅ Accessibility options (colorblind modes, etc.)
7. ✅ Performance optimization
8. ✅ Final content pass

**Deliverable:**
- Stable, tested build
- Community feedback incorporated
- Performance optimized

---

### **Phase 8: Launch (Week 29-30)**

**Goal:** Ship it!

**Tasks:**
1. ✅ Final build upload to Steam
2. ✅ Launch day marketing push
3. ✅ Monitor reviews/feedback
4. ✅ Rapid hotfix response
5. ✅ Community engagement (Discord, Reddit)
6. ✅ Press outreach (email journalists)

**Deliverable:**
- Game live on Steam
- Positive reception
- Sales tracking

---

### **Phase 9: Post-Launch (Week 31+)**

**Goal:** Support and expand

**Tasks:**
1. ✅ Week 1-2: Critical bug fixes
2. ✅ Month 1: Quality of life updates
3. ✅ Month 2-3: Free content update (new keeper?)
4. ✅ Month 4-6: Paid DLC planning
5. ✅ Ongoing: Community events, challenges

**Potential DLC Ideas:**
- New keeper: "The Architect" (advanced building options)
- New biome: Desert lighthouse
- Nightmare mode (permadeath hardcore)
- Co-op mode (2-player)

---

## 🛠️ Technical Specifications

### Godot Version
- **Godot 4.3+** (latest stable)
- C# support optional (GDScript recommended)

### Performance Targets
- **60 FPS minimum** (on mid-range PC from 2018)
- **100+ enemies on screen** without slowdown
- **<500MB RAM usage**
- **<100MB disk space**

### Resolution & Display
- **Native:** 320x180 (16:9)
- **Scaled:** 1920x1080 (integer scaling)
- **Fullscreen support**
- **Windowed mode**
- **V-Sync toggle**

### Input Methods
- **Keyboard + Mouse** (primary)
- **Controller** (Xbox/PlayStation layouts)
- **Rebindable keys**

### Save System
- **Auto-save:** After each night
- **Manual save:** Disabled (roguelike convention)
- **Cloud saves:** Steam Cloud integration
- **Save location:** `user://savegame.save`

### Audio
- **Music:** 5-7 tracks (looping)
  - Main menu theme
  - Day phase theme
  - Night phase theme (tense)
  - Boss theme
  - Victory theme
  - Game over theme
  
- **Sound Effects:** 60-80 SFX
  - Movement (footsteps, doors)
  - Combat (shots, hits, deaths)
  - Building (place, repair, destroy)
  - UI (clicks, hovers, confirmations)
  - Ambient (wind, waves, fog)

### Localization
**Launch languages:**
- English (primary)

**Post-launch potential:**
- Spanish
- French
- German
- Portuguese
- Russian
- Chinese (Simplified)
- Japanese

---

## 📊 Balancing Considerations

### Resource Balance
```
Starting Resources:
- Wood: 50
- Metal: 20
- Stone: 30
- Fuel: 10

Day 1 Available (if gather everything):
- Wood: ~150 (3 nodes × ~35 each + starting)
- Metal: ~80
- Stone: ~100
- Fuel: ~30

Minimum Defense for Night 1:
- 2 Walls (10 wood, 20 stone)
- 1 Barricade (3 wood)
- 1 Turret (10 wood, 15 metal)
- Total: 23 wood, 15 metal, 20 stone
```

### Enemy Scaling
```
Night 1:  10 enemies (50 HP total)
Night 5:  25 enemies (150 HP total) + mini-boss
Night 10: 50 enemies (400 HP total) + boss
Night 15: 75 enemies (700 HP total) + 2 bosses
Night 20: 100 enemies (1200 HP total) + final boss gauntlet
Night 30: Endless waves until victory/death
```

### Lighthouse HP Scaling
```
Base HP: 500
With Medic: +50 HP regen over time
With Upgrades: Can reach 750 HP
HP per night:
- Night 1: 500 HP (overkill for tutorial)
- Night 5: 500 HP (getting tight)
- Night 10: Need ~600 HP with upgrades
- Night 20: Need ~750 HP maximum
```

### Time Balance
```
Day Phase: 5 minutes (300 seconds)
- Exploration: ~2 minutes
- Gathering: ~1 minute
- Building: ~1.5 minutes
- Buffer: ~30 seconds

Night Phase: 3-5 minutes
- Night 1-5: ~3 minutes (tutorial pace)
- Night 6-15: ~4 minutes (medium)
- Night 16+: ~5 minutes (intense)
```

---

## 🎮 Controls Schema

### Keyboard & Mouse (Default)

**Movement:**
- `W/A/S/D` - Move keeper
- `Shift` - Sprint (150% speed, drains stamina)

**Combat:**
- `Left Click` - Shoot projectile toward mouse
- `Space` (Hold) - Activate lighthouse beam
- `R` - Reload (if ammo system added)

**Building:**
- `B` - Enter build mode
- `1-9` - Quick-select structure type
- `E` - Place structure / Interact
- `Q` - Cancel build mode
- `Tab` - Open build menu (detailed)

**Actions:**
- `E` - Gather resource / Open door / Repair
- `F` - Use keeper special ability
- `Escape` - Pause menu
- `M` - Toggle map overlay

**UI:**
- `I` - Inventory (if added)
- `T` - Tech tree / Upgrades
- `L` - Lighthouse status

### Controller (Xbox Layout)

**Movement:**
- `Left Stick` - Move keeper
- `Left Stick Click` - Sprint

**Combat:**
- `Right Trigger` - Shoot toward right stick direction
- `Right Bumper` - Lighthouse beam
- `A Button` - Interact / Place structure

**Building:**
- `Y Button` - Enter build mode
- `D-Pad` - Select structure
- `A Button` - Place
- `B Button` - Cancel

**Actions:**
- `X Button` - Keeper special ability
- `Start` - Pause menu
- `Select/Back` - Map overlay

---

## 🎨 Visual Effects Wishlist

### Particle Effects
1. **Hit Sparks** - When projectile hits enemy
2. **Blood Splatter** - Enemy death (stylized, not gory)
3. **Wood Debris** - Structure destruction
4. **Metal Shrapnel** - Turret/trap destroyed
5. **Dust Clouds** - Player running, building placement
6. **Water Splash** - Near coastline
7. **Fog Wisps** - Weather effect
8. **Lightning Strike** - Storm weather
9. **Lighthouse Beam** - Radial light waves
10. **Muzzle Flash** - Gun/turret firing

### Screen Effects
1. **Screen Shake** - On heavy impacts
2. **Chromatic Aberration** - Low lighthouse HP
3. **Vignette** - Darkens edges during night
4. **Red Flash** - Taking damage
5. **Slow Motion** - On lighthouse destruction
6. **Blur** - Pause menu background

### Lighting
1. **Lighthouse Beam** - Rotating, dynamic shadows
2. **Torches** - Flickering point lights
3. **Muzzle Flashes** - Brief light bursts
4. **Enemy Glow** - Slight green glow (identification)
5. **Day/Night Transition** - Global illumination change

---

## 🧪 Testing Checklist

### Functional Testing
- [ ] Can complete full day/night cycle
- [ ] All keepers playable and distinct
- [ ] All enemies spawn correctly
- [ ] Structures build and function
- [ ] Resources gather correctly
- [ ] Lighthouse beam works
- [ ] Win condition triggers
- [ ] Lose condition triggers
- [ ] Save/load works
- [ ] Meta-progression tracks correctly

### Balance Testing
- [ ] Night 1-5 beatable by new player
- [ ] Night 10 challenging but fair
- [ ] Night 20 requires mastery
- [ ] All keepers viable for full run
- [ ] Resources abundant but require planning
- [ ] No dominant strategy (multiple paths to victory)

### Polish Testing
- [ ] All animations smooth (60fps)
- [ ] No audio pops or clicks
- [ ] UI readable at all resolutions
- [ ] Controller input feels good
- [ ] Particles don't tank performance
- [ ] Game feels responsive (<100ms input lag)

### Edge Case Testing
- [ ] What if player builds nothing? (should lose)
- [ ] What if player only builds walls? (should lose later)
- [ ] Can player soft-lock by wasting resources?
- [ ] What if player doesn't explore? (harder but possible)
- [ ] Lighthouse beam with 0 fuel? (doesn't activate)

---

## 📝 Implementation Notes for AI Assistants

### When Building This Game:

**Architecture Principles:**
1. Use **Godot Signals** extensively for decoupling
2. Favor **Composition over Inheritance**
3. Keep systems **modular and testable**
4. Use **Autoload sparingly** (only for true globals)

**Code Style:**
```gdscript
# Use clear, descriptive names
var current_health: int  # Good
var hp: int              # Avoid abbreviations

# Document complex logic
# Calculate enemy budget based on night number
# Formula: base_budget * night_multiplier * difficulty_modifier
var enemy_budget = calculate_enemy_budget(night_number)

# Use enums for states
enum Phase { DAY, TRANSITION, NIGHT }
var current_phase: Phase = Phase.DAY

# Prefer signals over direct calls
signal health_changed(current: int, max: int)
health_changed.emit(current_health, max_health)
```

**Performance Tips:**
1. **Object Pooling** for bullets/particles
2. **Spatial Hashing** for enemy collision detection
3. **Lazy Updates** (not every frame for everything)
4. **Packed Scenes** for instantiation
5. **Process Mode** toggle for pause

**Common Pitfalls to Avoid:**
1. Don't put game logic in `_ready()` (use initialization methods)
2. Don't use `get_node()` in loops (cache references)
3. Don't forget to `queue_free()` removed nodes
4. Don't use global variables for level-specific data
5. Don't hard-code values (use exported variables)

**Testing Approach:**
1. Each major system should work in isolation
2. Create test scenes for individual components
3. Use print statements liberally during development
4. Add debug overlays (pathfinding visualization, etc.)

---

## 🎯 Success Metrics

### Development Success:
- ✅ Prototype in 4 weeks
- ✅ Vertical slice in 8 weeks
- ✅ Content complete in 20 weeks
- ✅ Launch-ready in 28-30 weeks

### Player Success:
- First-time player survives Night 1 (tutorial)
- Experienced player reaches Night 10 (50% of runs)
- Skilled player completes Night 20-30 (10% of runs)
- Meta-progression keeps players engaged for 20+ hours

### Commercial Success:
- 10,000 wishlists before launch
- 85%+ Steam review score
- 5,000+ copies sold in first month
- $50,000+ revenue in first year

---

## 📚 Additional Resources

### Learning Resources:
- **Godot Docs:** https://docs.godotengine.org/
- **GDQuest:** https://www.gdquest.com/
- **Heartbeast:** https://www.youtube.com/@uheartbeast
- **Godot Reddit:** https://www.reddit.com/r/godot/

### Asset Resources:
- **Itch.io:** Free/paid pixel art assets
- **OpenGameArt:** Public domain assets
- **Kenney:** Free game assets
- **Lospec:** Palette and pixel art tools

### Sound Resources:
- **Freesound:** Community sound effects
- **Incompetech:** Royalty-free music
- **SFXR/BFXR:** Generate retro sounds
- **Audacity:** Free audio editing

---

## 🚀 Final Notes

This game is designed to be:
1. **Achievable** - Reasonable scope for solo/small team
2. **Marketable** - Clear hook, proven genres
3. **Replayable** - Roguelike mechanics ensure longevity
4. **Polishable** - 2D pixel art is forgiving
5. **Expandable** - DLC potential for post-launch

**Core Philosophy:**
- Simple mechanics, complex interactions
- Easy to learn, hard to master
- Atmospheric over realistic
- Responsive over realistic

**Remember:**
- Start small, iterate fast
- Prototype core loop first
- Polish is the last 10% that takes 90% of the time
- Community feedback is invaluable

---

## 📄 Version History

- **v1.0** - Initial README (2025-11-01)
  - Complete game design document
  - Technical architecture
  - Development roadmap

---

**Good luck building Last Lighthouse! May your light never fade. 🗼💡**

---

*This README is designed for AI-assisted development. All sections provide sufficient detail for Claude Code, Cursor, or similar AI coding assistants to understand the game architecture and implement features correctly.*
