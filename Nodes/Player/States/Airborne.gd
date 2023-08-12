extends State

# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent):
	pass

# Virtual function. Corresponds to the `_process()` callback.
func update(_delta):
	pass

# Virtual function. Corresponds to the `_physics_process()` callback.
func physics_update(_delta):
	#1. Check for jump button release (variable jump velocity).
	#2. Check for turning Super.
	#3. Update X Speed based on directional input.
	#4. Apply air drag.
	#5. Move the Player object
	#    Updates X Position and Y Position based on X Speed and Y Speed.
	#6. Apply gravity.
	#    Update Y Speed by adding gravity to it.
	#    This happens after the Player's position was updated. This is an important detail for ensuring the Player's jump height is correct.
	#7. Check underwater for reduced gravity.
	#8. Rotate Ground Angle back to 0.
	#9. All air collision checks occur here.
	#    The sensors used depend on the sensor activation.
	#    Active Airborne Push Sensors check first, then the active Airborne Ground Sensors/Ceiling Sensors second.
	pass

# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg = {}):
	pass

# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit():
	pass

