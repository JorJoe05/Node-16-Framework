@tool
extends Node2D
class_name TileCheck

enum Dir {RIGHT, DOWN, LEFT, UP}
enum Axis {X, Y}
enum Mode {NORMAL, EXTENSION, REGRESSION}
enum Solidity {EMPTY, FULL, PARTIAL}

@export_enum("Right", "Down", "Left", "Up") var direction : int = Dir.DOWN :
	set(value):
		direction = value
		_update()
var axis :
	get:
		return direction % 2
var mode = Mode.NORMAL
@export var hint_color = Color.WHITE
@export_flags_2d_physics var collision_mask = 1

@export var force_int = false

func is_colliding():
	_update()
	return get_distance_linear() <= 0 

func tile_found():
	_update()
	return $Primary.is_colliding() or $Secondary.is_colliding() or $Primary_R.is_colliding() or $Secondary_R.is_colliding()

func get_distance_linear():
	_update()
	match mode:
		Mode.NORMAL:
			return _get_dist($Primary) - _get_dist_offset()
		Mode.EXTENSION:
			return _get_dist($Primary) + _get_dist($Secondary) - _get_dist_offset()
		Mode.REGRESSION:
			return _get_dist($Primary) + _get_dist($Secondary) - _get_dist_offset() - 16

func get_distance_vector():
	return get_distance_linear() * _get_dir_vector()

func get_normal():
	_update()
	return $Span.get_collision_normal()

func get_slope():
	return get_normal().rotated(PI/2)

func get_angle():
	return wrapf(atan2(get_slope().y, get_slope().x), 0, PI*2)

func get_angle_hex():
	return floor(get_angle() * 256/(2*PI))

# All functions beginning with an underscore are used internally and should not be modified

func _ready():
	if !Engine.is_editor_hint():
		for f in range(0, 5):
			var names = ["Primary", "Primary_R", "Secondary", "Secondary_R", "Span"]
			var node = RayCast2D.new()
			node.name = names[f]
			node.hit_from_inside = true
			add_child(node)
		_update()

func _var_floor(value):
	if force_int:
		return floor(value)
	return value

func _var_ceil(value):
	if force_int:
		return ceil(value)
	return value#+1

func _get_dir_vector(abs=false):
	var vector = Vector2(1, 0) if direction == Dir.RIGHT \
	else Vector2(0, 1) if direction == Dir.DOWN \
	else Vector2(-1, 0) if direction == Dir.LEFT \
	else Vector2(0, -1)
	return vector if abs == false else Vector2(abs(vector.x), abs(vector.y))

func _get_dist_offset(abs=false):
	var sign = -1 if direction == Dir.LEFT or direction == Dir.UP else 1
	sign = 1 if abs == true else sign
	if sign == 1:
		return wrapf(_var_floor(global_position.x), 0, 16)+1 if axis == Axis.X else wrapf(_var_floor(global_position.y), 0, 16)+1
	else:
		return 16-wrapf(_var_floor(global_position.x), 0, 16) if axis == Axis.X else 16-wrapf(_var_floor(global_position.y), 0, 16)
	#var _var_floor_ceil = func _var_floor_ceil(value, sign):
	#	return _var_floor(value) if sign == 1 else _var_ceil(value)
	#var sign = -1 if direction == Dir.LEFT or direction == Dir.UP else 1
	#sign = 1 if abs == true else sign
	#var pad = -1 if sign == -1 else 0
	#return wrapf(_var_floor_ceil.call(global_position.x*sign, sign), 0, 16)+pad+1 if axis == Axis.X else wrapf(_var_floor_ceil.call(global_position.y*sign, sign), 0, 16)+pad+1

func _get_dist(sensor):
	if sensor.is_colliding():
		return _var_floor((sensor.get_collision_point().x - sensor.global_position.x) * sign(sensor.target_position.x)) if axis == Axis.X \
		else _var_floor((sensor.get_collision_point().y - sensor.global_position.y) * sign(sensor.target_position.y))
	else:
		return 16

func _check_solidity():
	if _get_dist($Primary) == 16 or _get_dist($Primary_R) == 16:
		return Solidity.EMPTY
	elif _get_dist($Primary) == 0 and _get_dist($Primary_R) == 0 and ($Primary.is_colliding() or $Primary_R.is_colliding()):
		return Solidity.FULL
	else:
		return Solidity.PARTIAL

func _switch_mode():
	mode = Mode.EXTENSION if _check_solidity() == Solidity.EMPTY \
	else Mode.REGRESSION if _check_solidity() == Solidity.FULL \
	else Mode.NORMAL

func _update():
	if !is_node_ready():
		await ready
	var ext = func ext():
		var tmp = 0 if mode == Mode.NORMAL else 16 if mode == Mode.EXTENSION else -16
		return -tmp if direction == Dir.LEFT or direction == Dir.UP else tmp
	var shift : int = 16 if direction == Dir.LEFT or direction == Dir.UP else 0
	var global_pos = \
		Vector2(floor(global_position.x/16)*16+shift, floor(global_position.y)+0.5) if axis == Axis.X \
		else Vector2(floor(global_position.x)+0.5, floor(global_position.y/16)*16+shift)
	var global_pos_secondary = \
		Vector2(floor(global_position.x/16)*16+shift+ext.call(), floor(global_position.y)+0.5) if axis == Axis.X \
		else Vector2(floor(global_position.x)+0.5, floor(global_position.y/16)*16+shift+ext.call())
	$Primary.global_position = global_pos
	$Primary.target_position = _get_dir_vector() * 16
	$Primary.force_raycast_update()
	$Primary_R.position = $Primary.position + $Primary.target_position
	$Primary_R.target_position = -$Primary.target_position
	$Primary_R.force_raycast_update()
	_switch_mode()
	$Secondary.global_position = global_pos_secondary
	$Secondary.target_position = _get_dir_vector() * 16
	$Secondary.force_raycast_update()
	$Secondary_R.position = $Secondary.position + $Secondary.target_position
	$Secondary_R.target_position = -$Secondary.target_position
	$Secondary_R.force_raycast_update()
	$Span.position = $Secondary.position if mode == Mode.REGRESSION else $Primary.position
	$Span.target_position = 16*_get_dir_vector() if mode == Mode.NORMAL else 32*_get_dir_vector()

func _draw():
	if Engine.is_editor_hint():
		var offset = -Vector2(wrapf(global_position.x, 0, 1), wrapf(global_position.y, 0, 1))
		var vert1 = offset + Vector2(1, -0.5).rotated(direction*PI/2) + Vector2(0.5, 0.5)
		var vert2 = offset + Vector2(1, 0.5).rotated(direction*PI/2) + Vector2(0.5, 0.5)
		var vert3 = offset + Vector2(2, 0).rotated(direction*PI/2) + Vector2(0.5, 0.5)
		var arrow_color = Color(hint_color.r, hint_color.g, hint_color.b, 0.5)
		draw_rect(Rect2(offset, Vector2(1, 1)), hint_color)
		draw_polygon([vert1, vert2, vert3], [arrow_color, arrow_color, arrow_color])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()
	else:
		_update()
