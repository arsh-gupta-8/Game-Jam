extends CharacterBody2D

func _physics_process(delta: float) -> void:
	move_and_slide()
	var screen_size = get_viewport_rect().size
	if global_position.x < -100 or global_position.x > screen_size.x + 100 or global_position.y < -100 or global_position.y > screen_size.y + 100:
		queue_free()
