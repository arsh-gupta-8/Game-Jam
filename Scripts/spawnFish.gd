extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnNewFish()
	pass # Replace with function body.

func spawnNewFish():
	print("Spawned a fish!")
	
	var fish = Sprite2D.new()
	
	# Making the fish a circle for now
	var fishPlaceholder = GradientTexture2D.new()
	fishPlaceholder.width = 64
	fishPlaceholder.height = 64
	fishPlaceholder.fill = GradientTexture2D.FILL_RADIAL
	
	fish.texture = fishPlaceholder
	add_child(fish)
	var screenSize = get_viewport_rect().size
	var centerPosition = screenSize / 2.0
	
	var side = randi() % 4
	var spawnPos = Vector2.ZERO
	if side == 0:
		spawnPos = Vector2(randi_range(0, screenSize.x), 0)
	elif side == 2:
		spawnPos = Vector2(randi_range(0, screenSize.x), screenSize.y)
	elif side == 3:
		spawnPos = Vector2(0, randi_range(0, screenSize.y))
	else:
		spawnPos = Vector2(screenSize.x, randi_range(0, screenSize.y))
	
	var directionVector = centerPosition-spawnPos
	var targetPosition = spawnPos+2*directionVector
	fish.global_position = spawnPos
	
	var fishTween = create_tween()
	var duration = 4.0
	
	fishTween.tween_property(fish, "global_position", targetPosition, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	fishTween.tween_callback(fish.queue_free)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var spawnTimer = Timer.new()
	spawnTimer.autostart = true
	spawnTimer.wait_time = 3.0
	spawnTimer.timeout.connect(spawnNewFish)
	add_child(spawnTimer)
	
