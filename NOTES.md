# Junker

## Goals

1. Build a character controller + state machine setup that isn't crazy annoying
    - Animations, hitboxes, behaviour chains, and entry conditions should
        all be configurable
    - This will be specific to 2D/Sprite based animations (should technically
        also work for 3D sprites, but you know)
2. Create a multi-level environment with actual transitions between scenes
3. Write manager(s) for handling one-off effects, i.e. audio, particles, etc.
    - Should create on load, add more when needed, and re-use when done
    - No scripting should be needed for this other than "play particle A"

## State Machines

I want to make a simple 'scripting language' out of nodes. There will be
two kinds of nodes.

1. Action Nodes
2. Utility Nodes

Separate to these is the State Machine which gets given a State, then operates
on that state.

### AI

The goal is for this structure to allow something like:

FrogControl (Utility Node with logic to switch between Patrol and Combat)
    1. Patrol (Custom Utility node, only job is to switch between children)
        - Looping state
        - Continues until finished with wait
        - On exit, saves the last point of patrolling
        - Decision type of node, will execute the underlying 
        - Actions:
            1. Move along path (Action)
            2. Wait a few seconds (Action)
    2. Combat (Utility)
        - Decides when to do which action, waits for a queue from the world
        - to be able to take the next "attack slot" or w/e
        1. Footsie (Action)
            - Just move to a position near-ish the player
        2. Basic Attack (Utility)
            1. Footsie into attack range
            2. Play Attack Animation
        3. Ranged Attack (Utility)
            1. Backpedal to firing range
            2. Play fire animation
                - Tell projectile manager to re-init N projectiles
        4. Tongue Lash (Utility)
            1. Footsie into range
            2. Play Tongue Lash animation

Just as easily as something like:

BeeControl
    - Decides when to buzz around and when to attack
    1. Buzz
        - Looping state, buzzes around within an area
    2. Attack
        - Looping state
        1. Chase Player
        2. Sting Player animation

### Player

The player setup is based a lot more on physics and input than anything else
Should be a characterbody2d to handle the actual movement
Use raycasts to figure out distance to terrain, angle of movement, etc.

Alrighty, so what sort of control flows exist here?

- Movement Control
    - Ground
        - Idling
        - Running
        - Ladder
        - Landing
    - Combat
        - Separate movement not a thing
        - Attacks 1-3 + Special
        - Damaged
        - Dash
    - Air
        - Transitioning from air to ground means we play the landing animation
            first
        - Animated Sprite needs a queue + methods for playing a one-shot or
            skipping to next animation

How do we determine transitions?
- I don't really know offhand. I want to be able to:
	1. determine what input is being requested
	2. switch to that state
	3. queue or trigger an animation
- Keep inputs simple, ground vs air determined by grounded state
- Buttons and Interactions are sent to Combat, if a transition is happening
	then Combat state will say "I'm ready", and the State Machine will switch
	to Combat
	- This "check transitions" phase happens before we process states

### Pseudocode

class StateMachine:
	current_state: State

	func tick(_delta):
		Check Transitions
		If Transition:
			Old State.exit()
			New State.enter()
		Current State.tick()

class State:
	<special variables>
	func enter() -> void:
		pass
	func exit() -> void:
		pass
