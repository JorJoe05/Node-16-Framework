extends State

# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent):
	pass

# Virtual function. Corresponds to the `_process()` callback.
func update(_delta):
	pass

# Virtual function. Corresponds to the `_physics_process()` callback.
func physics_update(_delta):
	#1. Adjust Ground Speed based on current Ground Angle (Rolling Slope Factors).
	owner.rolling_slope_factor()
	#2. Check for starting a jump.
	if Input.is_action_just_pressed("jump"):
		owner.velocity.x -= owner.jmp * sin(owner.ang)
		owner.velocity.y -= owner.jmp * cos(owner.ang)
		state_machine.transition_to("Airborne", {"jump" = true})
		return
	if abs(owner.gsp) < 0.01:
		state_machine.transition_to("Normal")
	#3. Update Ground Speed based on directional input and apply friction.
	owner.roll_deceleration()
	#4. Wall sensor collision occurs.
	#    Which sensors are used varies based on the the sensor activation.
	#    This occurs before the Player's position physically moves, meaning he might not actually be touching the wall yet, the game accounts for this by adding the Player's X Speed and Y Speed to the sensor's position. 
	owner.wall_collision()
	#5. Handle camera boundaries (keep the Player inside the view and kill them if they touch the kill plane).
	#6. Move the Player object
	#    Calculate X Speed and Y Speed from Ground Speed and Ground Angle.
	owner.gsp_to_velocity()
	#    Update X Position and Y Position based on X Speed and Y Speed.
	owner.move()
	#7. Grounded Ground Sensor collision occurs.
	#    Updates the Player's Ground Angle.
	owner.update_ang()
	#    Align the Player to surface of terrain or become airborne if none found.
	owner.floor_snap()
	owner.switch_mode()
	#8. Check for slipping/falling when Ground Speed is too low on walls/ceilings.
	if abs(owner.gsp) >= 8:
		GlobalCamera.speed.y = 24
	else:
		GlobalCamera.speed.y = 6
	GlobalCamera.use_grounded_margin = true
	GlobalCamera.focus()
	pass

# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg = {}):
	pass

# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit():
	pass

