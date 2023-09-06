extends Entity

enum Dir {RIGHT, DOWN, LEFT, UP}
enum Mode {FLOOR, RIGHTWALL, CEILING, LEFTWALL}

@onready var Collider = $PlayerCollider
@export var width_radius = 9
@export var height_radius = 19
@export var roll_width_radius = 7
@export var roll_height_radius = 14

var control_lock_timer : int = 0

var test = 0

const acc = 0.046875 # 12 subpixels
const dec = 0.5 # 128 subpxels
const frc = 0.046875 # 12 subpixels
const top = 6
const grv = 0.21875 # 56 subpixels
const jmp = 6.5

const slp = 0.125 # 32 subpixels
const slp_up = 0.078125 # 20 subpixels
const slp_down = 0.3125 # 80 subpixels
const slp_min = 0.05078125 # 13 subpixels

# ----- built-in functions -----

func _ready():
	pass

# ----- collision -----

func can_snap_floor():
	var dist = Collider.get_dist_linear_floor()
	var vh = velocity.y if Collider.direction % 2 == 0 else velocity.x
	return abs(dist) <= 14
	#return dist >= -14 and dist <= min(abs(vh) + 4, 14)

func floor_collision():
	if Collider.get_dist_linear_floor() < 0:
		position += Collider.get_dist_vector_floor()
		update_ang()
		land_on_floor()
		$StateMachine.transition_to("Normal")

func wall_collision():
	if Collider.get_dist_linear_left_wall() < 0:
		position += Collider.get_dist_vector_left_wall()
		velocity.x = 0
		gsp=0
	if Collider.get_dist_linear_right_wall() < 0:
		position += Collider.get_dist_vector_right_wall()
		velocity.x = 0
		gsp=0

func ceiling_collision():
	if Collider.get_dist_linear_ceiling() < 0:
		position += Collider.get_dist_vector_ceiling()
		velocity.y = 0

func floor_snap():
	if can_snap_floor():
		position += Collider.get_dist_vector_floor()
	if not Collider.tile_found_floor():
		$StateMachine.transition_to("Airborne")

# ----- update functions -----

func update_ang(use_ceiling:=false):
	var nrm = Collider.get_normal_floor().rotated(PI/2)
	if Collider.tile_found_floor():
		ang = atan2(-nrm.y, nrm.x)
	else:
		ang = 0

func switch_mode(mode:int=-1) -> int:
	var to = wrapi(round(ang/(PI/2)), 0, 4) if mode == -1 else mode
	Collider.direction = 0
	match to:
		0:
			Collider.direction = Collider.Dir.DOWN
			return Mode.FLOOR
		1:
			Collider.direction = Collider.Dir.RIGHT
			return Mode.RIGHTWALL
		2:
			Collider.direction = Collider.Dir.UP
			return Mode.CEILING
		3:
			Collider.direction = Collider.Dir.LEFT
			return Mode.LEFTWALL
	return Mode.FLOOR

func control_lock_update():
	control_lock_timer = move_toward(control_lock_timer, 0, 1)

# ----- state changes -----

func land_on_floor():
	var degrees = wrapi(round(rad_to_deg(ang)), 0, 360)
	var degrees_offset = wrapi(degrees, -180, 180)
	if (0 <= degrees and degrees <= 23) or (339 <= degrees and degrees <= 360):
		gsp = velocity.x
	elif (24 <= degrees and degrees <= 45) or (316 <= degrees and degrees <= 338):
		gsp = velocity.y * 0.5 * -sign(sin(degrees_offset))
	else:
		gsp = velocity.y * -sign(sin(degrees_offset))
	if mostly_moving() == Dir.LEFT or mostly_moving() == Dir.RIGHT:
		gsp = velocity.x
	print(degrees_offset)

func land_on_ceiling():
	var degrees = wrapi(round(rad_to_deg(ang)), 0, 360)
	if 91 <= degrees <= 135 or 226 <= degrees <= 270:
		#reattach
		gsp = velocity.y * -sign(sin(ang))
	else:
		velocity.y = 0

func enter_roll():
	position.y += Collider.height_radius - roll_height_radius
	Collider.width_radius = roll_width_radius
	Collider.height_radius = roll_height_radius

func exit_roll():
	position.y += Collider.height_radius - height_radius
	Collider.width_radius = width_radius
	Collider.height_radius = height_radius

# ----- movement -----

func floor_movement():
	if Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
		if gsp > 0:
			gsp -= dec
			if gsp <= 0:
				gsp = -0.5
		elif gsp > -top:
			gsp -= acc
			gsp = max(gsp, -top)
	elif Input.is_action_pressed("right") and !Input.is_action_pressed("left"):
		if gsp < 0:
			gsp += dec
			if gsp >= 0:
				gsp = 0.5
		elif gsp < top:
			gsp += acc
			gsp = min(gsp, top)
	else:
		gsp -= min(abs(gsp), frc) * sign(gsp)

func airborne_movement():
	if Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
		if velocity.x > -top:
			velocity.x -= acc*2
			velocity.x = max(velocity.x, -top)
	elif Input.is_action_pressed("right") and !Input.is_action_pressed("left"):
		if velocity.x < top:
			velocity.x += acc*2
			velocity.x = min(velocity.x, top)

func roll_deceleration():
	if Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
		if gsp > 0:
			gsp -= dec/4
			if gsp <= 0:
				gsp = -0.5
	elif Input.is_action_pressed("right") and !Input.is_action_pressed("left"):
		if gsp < 0:
			gsp += dec/4
			if gsp >= 0:
				gsp = 0.5
	gsp -= min(abs(gsp), frc/2) * sign(gsp)

func slope_factor():
	gsp -= slp*sin(ang)

func rolling_slope_factor():
	var slope = slp_up if sign(gsp) == sign(ang) else slp_down
	gsp -= slope*sin(ang)

func air_drag():
	if velocity.y < 0 and velocity.y > -4:
		velocity.x -= (floor(velocity.x / 0.125) / 256)

# ----- miscellaneous checks -----

func can_slip_s3():
	var degrees = wrapi(round(rad_to_deg(ang)), 0, 360)
	if degrees >= 35 and degrees <= 326:
		if degrees >= 69 and degrees <= 293:
			return 2
		return 1
	return 0

func can_slip():
	var degrees = wrapi(round(rad_to_deg(ang)), 0, 360)
	if degrees >= 46 and degrees <= 315:
		return true
	return false

func can_roll():
	if not (Input.is_action_pressed("left") or Input.is_action_pressed("right")):
		if Input.is_action_pressed("down") and abs(gsp) >= 0.5:
			return true
	return false

func mostly_moving() -> int:
	var rad = atan2(velocity.y, velocity.x)
	return wrapi(round(rad/(PI/2)), 0, 4)
	# 0=Right 1=Down 2=Left 3=Up

func _physics_process(delta):
	pass
	#test += 0.005
	#velocity = Vector2.RIGHT.rotated(test)*3
	#print(mostly_moving())
	#print(RMath.ANGLELIST.size())
	#position += velocity
