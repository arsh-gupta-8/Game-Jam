extends CharacterBody2D

func _physics_process(delta: float) -> void:
	move_and_slide()
	var screen_size = get_viewport_rect().size
	if global_position.x < 545 or global_position.x > screen_size.x or global_position.y < 140 or global_position.y > 955:
		queue_free()
