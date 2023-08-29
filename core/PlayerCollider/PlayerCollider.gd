@tool
extends Node2D
class_name PlayerCollider

enum Dir {RIGHT, DOWN, LEFT, UP}
enum Axis {X, Y}

@export var width_radius : int = 9 #7
@export var height_radius : int = 19 #14
@export var push_radius : int = 10 #10
@export_enum("Right", "Down", "Left", "Up") var direction : int = Dir.DOWN:
	set(value):
		direction = value
		_position_sensors()
@export_flags_2d_physics var collision_mask = 1
var shift_sides = false

var sensors = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if !Engine.is_editor_hint():
		for f in range(0, 6):
			var sensor = TileCheck.new()
			sensor.collision_mask = collision_mask
			var suffixes = ["A", "B", "C", "D", "E", "F"]
			sensor.name = "Sensor_" + suffixes[f]
			add_child(sensor)
			sensors.append(get_node("Sensor_" + suffixes[f]))
		_position_sensors()

func _position_sensors():
	var shift = 8 if shift_sides == true else 0
	var sensor_positions = [
		Vector2(-width_radius, height_radius), Vector2(width_radius, height_radius),
		Vector2(-width_radius, -height_radius), Vector2(width_radius, -height_radius),
		Vector2(-push_radius, shift), Vector2(push_radius, shift),
	]
	var sensor_directions = [Dir.DOWN, Dir.DOWN, Dir.UP, Dir.UP, Dir.LEFT, Dir.RIGHT]
	for f in range(0, sensors.size()):
		var sensor_position = sensor_positions[f].rotated((direction-1)*PI/2)
		sensors[f].position = Vector2(round(sensor_position.x), round(sensor_position.y))
		sensors[f].direction = wrapi(sensor_directions[f] + (direction-1), 0, 4)
	queue_redraw()

# ---------- Floor (Sensors A and B) ----------

func get_active_floor_sensor():
	_position_sensors()
	var compare = $Sensor_A.get_distance_linear() <= $Sensor_B.get_distance_linear()
	return $Sensor_A if compare else $Sensor_B

func is_on_floor():
	return get_active_floor_sensor().is_colliding()

func tile_found_floor():
	return get_active_floor_sensor().tile_found()

func get_dist_linear_floor():
	if tile_found_floor():
		return get_active_floor_sensor().get_distance_linear()
	return 0

func get_dist_vector_floor():
	if tile_found_floor():
		return get_active_floor_sensor().get_distance_vector()
	return Vector2.ZERO

func get_normal_floor():
	return get_active_floor_sensor().get_normal()

# ---------- Ceiling (Sensors C and D) ----------

func get_active_ceiling_sensor():
	_position_sensors()
	var compare = $Sensor_C.get_distance_linear() <= $Sensor_D.get_distance_linear()
	return $Sensor_C if compare else $Sensor_D

func is_on_ceiling():
	return $Sensor_C.is_colliding() or $Sensor_D.is_colliding()

func tile_found_ceiling():
	return get_active_ceiling_sensor().tile_found()

func get_dist_linear_ceiling():
	return get_active_ceiling_sensor().get_distance_linear()

func get_dist_vector_ceiling():
	return get_active_ceiling_sensor().get_distance_vector()

func get_normal_ceiling():
	return get_active_ceiling_sensor().get_normal()

# ---------- Wall (Sensors E and F) ----------

func is_on_left_wall():
	_position_sensors()
	return $Sensor_E.is_colliding()

func is_on_right_wall():
	_position_sensors()
	return $Sensor_F.is_colliding()

func is_on_wall():
	return is_on_left_wall() or is_on_right_wall()

func tile_found_left_wall():
	return $Sensor_E.tile_found()

func tile_found_right_wall():
	return $Sensor_F.tile_found()

func tile_found_wall():
	return tile_found_left_wall() or tile_found_right_wall()

func get_dist_linear_left_wall():
	_position_sensors()
	return $Sensor_E.get_distance_linear()

func get_dist_vector_left_wall():
	_position_sensors()
	return $Sensor_E.get_distance_vector()

func get_dist_linear_right_wall():
	_position_sensors()
	return $Sensor_F.get_distance_linear()

func get_dist_vector_right_wall():
	_position_sensors()
	return $Sensor_F.get_distance_vector()

func _draw():
	if true:#Engine.is_editor_hint():
		var points = [
				Vector2(-width_radius, -0.5).rotated(direction*PI/2-PI/2)+Vector2(0.5, 0.5), Vector2(-width_radius, height_radius+0.5).rotated(direction*PI/2-PI/2)+Vector2(0.5, 0.5),
				Vector2(width_radius, -0.5).rotated(direction*PI/2-PI/2)+Vector2(0.5, 0.5), Vector2(width_radius, height_radius+0.5).rotated(direction*PI/2-PI/2)+Vector2(0.5, 0.5),
				Vector2(-width_radius, 0.5).rotated(direction*PI/2-PI/2)+Vector2(0.5, 0.5), Vector2(-width_radius, -height_radius-0.5).rotated(direction*PI/2-PI/2)+Vector2(0.5, 0.5),
				Vector2(width_radius, 0.5).rotated(direction*PI/2-PI/2)+Vector2(0.5, 0.5), Vector2(width_radius, -height_radius-0.5).rotated(direction*PI/2-PI/2)+Vector2(0.5, 0.5),
				Vector2(0.5, 0).rotated(direction*PI/2-PI/2)+Vector2(0.5, 0.5), Vector2(-push_radius-0.5, 0).rotated(direction*PI/2-PI/2)+Vector2(0.5, 0.5),
				Vector2(-0.5, 0).rotated(direction*PI/2-PI/2)+Vector2(0.5, 0.5), Vector2(push_radius+0.5, 0).rotated(direction*PI/2-PI/2)+Vector2(0.5, 0.5)
			]
		var offset = -Vector2(wrapf(global_position.x, 0, 1), wrapf(global_position.y, 0, 1))
		draw_line(points[0], points[1], Color.GREEN, 1)
		draw_line(points[2], points[3], Color.CYAN, 1)
		draw_line(points[4], points[5], Color.DODGER_BLUE, 1)
		draw_line(points[6], points[7], Color.YELLOW, 1)
		draw_line(points[8], points[9], Color.MAGENTA, 1)
		draw_line(points[10], points[11], Color.RED, 1)
		for f in [Vector2.ZERO, Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
			var col = Color.BLACK if f == Vector2.ZERO else Color.WHITE
			draw_rect(Rect2(f, Vector2(1, 1)), col)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
