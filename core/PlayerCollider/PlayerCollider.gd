@tool
extends Node2D
class_name PlayerCollider

enum Dir {RIGHT, DOWN, LEFT, UP}
enum Axis {X, Y}

@export var width_radius : int = 9 #7
@export var height_radius : int = 19 #14
@export var push_radius : int = 10 #10
@export_enum("Right", "Down", "Left", "Up") var direction : int = Dir.DOWN
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !Engine.is_editor_hint():
		_position_sensors()
