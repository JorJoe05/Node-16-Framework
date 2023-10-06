extends Camera2D

const default_resolution = Vector2(320, 224)
const grounded_margin = Rect2(Vector2(144, 96), Vector2(16, 0))
const airborne_margin = Rect2(Vector2(144, 64), Vector2(16, 64))

const gm_center_origin = Rect2(default_resolution/2 - grounded_margin.position - grounded_margin.size, grounded_margin.size)
const am_center_origin = Rect2(default_resolution/2 - airborne_margin.position - airborne_margin.size, airborne_margin.size)

@export var focus_object : Node2D
var focus_point : Vector2
var margin := am_center_origin
var use_grounded_margin := false :
	set(value):
		margin = gm_center_origin if value else am_center_origin
		use_grounded_margin = value

#Overwritable Properties
var focus_offset : Vector2
var speed := Vector2(24, 24)
var margin_vertical := true

func _copy_constraints():
	pass

func _set_focus_point():
	if not focus_object == null:
		var value = focus_object.global_position
		if "camera_focus_offset" in focus_object:
			value += focus_object.camera_focus_offset
		focus_point = value

func focus():
	_set_focus_point()
	if not focus_object == null:
		#Horizontal Margin
		var h_margin_begin = focus_point.x + margin.position.x
		var h_margin_end = focus_point.x + margin.position.x + margin.size.x
		if position.x < h_margin_begin:
			position.x = min(position.x + speed.x, h_margin_begin)
		elif position.x > h_margin_end:
			position.x = max(position.x - speed.x, h_margin_end)
		#Vertical Margin
		var v_margin_begin = focus_point.y + margin.position.y
		var v_margin_end = focus_point.y + margin.position.y + margin.size.y
		if position.y < v_margin_begin:
			position.y = min(position.y + speed.y, v_margin_begin)
		elif position.y > v_margin_end:
			position.y = max(position.y - speed.y, v_margin_end)
	#position.x = round(position.x)
	#position.y = round(position.y)

func _ready():
	process_physics_priority = 10
