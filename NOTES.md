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

## Secondary Animation + Managers

### High Level

This part I'm tentatively hopeful for. Basically, I want the ability to play random audio SFX at random times, trigger puffs of smoke, etc., just do random stuff
without specifically needing to set up the nodes for it every single time. I'm trying to accomplish that via a generic `ObjectPool` and manager setup.

I created autoloads for handling audio and particle playback, as well as resources for encoding some important fields for each, i.e. volume, pitch, sample, material,
    particle count, etc.

Via the autoloads I can instance and configure these as single-use objects, or grab one for longer term use.

### Secondary Animation

Kind of a funky thing I'm doing alongside this, so we have these `AudioFrame` and `ParticleFrame` objects that encode the information about a given burst, I also added
`SecondaryFrame` which collects lists of both, allowing multiple audio or particle effects to be triggered at the same frame.

To use this, I attach a `SecondaryAnimator` node to the tree which accepts a target `SpriteAnimator`, and a dictionary of `SecondaryFrames`, mapping animations to
inputs. the `SecondaryAnimator` then listens to `animation_changed` and `frame_changed` signals, triggering effects as they occur.

### Patterns

Two examples currently. `PlayerRun` and `PlayerJetpack`.

In `PlayerRun` we somewhat naively play an audio clip with mild pitch, volume changes on frames 0, 3 of the "Run" animation. This happens automatically without any
    interaction from me.

In `PlayerJetpack`, I request an audio player off the top (technically two), they are saved in the state locally (not in the blackboard), and have their volume altered
    in realtime as I want. 

## State Machines

How does this work in my implementation?

There are two classes that essentially manage everything. StateMachine, and State

This is set up as a hierarchical state machine, where every state can further specify behaviour, so really it's StateMachines the whole way down, but you get the gist.
    On startup, any character or creature that requires it will instantiate a StateMachine, registering the top level states as needed. For a player example, see this:

```gdscript
func _init_state_machine() -> void:
    # Create top level
	state_machine = StateMachine.new()

    # Create and update state trees
	var ground = PlayerGround.new()
	ground.register_states([PlayerRun.new(), Idle.new()])
	var air = PlayerAir.new()
	air.register_states([PlayerJetpack.new(), Fall.new()])
    
    # Register everything with the main machine
	state_machine.register_states([air, ground])
```

### Shared State

On startup, a state machine will be provided with a "blackboard", which is a dictionary containing all sorts of shared state between modules
    There is a risk here that multiple states use the same details, but it's so convenient that I'm not going to worry for now.

The state machine will then "inject" this blackboard into every child state, recursing through the whole structure so that every state
    in the tree shares the same pointer. Transitions are not explicitly defined, but rather the tree will always flow from current state
    to target state based on state contained within this tree, and the current state of each parent node.

### Flow

A StateMachine will check transitions every `tick` invokation by iterating over all states in order, flagging the first valid state.
    If a new, non-null state is found, then we will trigger the state swap by invoking the old state's `exit` method, and the new
    state's `enter` method (passing along a reference to the previous state of the state tree. The `exit` call will recurse down the branch so that
    the very last state in the chain still gets to trigger any `exit` effects.

For each state during this check, the `is_ready` method is invoked to determine whether it should be triggered or not.
    Additionally, because the state readiness checks occur in order, there is an implicit priority to states so that no ties can ever form

When a state is entered, we immediately check for further transitions, we hope to end up at a leaf state in most or all cases.

CRITICAL: All of this control flow control stems from using `super.tick()` at the end of the main `tick` method for a state. If this is omitted then there will be no
    automatic state transitions and control will depend solely on the parent state.
    I intend to use this a lot for combat states, or for handling wonky movement situations

### Patterns

One recurring pattern for me is to have a top level state, i.e. `AirControl` or `GroundControl`, that handles some top-level behaviour, and will return `ready` when an
    entry condition is met, or when a child state is in progress.

For example, during `AirControl`, we enter whenever we are not currently grounded, but we are still able to enter `PlayerJetpack` when we are not in `AirControl`.
    We accomplish this by having the `Jetpack` state check the blackboard for a jump input during the `is_ready` method, and if that input has been provided, then
    we return true regardless of grounded state. This allows the state to actually process and get us off the ground, otherwise we could get 'stuck' grounded if the
    movement was not significant enough.


## Future Plans

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
        - [ ] Idling
        - [ ] Running
        - [ ] Ladder
        - [ ] Landing
    - Combat
        - [ ] Separate movement not a thing
        - [ ] Attacks 1-3 + Special
        - [ ] Damaged
        - [ ] Dash
    - Air
        - [ ] Fall
        - [ ] Jetpack
