extends Entity

var velocity : Vector2

func _physics_process(delta):
	velocity.y += 0.2
	
	velocity.x = Input.get_axis("ui_left", "ui_right")*3
	
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = -5
	
	pixel += velocity
	
	if $TileCheck.is_colliding():
		velocity.y = 0
		pixel += $TileCheck.get_distance_vector()
