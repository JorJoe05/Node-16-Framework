@tool
extends Node2D
class_name NewTileCheck

enum Dir {RIGHT, DOWN, LEFT, UP}
enum Axis {X, Y}
enum Mode {NORMAL, EXTENSION, REGRESSION}
enum Solidity {EMPTY, FULL, PARTIAL}

@export_enum("Right", "Down", "Left", "Up") var direction : int = Dir.DOWN :
	set(value):
		direction = value
var axis :
	get:
		return direction % 2
@export var mode = Mode.NORMAL
@export var hint_color = Color.WHITE
@export_flags_2d_physics var collision_mask = 1

@export var force_int = false

#----- Exposed Functions -----

func get_distance_linear() -> float:
	var vec = get_distance_vector()
	return sqrt((vec.x**2) + (vec.y**2))

func get_distance_vector() -> Vector2:
	return $Ray.get_collision_point() - global_position

func get_normal() -> Vector2:
	return $Ray.get_collision_normal()

func get_slope() -> Vector2:
	return get_normal().rotated(PI/2)

func get_angle() -> float:
	var vec = get_slope()
	return atan2(vec.y, vec.x)

#----- Update Functions -----

func _get_grid_cell(coords:Vector2) -> Vector2:
	var x = floor(coords.x/16)*16
	var y = floor(coords.y/16)*16
	return Vector2(x, y)

func _update():
	var ray = $Ray
	
	#Position and Extension
	var global_positions = [
		Vector2(_get_grid_cell(global_position).x-(16*int(mode==Mode.REGRESSION)), floor(global_position.y)+0.5),
		Vector2(floor(global_position.x)+0.5, _get_grid_cell(global_position).y-(16*int(mode==Mode.REGRESSION))),
		Vector2(_get_grid_cell(global_position).x+16+(16*int(mode==Mode.REGRESSION)), floor(global_position.y)+0.5),
		Vector2(floor(global_position.x)+0.5, _get_grid_cell(global_position).y+16+(16*int(mode==Mode.REGRESSION)))
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
	if true:#not Engine.is_editor_hint():
		var raycast = RayCast2D.new()
		raycast.collision_mask = collision_mask
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
	else:
		_update()
