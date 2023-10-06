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
	if Input.is_action_just_released("jump"):
		if owner.velocity.y < -4:
			owner.velocity.y = -4
	#2. Check for turning Super.
	#3. Update X Speed based on directional input.
	owner.airborne_movement()
	#4. Apply air drag.
	owner.air_drag()
	#5. Move the Player object
	#    Updates X Position and Y Position based on X Speed and Y Speed.
	owner.move()
	GlobalCamera.speed.y = 24
	GlobalCamera.use_grounded_margin = false
	GlobalCamera.focus()
	#6. Apply gravity.
	#    Update Y Speed by adding gravity to it.
	#    This happens after the Player's position was updated. This is an important detail for ensuring the Player's jump height is correct.
	owner.velocity.y += owner.grv
	#7. Check underwater for reduced gravity.
	#8. Rotate Ground Angle back to 0.
	#9. All air collision checks occur here.
	owner.switch_mode(0)
	#    The sensors used depend on the sensor activation.
	#    Active Airborne Push Sensors check first, then the active Airborne Ground Sensors/Ceiling Sensors second.
	owner.wall_collision()
	owner.floor_collision()
	owner.ceiling_collision()
	pass

# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg = {}):
	pass

# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit():
	pass

