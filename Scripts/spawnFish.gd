extends Node2D

var speed = 250
var catchCDLength: int = 1
var catchCD: Timer = Timer.new()

@export var catch_radius: float = 500.0  
var catch_center: Vector2

var allFish: Array[Resource] = []
var spawnTimer = Timer.new()

# get darker as depth is lower
const START_DEPTH := 1000     # depth where it's fully bright
const DARK_DEPTH := 0   # depth where it's at its darkest
const MAX_DARKNESS := 0.85   # 1.0 would be pure black
@onready var dark_tint: ColorRect = $DarkTint

# smokescreen
@onready var smokescreen: Sprite2D = $Smokescreen
@onready var catch_sound: AudioStreamPlayer2D = $CatchSound
const FADE_IN_TIME := 0.1    # fast
const FADE_OUT_TIME := 0.9   # slower
var flash_tween: Tween

func _ready() -> void:
	get_all_assets_in_folder("res://Assets/Fish/")
	spawnTimer.autostart = true
	spawnTimer.wait_time = 3.0
	spawnTimer.timeout.connect(spawnNewFish)
	add_child(spawnTimer)

	catchCD.wait_time = catchCDLength
	catchCD.one_shot = true
	add_child(catchCD)

	catch_center = Vector2(1305, 555)
	queue_redraw()
	
	smokescreen.modulate.a = 0.0


func get_all_assets_in_folder(folder_path: String) -> void:  
	for file_name in ResourceLoader.list_directory(folder_path):
			
		var full_path: String = folder_path + file_name
		var asset = ResourceLoader.load(full_path)
		
		if asset:
			allFish.append(asset)


func spawnNewFish():
	print("Spawned a fish!")
	spawnTimer.wait_time = randf_range(1, 2)

	var fish = CharacterBody2D.new()
	fish.z_index = 4
	var fish_script = load("res://Scripts/fishConstraint.gd")
	fish.set_script(fish_script)

	var fishBody = Sprite2D.new()
	fishBody.scale.x = 0.3
	fishBody.scale.y = 0.3
	fishBody.texture = allFish.pick_random()
	fishBody.modulate = Color(0.537, 0.745, 0.992, 0.902) 
	fish.add_child(fishBody)

	add_child(fish)
	var screenSize = get_viewport_rect().size
	var centerPosition = Vector2(randf_range(1304 - 0.15*screenSize.x, 1304 + 0.15*screenSize.x), randf_range(555 - 0.15*screenSize.y, 555 + 0.15*screenSize.y))

	var random_angle = randf_range(0.0, TAU)
	var offset_vector = Vector2.from_angle(random_angle) * catch_radius
	var spawnPos = catch_center + offset_vector

	var directionVector = centerPosition - spawnPos
	if directionVector.angle() > -PI/2 and directionVector.angle() < PI/2:
		fishBody.flip_v = true
	fishBody.rotate(directionVector.angle()+PI)
	fish.global_position = spawnPos

	var setVelocity = directionVector.normalized() * speed
	fish.velocity = setVelocity


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and catchCD.time_left <= 0 and (Global.current % 4) == 0:
		var caught_any := false
		for child in get_children():
			if child is CharacterBody2D:
				if child.global_position.distance_to(catch_center) <= catch_radius:
					Global.fishCaught.append("New Fish")
					child.queue_free()
					caught_any = true
		if caught_any:
			catchCD.start()
			play_catch_effect()
		print(Global.fishCaught)
	
	# get darker as depth is lower
	var t := clampf(inverse_lerp(START_DEPTH, DARK_DEPTH, Global.depth), 0.0, 1.0)
	dark_tint.color.a = t * MAX_DARKNESS
	
func play_catch_effect() -> void:
	catch_sound.play()

	if flash_tween and flash_tween.is_running():
		flash_tween.kill()   # restart cleanly if a catch happens mid-fade

	smokescreen.modulate.a = 0.0
	flash_tween = create_tween()
	flash_tween.tween_property(smokescreen, "modulate:a", 1.0, FADE_IN_TIME)
	flash_tween.tween_property(smokescreen, "modulate:a", 0.0, FADE_OUT_TIME)
