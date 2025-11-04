# Art Asset Guide - Last Lighthouse

This guide explains the art asset structure and import guidelines for Last Lighthouse.

## Asset Directory Structure

```
assets/
├── sprites/
│   ├── characters/
│   │   ├── keepers/
│   │   │   ├── engineer.png
│   │   │   ├── soldier.png
│   │   │   ├── scavenger.png
│   │   │   └── medic.png
│   │   └── animations/
│   │       ├── keeper_walk.png
│   │       ├── keeper_idle.png
│   │       └── keeper_interact.png
│   ├── enemies/
│   │   ├── crawler.png
│   │   ├── spitter.png
│   │   ├── brute.png
│   │   ├── swarm.png
│   │   └── bosses/
│   │       └── [boss sprites]
│   ├── structures/
│   │   ├── lighthouse.png
│   │   ├── wall.png
│   │   ├── barricade.png
│   │   ├── turret.png
│   │   ├── trap.png
│   │   └── generator.png
│   ├── environment/
│   │   ├── resource_nodes/
│   │   │   ├── wood_node.png
│   │   │   ├── metal_node.png
│   │   │   ├── stone_node.png
│   │   │   └── fuel_node.png
│   │   ├── terrain/
│   │   │   ├── ground_tiles.png
│   │   │   ├── ruins.png
│   │   │   └── decorations.png
│   │   └── weather/
│   │       └── [weather effects]
│   ├── ui/
│   │   ├── hud/
│   │   │   ├── resource_icons.png
│   │   │   ├── health_bar.png
│   │   │   └── ability_icons.png
│   │   ├── menus/
│   │   │   ├── buttons.png
│   │   │   ├── panels.png
│   │   │   └── backgrounds.png
│   │   └── icons/
│   │       └── [various UI icons]
│   └── effects/
│       ├── particles/
│       │   ├── hit_particle.png
│       │   ├── explosion_particle.png
│       │   ├── muzzle_flash.png
│       │   └── build_particle.png
│       ├── projectiles/
│       │   ├── bullet.png
│       │   └── beam_segment.png
│       └── lighting/
│           └── lighthouse_beam.png
├── audio/
│   ├── sfx/
│   │   ├── combat/
│   │   │   ├── hit_light.wav
│   │   │   ├── hit_heavy.wav
│   │   │   ├── enemy_death.wav
│   │   │   └── turret_shoot.wav
│   │   ├── building/
│   │   │   ├── structure_place.wav
│   │   │   ├── structure_destroy.wav
│   │   │   └── repair.wav
│   │   ├── ui/
│   │   │   ├── button_click.wav
│   │   │   ├── menu_open.wav
│   │   │   └── notification.wav
│   │   └── ambient/
│   │       ├── wind.wav
│   │       └── lighthouse_hum.wav
│   └── music/
│       ├── day_theme.ogg
│       ├── night_theme.ogg
│       ├── boss_theme.ogg
│       └── menu_theme.ogg
└── fonts/
    └── [pixel fonts for UI]
```

## Pixel Art Requirements

### Base Resolution
- **Game Resolution:** 320x180 pixels (scaled 6x to 1920x1080)
- **Tile Size:** 16x16 pixels for grid-based placement
- All sprites must align to pixel grid for crisp rendering

### Sprite Sizes (Guidelines)

**Characters:**
- Keeper: 16x24 pixels (1 tile wide, 1.5 tiles tall)
- Crawler: 12x12 pixels
- Spitter: 14x14 pixels
- Brute: 20x24 pixels
- Swarm: 8x8 pixels

**Structures:**
- Lighthouse: 32x48 pixels (centerpiece, larger)
- Wall: 16x16 pixels (1 tile)
- Barricade: 16x16 pixels
- Turret: 16x20 pixels
- Trap: 16x16 pixels
- Generator: 20x20 pixels

**Effects:**
- Particles: 2x2 to 4x4 pixels
- Muzzle flash: 8x8 pixels
- Projectiles: 4x4 pixels

### Color Palette
- **Atmospheric Theme:** Dark, moody palette with limited colors
- **Recommended Palette:**
  - Background: Dark blues/grays (#1a2332, #2d3e50)
  - Lighthouse: Warm yellows/oranges (#ffcc66, #ff9933)
  - Enemies: Reds/purples for horror theme (#8b1e3f, #5a1e5c)
  - Resources: Wood (brown), Metal (gray), Stone (tan), Fuel (orange)
  - UI: High contrast for readability (white text, colored highlights)

### Animation Guidelines

**Frame Rates:**
- Idle animations: 4-6 frames @ 6 FPS
- Walk cycles: 4-8 frames @ 12 FPS
- Attack animations: 3-5 frames @ 10 FPS
- Death animations: 5-7 frames @ 8 FPS

**Naming Convention:**
- `{entity}_{action}_{frame}.png`
- Example: `keeper_walk_01.png`, `crawler_attack_03.png`

## Godot Import Settings

### For Pixel Art Sprites

When importing PNG files, use these settings in Godot:

```
Import Tab:
- Compress: VRAM Uncompressed (or Lossless for better quality)
- Filter: Disabled/Nearest (CRITICAL for pixel art)
- Mipmaps: Disabled
- Repeat: Disabled
```

**In Project Settings:**
- `Rendering > Textures > Canvas Textures > Default Texture Filter` = Nearest

### Sprite Sheets

For animated sprites:
1. Create horizontal sprite sheets (all frames in one row)
2. Set `Hframes` in Sprite2D or AnimatedSprite2D node
3. Use AnimatedSprite2D for complex animations
4. Use Sprite2D + script for simple frame switching

## Current Placeholder Graphics

The following systems currently use colored rectangles/circles as placeholders:

- **Keeper:** ColorRect (16x24, color: green)
- **Enemies:** ColorRect (sizes vary, color: red)
- **Structures:** ColorRect (16x16, colors vary)
- **Lighthouse:** ColorRect (32x48, color: yellow)
- **Particles:** Colored GPU particles (no textures)
- **UI:** Basic Godot controls (buttons, panels)

## Replacing Placeholders

### Step 1: Prepare Assets
1. Create pixel art sprites following size/palette guidelines
2. Export as PNG with transparency
3. Place in appropriate `assets/sprites/` subdirectory

### Step 2: Import to Godot
1. Copy PNG files to project directory
2. Godot auto-imports; verify import settings (Filter = Nearest!)
3. Check `.godot/imported/` for any import errors

### Step 3: Update Scenes
1. Open scene file (e.g., `scenes/characters/keeper_base.tscn`)
2. Select Sprite2D node
3. In Inspector, drag PNG to `Texture` property
4. Adjust `Offset` if needed for centering
5. Save scene

### Step 4: Update Particle Effects
1. Open particle effect scene (e.g., `scenes/effects/hit_effect.tscn`)
2. Select GPUParticles2D node
3. In Process Material, set `Texture` to particle sprite
4. Adjust `Scale` properties as needed

## Art Production Pipeline

### Phase 4 (Current - Polish & Juice)
**Priority: Technical systems with placeholder particles**
- ✅ Particle systems (using colored particles)
- ✅ Screen shake
- ✅ Hit pause
- ✅ Camera effects
- 🎨 **Next:** Sound effects (you'll add audio files to `assets/audio/sfx/`)

### Phase 5 (Future - Content Complete)
**Priority: Replace all placeholders with final art**
1. Core gameplay sprites (keeper, enemies, structures)
2. Environment tiles and decorations
3. UI graphics and icons
4. Particle textures
5. Animation frames

### Phase 6 (Future - Marketing Prep)
**Priority: Polish and presentation**
1. Title screen artwork
2. Promotional screenshots
3. Steam capsule art
4. Trailer assets

## Tools & Resources

**Recommended Software:**
- **Aseprite:** Best pixel art editor (paid, ~$20)
- **Lospec:** Free pixel art editor and palette browser
- **Piskel:** Free online pixel art tool

**Useful Resources:**
- Lospec Palettes: https://lospec.com/palette-list
- Pixel Art Tutorials: https://saint11.org/blog/pixel-art-tutorials/
- Animation Reference: https://www.animatedimages.org/

**Godot-Specific:**
- Pixel art import guide: https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html
- Tilemap setup: https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html

## Testing Your Art

After adding new sprites:
1. Run the game (F5 in Godot)
2. Check sprite scaling (should be crisp, no blur)
3. Verify animations play correctly
4. Test in different game phases (day/night)
5. Check particle effects spawn correctly

## Asset Checklist

Before Phase 4 completion, you need:
- [ ] Sound effects (60+ files)
- [ ] Music tracks (3-4 tracks)

Before Phase 5 completion, you need:
- [ ] All character sprites
- [ ] All enemy sprites
- [ ] All structure sprites
- [ ] Environment tiles
- [ ] UI graphics
- [ ] Particle textures
- [ ] Animation frames

---

**Note:** While the game is fully functional with placeholders, replacing them with proper pixel art will dramatically improve the game feel and marketability. Phase 4 focuses on technical "juice" (which is now implemented), while art assets can be added progressively during Phase 5.
