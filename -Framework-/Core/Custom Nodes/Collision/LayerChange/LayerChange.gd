extends Area2D
class_name LayerChange

@export_enum("Horizontal", "Vertical") var axis : int = 1
@export var flip_direction := false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.area_entered.connect(_change_layer)

func _change_layer(area):
	var body = area.owner
	if body is Player:
		match axis:
			0:
				if body.velocity.y <0 :
					body.Collider.collision_mask = 1
				elif body.velocity.y > 0:
					body.Collider.collision_mask = 2
			1:
				if body.velocity.x <0 :
					body.Collider.collision_mask = 1
				elif body.velocity.x > 0:
					body.Collider.collision_mask = 2
