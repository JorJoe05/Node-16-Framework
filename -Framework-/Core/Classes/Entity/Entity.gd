extends Node2D
class_name Entity

var gsp : float
var ang : float
var velocity : Vector2

var pixel : Vector2 :
	set(value):
		value = Vector2(floor(value.x), floor(value.y))
		position = value
		pixel = value
	get:
		return pixel
var subpixel : Vector2 :
	set(value):
		value = Vector2(floor(value.x), floor(value.y))
		subpixel = value
	get:
		return subpixel

func gsp_to_velocity():
	velocity = Vector2(gsp*cos(ang), gsp*-sin(ang))

func move():
	position += velocity

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
