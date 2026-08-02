class_name PlayerCombat
extends State
# This is basically the same as ground_control, there are different sub-states that can take over here
# depending on previous behaviour
# Available combat states are 1/2/3 combo and dash
# When combat_control is entered, we will figure out which state to enter based on whether it's the
# light, heavy, or dash input that's been provided.
# For this one, when checking transitions, we need to be sure that the previous state is finished first
# if current state is unfinished and blocking, then don't check transitiongts
# Alrighty, we have the blocking for animations bit ready. This thing just needs to pick which state to enter.
# I think we're going to track in this class when the last animation ended
# That will give us the window for triggering follow up animations
