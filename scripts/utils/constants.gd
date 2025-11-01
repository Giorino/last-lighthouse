## Global constants and enums for the game
extends Node

## Resource types available in the game
enum ResourceType {
	WOOD,   ## Common, for basic structures
	METAL,  ## Uncommon, for advanced defenses
	STONE,  ## Common, for walls
	FUEL    ## Rare, for lighthouse beam + generators
}

## Game phase states
enum Phase {
	DAY,        ## Exploration and building phase
	TRANSITION, ## Shop and preparation phase
	NIGHT       ## Defense phase
}

## Tile size for grid-based placement
const TILE_SIZE: int = 16

## Day phase duration in seconds
const DAY_DURATION: float = 300.0  # 5 minutes

## Night phase base duration in seconds
const NIGHT_DURATION: float = 180.0  # 3 minutes

## Transition phase duration in seconds
const TRANSITION_DURATION: float = 10.0

## Lighthouse beam fuel cost per second
const BEAM_FUEL_COST: float = 5.0

## Lighthouse beam stun radius
const BEAM_STUN_RADIUS: float = 200.0

## Starting resource amounts
const STARTING_RESOURCES = {
	ResourceType.WOOD: 50,
	ResourceType.METAL: 20,
	ResourceType.STONE: 30,
	ResourceType.FUEL: 10
}
