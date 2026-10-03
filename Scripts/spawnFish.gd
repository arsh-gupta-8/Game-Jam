extends Node2D

var speed = 250
var catchCDLength: int = 1
var catchCD: Timer = Timer.new()

@export var catch_radius: float = 450.0   # change this one number
var catch_center: Vector2


func _ready() -> void:
	var spawnTimer = Timer.new()
	spawnTimer.autostart = true
	spawnTimer.wait_time = 3.0
	spawnTimer.timeout.connect(spawnNewFish)
	add_child(spawnTimer)

	catchCD.wait_time = catchCDLength
	catchCD.one_shot = true
	add_child(catchCD)

	catch_center = get_viewport_rect().size / 2
	queue_redraw()


func spawnNewFish():
	print("Spawned a fish!")

	var fish = CharacterBody2D.new()
	var fish_script = load("res://Scripts/fishConstraint.gd")
	fish.set_script(fish_script)

	var fishBody = Sprite2D.new()

	# Making the fish a template for now
	var fishPlaceholder = GradientTexture2D.new()
	fishPlaceholder.width = 64
	fishPlaceholder.height = 64

	fishBody.texture = fishPlaceholder

	fish.add_child(fishBody)

	add_child(fish)
	var screenSize = get_viewport_rect().size
	var centerPosition = Vector2(randf_range(0.25*screenSize.x, 0.75*screenSize.x), randf_range(0.25*screenSize.y, 0.75*screenSize.y))

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

	var directionVector = centerPosition - spawnPos
	fish.global_position = spawnPos

	var setVelocity = directionVector.normalized() * speed
	fish.velocity = setVelocity


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and catchCD.time_left <= 0:
		var caught_any := false
		for child in get_children():
			if child is CharacterBody2D:
				if child.global_position.distance_to(catch_center) <= catch_radius:
					Global.fishCaught.append("New Fish")
					child.queue_free()
					caught_any = true
		if caught_any:
			catchCD.start()
		print(Global.fishCaught)


func _draw() -> void:
	draw_arc(to_local(catch_center), catch_radius, 0, TAU, 128, Color.WHITE, 4.0, true)
