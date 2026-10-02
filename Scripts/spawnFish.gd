extends Node2D

var speed = 250

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var spawnTimer = Timer.new()
	spawnTimer.autostart = true
	spawnTimer.wait_time = 3.0
	spawnTimer.timeout.connect(spawnNewFish)
	add_child(spawnTimer)


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
	fish.global_position = spawnPos
	
	var setVelocity = directionVector.normalized() * speed
	fish.velocity = setVelocity

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
