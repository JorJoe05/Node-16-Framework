extends Entity

enum Dir {RIGHT, DOWN, LEFT, UP}
enum Mode {FLOOR, RIGHTWALL, CEILING, LEFTWALL}

@onready var Collider = $PlayerCollider

var control_lock_timer : int = 0

var test = 0

const acc = 0.046875 # 12 subpixels
const dec = 0.5 # 128 subpxels
const frc = 0.046875 # 12 subpixels
const top = 6
const grv = 0.21875 # 56 subpixels

const slp = 0.125 # 32 subpixels
const slp_up = 0.078125 # 20 subpixels
const slp_down = 0.3125 # 80 subpixels
const slp_min = 0.05078125 # 13 subpixels

func _ready():
	pass

func mostly_moving_retro():
	var hex = RMath.hex_point_dir(velocity.x, velocity.y)
	if 255 >= hex and hex >= 224:
		return Dir.RIGHT
	elif 223 >= hex and hex >= 160:
		return Dir.UP
	elif 159 >= hex and hex >= 96:
		return Dir.LEFT
	elif 95 >= hex and hex >= 32:
		return Dir.DOWN
	elif 31 >= hex and hex >= 0:
		return Dir.RIGHT

func mostly_moving() -> int:
	var rad = atan2(velocity.y, velocity.x)
	return wrapi(round(rad/(PI/2)), 0, 4)
	# 0=Right 1=Down 2=Left 3=Up

func switch_mode_retro():
	var degrees = wrapi(round(rad_to_deg(ang)), 0, 360)
	if degrees >= 0 and degrees <= 46:
		Collider.direction = Collider.Dir.DOWN
	elif degrees >= 46 and degrees <= 135:
		Collider.direction = Collider.Dir.RIGHT
	elif degrees >= 135 and degrees <= 226:
		Collider.direction = Collider.Dir.UP
	elif degrees >= 226 and degrees <= 315:
		Collider.direction = Collider.Dir.LEFT
	elif degrees >= 315 and degrees <= 360:
		Collider.direction = Collider.Dir.DOWN

func switch_mode(mode:int=-1) -> int:
	var to = wrapi(round(ang/(PI/2)), 0, 4) if mode == -1 else mode
	match to:
		0:
			return Mode.FLOOR
		1:
			return Mode.RIGHTWALL
		2:
			return Mode.CEILING
		3:
			return Mode.LEFTWALL
	return Mode.FLOOR

func control_lock_update():
	control_lock_timer = move_toward(control_lock_timer, 0, 1)

func land_on_floor():
	var degrees = wrapi(round(rad_to_deg(ang)), 0, 360)
	if 0 <= degrees <= 23 or 339 <= degrees <= 360:
		gsp = velocity.x
	elif 24 <= degrees <= 45 or 316 <= degrees <= 338:
		gsp = velocity.y * 0.5 * -sign(sin(ang))
	else:
		gsp = velocity.y * -sign(sin(ang))
	if mostly_moving() == Dir.LEFT or mostly_moving() == Dir.RIGHT:
		gsp = velocity.x

func land_on_ceiling():
	var degrees = wrapi(round(rad_to_deg(ang)), 0, 360)
	if 91 <= degrees <= 135 or 226 <= degrees <= 270:
		#reattach
		gsp = velocity.y * -sign(sin(ang))
	else:
		velocity.y = 0

func _physics_process(delta):
	pass
	#test += 0.005
	#velocity = Vector2.RIGHT.rotated(test)*3
	#print(mostly_moving())
	#print(RMath.ANGLELIST.size())
	#position += velocity
