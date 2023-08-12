extends State

# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent):
	pass

# Virtual function. Corresponds to the `_process()` callback.
func update(_delta):
	pass

# Virtual function. Corresponds to the `_physics_process()` callback.
func physics_update(_delta):
	#1. Check for special animations that prevent control (such as balancing).
	#2. Check for starting a spindash while crouched.
	#3. Adjust Ground Speed based on current Ground Angle (Slope Factor).
	slope_factor()
	#4. Check for starting a jump.
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Airborne", {"jump" = true})
	#5. Update Ground Speed based on directional input and apply friction/deceleration.
	floor_movement()
	#6. Check for starting crouching, balancing on ledges, etc.
	#7. Wall sensor collision occurs.
	#    Which sensors are used varies based on the the sensor activation.
	#    This occurs before the Player's position physically moves, meaning they might not actually be touching the wall yet, the game accounts for this by adding the Player's X Speed and Y Speed to the sensor's position.
	#8. Check for starting a roll.
	#9. Handle camera boundaries (keep the Player inside the view and kill them if they touch the kill plane).
	#10. Move the Player object
	#    Calculate X Speed and Y Speed from Ground Speed and Ground Angle.
	#    Updates X Position and Y Position based on X Speed and Y Speed.
	#11. Grounded Ground Sensor collision occurs.
	#    Updates the Player's Ground Angle.
	#    Align the Player to surface of terrain or become airborne if none found.
	#12. Check for slipping/falling when Ground Speed is too low on walls/ceilings.
	pass

func floor_movement():
	if Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
		if owner.gsp > 0:
			owner.gsp -= owner.dec
			if owner.gsp <= 0:
				owner.gsp = -0.5
		else:
			owner.gsp = move_toward(owner.gsp, min(owner.gsp, -owner.top), owner.acc)
	elif Input.is_action_pressed("right") and !Input.is_action_pressed("left"):
		if owner.gsp < 0:
			owner.gsp += owner.dec
			if owner.gsp >= 0:
				owner.gsp = 0.5
		else:
			owner.gsp = move_toward(owner.gsp, max(owner.gsp, owner.top), owner.acc)
	else:
		owner.gsp = move_toward(owner.gsp, 0, min(abs(owner.gsp), owner.frc))

func s3_slip():
	var degrees = wrapi(round(rad_to_deg(owner.ang)), 0, 360)
	if degrees >= 35 and degrees <= 326:
		if degrees >= 69 and degrees <= 293:
			return 2
		return 1
	return 0

func can_slip():
	var degrees = wrapi(round(rad_to_deg(owner.ang)), 0, 360)
	if degrees >= 46 and degrees <= 315:
		return true
	return false

func slope_factor():
	owner.gsp -= owner.slp*sin(owner.ang)

func rolling_slope_factor():
	var slope = owner.slp_up if sign(owner.gsp) == sign(owner.ang) else owner.slp_down
	owner.gsp -= owner.slope*sin(owner.ang)

# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg = {}):
	pass

# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit():
	pass

