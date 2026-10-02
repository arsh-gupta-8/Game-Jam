extends Node2D

var fishSprite: Sprite2D = Sprite2D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fishSprite.rotate(90)
	fishSprite.scale.x = 0.4
	fishSprite.scale.y = 0.4
	fishSprite.position = Vector2i(1000, 600)
	fishSprite.texture = load("res://Assets/blue-fish-vector-illustration-free-png.webp")
	add_child(fishSprite)

func toggleFish():
	if Global.heldFish:
		fishSprite.visible = false
		Global.heldFish = false
	else:
		fishSprite.visible = true
		Global.heldFish = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		toggleFish()
