# How to Play Last Lighthouse - Phase 1 Prototype

## Running the Game

1. Open the project in Godot 4.5
2. Press **F5** or click the Play button
3. The game will start immediately in Day Phase

## What You'll See

### Visual Guide:
- **Dark blue/gray background** - The game world
- **Light gray/white rectangle (center)** - The Lighthouse (with a yellow glow)
- **Light blue square** - Your Keeper (player character)
- **Brown squares** - Resource nodes (wood)
- **Gray square** - Metal resource node
- **Green squares** - Crawler enemies (spawn at night)
- **Tan squares** - Walls (when you build them)

### HUD (Top of screen):
- **Left panel** - Your resources (Wood, Metal, Stone, Fuel)
- **Center panel** - Current phase (DAY/TRANSITION/NIGHT) and time remaining
- **Right panel** - Lighthouse HP bar

## Controls

### Movement:
- **W/A/S/D** or **Arrow Keys** - Move your keeper around

### Actions:
- **E** - Gather resources (stand near brown/gray squares and hold E for 2 seconds)
- **B** - Toggle build mode
  - In build mode, move mouse and left-click to place walls
  - Right-click to cancel build mode
- **Space** (hold) - Activate lighthouse beam
  - Stuns nearby enemies
  - Drains fuel (watch your fuel count!)

## Game Flow

### Day Phase (5 minutes):
1. **Explore** - Move around the map
2. **Gather** - Collect resources from brown (wood) and gray (metal) squares
   - Stand near them and press E
   - Wait 2 seconds for the progress bar
3. **Build** - Press B to enter build mode
   - Place walls to protect the lighthouse
   - Costs: 5 Wood + 10 Stone per wall
4. **Prepare** - Get ready for night!

### Night Phase (Variable duration):
1. **Green enemies spawn** from the edges
2. **Defend the lighthouse** - They will pathfind toward the center
3. **Use walls** to block enemies
4. **Use lighthouse beam** (Space) to stun enemies in a large radius
5. **Survive** until all enemies are dead

### Win/Loss:
- **Win**: Survive the night (all enemies defeated)
- **Lose**: Lighthouse HP reaches 0
- After winning a night, you progress to the next day with more enemies!

## Tips:
1. **Gather resources first** - You need materials to build defenses
2. **Build walls early** - Before night comes
3. **Save some fuel** - The lighthouse beam is powerful but drains fuel quickly
4. **Watch the timer** - You get warnings at 30s and 10s before night
5. **Walls can be damaged** - Enemies will attack them if they block the path

## Known Phase 1 Limitations:
- No proper sprites (just colored rectangles)
- Simple direct pathfinding (enemies go straight to lighthouse)
- Only one enemy type (Crawler)
- Only one structure type (Wall)
- No sound or music yet
- Basic UI

## Debug Info:
- Check the Godot console (bottom panel) for game events
- You'll see messages like "Day started", "Night started", "Enemy died", etc.

Enjoy testing Phase 1!
