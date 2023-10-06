@tool
extends Node2D
class_name NewTileCheck

enum Dir {RIGHT, DOWN, LEFT, UP}
enum Axis {X, Y}
enum Mode {NORMAL, EXTENSION, REGRESSION}
enum Solidity {EMPTY, FULL, PARTIAL}

@export var enabled = true:
	set(value):
		enabled = value
		_update()
@export_enum("Right", "Down", "Left", "Up") var direction : int = Dir.DOWN :
	set(value):
		direction = value
		_update()
var axis :
	get:
		return direction % 2
@export var mode = Mode.EXTENSION
@export var hint_color = Color.WHITE
@export_flags_2d_physics var collision_mask = 1

var _top_only_rids = []
var _sides_bottom_rids = []
var _ignore_collision : bool

#----- Exposed Functions -----

func is_colliding() -> bool:
	if _ignore_collision or not enabled:
		return false
	return get_distance_linear() <= 0

func tile_found() -> bool:
	_update()
	if _ignore_collision or not enabled:
		return false
	return $Ray.is_colliding()

func get_distance_linear() -> float:
	if _ignore_collision or not enabled:
		return 16
	var vec = get_distance_vector()
	var point_vec = $Ray.target_position
	var point_ang = -(atan2(point_vec.y, point_vec.x) - (PI/2))
	if tile_found():
		return vec.rotated(point_ang).y
	return 16

func get_distance_vector() -> Vector2:
	if _ignore_collision or not enabled:
		return Vector2.ZERO
	_update()
	return $Ray.get_collision_point() - global_position - _compensation()

func get_normal() -> Vector2:
	if _ignore_collision or not enabled:
		return Vector2.ZERO
	_update()
	return $Ray.get_collision_normal()

func get_slope() -> Vector2:
	if _ignore_collision or not enabled:
		return Vector2.ZERO
	return get_normal().rotated(PI/2)

func get_angle() -> float:
	if _ignore_collision or not enabled:
		return 0
	var vec = get_slope()
	return wrapf(atan2(vec.y, vec.x), 0, PI*2)

func get_solidity():
	var solidity = get_metadata("Solidity")
	if solidity == 1 and direction != Dir.DOWN:
		_ignore_collision = true
	elif solidity == 2:# and direction == Dir.DOWN:
		_ignore_collision = true
	else:
		_ignore_collision = false

func get_metadata(string:String):
	var ray = $Ray
	var collider = ray.get_collider()
	if collider is TileMap:
		var map_position = collider.local_to_map(ray.get_collision_point())
		var tile_data = collider.get_cell_tile_data(0, map_position)
		if tile_data is TileData:
			var data = tile_data.get_custom_data(string)
			return data

#----- Update Functions -----

func _compensation():
	var vectors = [
		Vector2(1, 0.5),
		Vector2(0.5, 1),
		Vector2(0, 0.5),
		Vector2(0.5, 0)
	]
	return vectors[direction]

func _update():
	var ray = $Ray
	var offset = 16
	
	ray.enabled = enabled
	
	#Position and Extension
	ray.force_raycast_update()
	var global_positions = [
		Vector2(global_position.x-offset-(16*int(mode==Mode.REGRESSION)), global_position.y+0.5),
		Vector2(global_position.x+0.5, global_position.y-offset-(16*int(mode==Mode.REGRESSION))),
		Vector2(global_position.x+offset+(16*int(mode==Mode.REGRESSION)), global_position.y+0.5),
		Vector2(global_position.x+0.5, global_position.y+offset+(16*int(mode==Mode.REGRESSION)))
	]
	var target_positions = [
		Vector2(16+(16*int(mode!=Mode.NORMAL)), 0),
		Vector2(0, 16+(16*int(mode!=Mode.NORMAL))),
		Vector2(-16-(16*int(mode!=Mode.NORMAL)), 0),
		Vector2(0, -16-(16*int(mode!=Mode.NORMAL)))
	]
	ray.global_position = global_positions[direction]
	ray.target_position = target_positions[direction]

#----- Core Functions -----

func _ready():
	if not Engine.is_editor_hint():
		var raycast = RayCast2D.new()
		raycast.collision_mask = collision_mask
		raycast.hit_from_inside = true
		raycast.enabled = enabled
		raycast.name = "Ray"
		add_child(raycast)

func _draw():
	if true:#Engine.is_editor_hint():
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
		_update()
