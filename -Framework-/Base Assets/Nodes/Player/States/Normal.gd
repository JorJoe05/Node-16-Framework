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
	owner.slope_factor()
	#4. Check for starting a jump.
	if Input.is_action_just_pressed("jump"):
		owner.velocity.x -= owner.jmp * sin(owner.ang)
		owner.velocity.y -= owner.jmp * cos(owner.ang)
		owner.enter_roll()
		state_machine.transition_to("Airborne", {"jump" = true})
		return
	#5. Update Ground Speed based on directional input and apply friction/deceleration.
	owner.floor_movement()
	#6. Check for starting crouching, balancing on ledges, etc.
	#7. Wall sensor collision occurs.
	owner.wall_collision()
	#    Which sensors are used varies based on the the sensor activation.
	#    This occurs before the Player's position physically moves, meaning they might not actually be touching the wall yet, the game accounts for this by adding the Player's X Speed and Y Speed to the sensor's position.
	#8. Check for starting a roll.
	if owner.can_roll():
		owner.enter_roll()
		state_machine.transition_to("Rolling")
	#9. Handle camera boundaries (keep the Player inside the view and kill them if they touch the kill plane).
	#10. Move the Player object
	#    Calculate X Speed and Y Speed from Ground Speed and Ground Angle.
	owner.gsp_to_velocity()
	#    Updates X Position and Y Position based on X Speed and Y Speed.
	owner.move()
	#11. Grounded Ground Sensor collision occurs.
	#    Updates the Player's Ground Angle.
	owner.update_ang()
	#    Align the Player to surface of terrain or become airborne if none found.
	owner.floor_snap()
	owner.switch_mode()
	#owner.Collider.sensors_grounded(owner.gsp, owner.ang==0)
	#12. Check for slipping/falling when Ground Speed is too low on walls/ceilings.
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
	owner.exit_roll()

# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit():
	pass

